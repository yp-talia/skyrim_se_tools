unit VO_Export_DIAL;
{
  This script flattens certain repeated subrecords (e.g. "Conditions \ Condition")
  into multiple rows for each subrecord. Then it writes the CSV 
  in ANSI encoding (TStringList.SaveToFile), logging each step 
  for debugging.

  Detailed documentation can be found at: https://docs.google.com/document/d/1U0C5H7hmUqyr22r49IliApJTO-XqURtunwL0mRD2Nhc/edit?tab=t.0

  Key points:
    - Flattening logic: if NonAggregatedPaths has "Conditions \ Condition", 
      we skip "Conditions \ Condition" in baseline, then produce a new row 
      for each child inside "Conditions \ Condition".
    - We call CollectSubrecordFields to store the node's own 
      editValue AND any child sub-entries.
    - We store results in 'Rows' (a TList of TStringList). 
      Each row is later written as a line in the CSV.
    - The final CSV is encoded in local ANSI, no BOM, no wide 
      string usage, so it's safe in older SSEEdit JvInterpreter.

  Usage:
    1) In Initialize, set TargetSignatures, NonAggregatedPaths, etc.
    2) Run in SSEEdit on your plugin. 
    3) The final CSV is saved in the SSEEdit folder.
}

interface
uses
  xEditAPI, Classes, SysUtils;

function Initialize: Integer;
function Process(e: IInterface): Integer;
function Finalize: Integer;

implementation

var
  // Each final row is a TStringList
  Rows: TList;

  // Discovered column names
  AllColumnNames: TStringList;

  // Config
  TargetSignatures: TStringList;   
  NonAggregatedPaths: TStringList; 
  EnableLogging: Boolean;
  LogLevel: Integer;

// ------------------------------------------------------------------------
// Logging & CSV helpers
// ------------------------------------------------------------------------

(*
  LOG LEVELS:
    1 = Errors only
    2 = Warnings + Errors
    3 = Info + Warnings + Errors
    4 = Debug + Info + Warnings + Errors
*)

procedure Log(Level: Integer; const Msg: string);
begin
  if EnableLogging and (Level <= LogLevel) then
    AddMessage(Msg);
end;

// CSV-escape function
function CSVEscape(const s: string): string;
var
  temp: string;
begin
  temp := Trim(s);
  // Double up quotes
  temp := StringReplace(temp, '"', '""', [rfReplaceAll]);
  // If it has comma/semicolon/newline or quotes, wrap in quotes
  if (Pos(',', temp) > 0) or (Pos(';', temp) > 0) or
     (Pos(#10, temp) > 0) or (Pos(#13, temp) > 0) or (Pos('"', temp) > 0) then
    Result := '"' + temp + '"'
  else
    Result := temp;
end;

// Add or update a column in rowData
procedure SetRowValue(rowData: TStringList; const columnName, newValue: string);
begin
  if AllColumnNames.IndexOf(columnName) < 0 then
  begin
    Log(4, '  -> Registering new column: "' + columnName + '"');
    AllColumnNames.Add(columnName);
  end;
  rowData.Values[columnName] := newValue;
end;

// If SSEEdit has a reference but no textual value, fallback to Name(LinksTo)
function GetEditValueOrRef(e: IInterface): string;
var
  raw: string;
  linked: IInterface;
begin
  raw := GetEditValue(e);
  linked := LinksTo(e);
  if Assigned(linked) and (Trim(raw) = '') then
    raw := Name(linked);
  Result := raw;
end;

// ------------------------------------------------------------------------
// Flatten Logic
// ------------------------------------------------------------------------

// Gather top-level fields except the ones we plan to flatten
procedure CollectBaselineFields(rec: IInterface; baseline: TStringList);
var
  i, j: Integer;
  child: IInterface;
  childName: string;
  skipThis: Boolean;
  val: string;
begin
  Log(3, 'CollectBaselineFields -> ' + Name(rec));

  for i := 0 to ElementCount(rec) - 1 do
  begin
    child := ElementByIndex(rec, i);
    childName := Name(child);

    // if childName is in NonAggregatedPaths, skip from baseline
    skipThis := False;
    for j := 0 to NonAggregatedPaths.Count - 1 do
    begin
      if Pos(childName, NonAggregatedPaths[j]) = 1 then
      begin
        Log(4, '  Skipping top-level container "' + childName + '" from baseline');
        skipThis := True;
        Break;
      end;
    end;
    if skipThis then Continue;

    val := GetEditValueOrRef(child);
    Log(4, '  Baseline field "' + childName + '" => "' + val + '"');
    SetRowValue(baseline, childName, val);
  end;
end;

// Store this node's own value, then enumerate children
procedure CollectSubrecordFields(e: IInterface; rowData: TStringList; parentPath: string);
var
  selfVal: string;
  c: IInterface;
  i: Integer;
  cName, childPath: string;
begin
  // 1) Store the node's own value
  selfVal := GetEditValueOrRef(e);
  if Trim(selfVal) <> '' then
  begin
    // only store if we have a path
    if parentPath <> '' then
    begin
      Log(4, '   CollectSubrecordFields node "' + parentPath + '" => "' + selfVal + '"');
      SetRowValue(rowData, parentPath, selfVal);
    end;
  end;

  // 2) then gather subchildren
  for i := 0 to ElementCount(e) - 1 do
  begin
    c := ElementByIndex(e, i);
    cName := Name(c);
    childPath := parentPath + ' \ ' + cName;

    CollectSubrecordFields(c, rowData, childPath);
  end;
end;

// Flatten repeated container path
procedure FlattenRepeatedContainer(rec: IInterface; containerPath: string; baseline: TStringList);
var
  slashPos, cCount, i: Integer;
  topLevel, subName: string;
  container, subrec: IInterface;
  subData, finalRow: TStringList;
begin
  Log(3, 'FlattenRepeatedContainer -> "' + containerPath + '" in ' + Name(rec));

  slashPos := Pos('\', containerPath);
  if slashPos > 0 then
  begin
    topLevel := Trim(Copy(containerPath, 1, slashPos - 1));
    subName  := Trim(Copy(containerPath, slashPos + 1, Length(containerPath)));
  end
  else
  begin
    topLevel := Trim(containerPath);
    subName  := '';
  end;

  Log(4, '  topLevel="' + topLevel + '", subName="' + subName + '"');

  // find that container
  container := ElementByPath(rec, topLevel);
  if not Assigned(container) then
  begin
    Log(2, '  Container "' + topLevel + '" not found on ' + Name(rec));
    Exit;
  end;

  cCount := ElementCount(container);
  Log(3, '  Found ' + IntToStr(cCount) + ' child subrecords under "' + topLevel + '"');

  // for each child
  for i := 0 to cCount - 1 do
  begin
    subrec := ElementByIndex(container, i);
    Log(3, '   Child index=' + IntToStr(i) + ' name="' + Name(subrec) + '"');

    if (subName <> '') and (not SameText(Name(subrec), subName)) then
    begin
      Log(4, '    Skipping child, mismatch with subName="' + subName + '"');
      Continue;
    end;

    // gather subfields
    subData := TStringList.Create;
    Log(3, '    Collecting subfields for ' + Name(subrec));

    // note the path used, e.g. "Conditions \ Condition"
    FlattenRepeatedContainer_Collect(subrec, subData, topLevel + ' \ ' + Name(subrec));

    // merge baseline + subData
    finalRow := TStringList.Create;
    finalRow.AddStrings(baseline);
    finalRow.AddStrings(subData);
    Rows.Add(finalRow);

    subData.Free;
  end;
end;

// This helper calls CollectSubrecordFields to store the subrec's own value
// plus deeper children.
procedure FlattenRepeatedContainer_Collect(e: IInterface; rowData: TStringList; path: string);
begin
  Log(4, '     FlattenRepeatedContainer_Collect node="' + path + '"');
  CollectSubrecordFields(e, rowData, path);
end;

// Build baseline, flatten each path
procedure ExportOneRecord(rec: IInterface);
var
  baseline: TStringList;
  rowCountBefore, rowCountAfter: Integer;
  i: Integer;
  singleRow: TStringList;
  edidVal: string;
begin
  Log(2, 'ExportOneRecord -> ' + Name(rec));

  baseline := TStringList.Create;
  try
    edidVal := GetElementEditValues(rec, 'EDID');
    if edidVal = '' then
      edidVal := 'FormID_' + IntToHex(FormID(rec), 8);

    SetRowValue(baseline, 'EditorID', edidVal);
    SetRowValue(baseline, 'RecordName', Name(rec));
    SetRowValue(baseline, 'FormID', IntToHex(FormID(rec), 8));

    // baseline
    CollectBaselineFields(rec, baseline);

    // flatten subcontainers
    rowCountBefore := Rows.Count;
    for i := 0 to NonAggregatedPaths.Count - 1 do
    begin
      Log(3, '  Flatten path "' + NonAggregatedPaths[i] + '" in ' + Name(rec));
      FlattenRepeatedContainer(rec, NonAggregatedPaths[i], baseline);
    end;
    rowCountAfter := Rows.Count;

    // if no new rows, store baseline
    if rowCountAfter = rowCountBefore then
    begin
      Log(3, 'No flatten expansions created rows; adding single baseline row');
      singleRow := TStringList.Create;
      singleRow.AddStrings(baseline);
      Rows.Add(singleRow);
    end;
  finally
    baseline.Free;
  end;
end;

// ----------------------------------------------------------------------
// SSEEdit script entry points
// ----------------------------------------------------------------------

function Initialize: Integer;
begin
  Rows := TList.Create;
  AllColumnNames := TStringList.Create;
  AllColumnNames.Sorted := True;
  AllColumnNames.Duplicates := dupIgnore;

  // Logging
  EnableLogging := True;
  LogLevel := 4; // Debug

  // Signatures
  TargetSignatures := TStringList.Create;
  // Only look at FLST records
  TargetSignatures.Add('DIAL');

  // subpaths to flatten
  NonAggregatedPaths := TStringList.Create;
  // E.g. flatten each Condition within Conditions container
  AddMessage('Initialized "GenericFlatten_ANSI_DebugFinal" script. LogLevel=' + IntToStr(LogLevel));
  Result := 0;
end;

function Process(e: IInterface): Integer;
begin
  Result := 0;
  if TargetSignatures.IndexOf(Signature(e)) >= 0 then
  begin
    Log(2, 'Process -> Flattening ' + Name(e));
    ExportOneRecord(e);
  end
  else
    Log(4, 'Skipping ' + Name(e) + ' signature=' + Signature(e));
end;

function Finalize: Integer;
var
  headers, outFile: TStringList;
  i, j: Integer;
  rowData: TStringList;
  line, colName, val, csvFileName: string;
begin
  Log(2, 'Finalize -> building CSV output');
  headers := TStringList.Create;
  outFile := TStringList.Create;
  try
    // Force these columns first
    headers.Add('EditorID');
    headers.Add('RecordName');
    headers.Add('FormID');

    // Then discovered columns
    for i := 0 to AllColumnNames.Count - 1 do
    begin
      colName := AllColumnNames[i];
      if (colName = 'EditorID') or (colName = 'RecordName') or (colName = 'FormID') then
        Continue;
      headers.Add(colName);
    end;

    // header line
    line := '';
    for i := 0 to headers.Count - 1 do
    begin
      line := line + CSVEscape(headers[i]);
      if i < headers.Count - 1 then
        line := line + ',';
    end;
    outFile.Add(line);

    Log(3, 'We have ' + IntToStr(Rows.Count) + ' total rows to write');
    // write rows
    for i := 0 to Rows.Count - 1 do
    begin
      rowData := TStringList(Rows[i]);
      line := '';
      for j := 0 to headers.Count - 1 do
      begin
        colName := headers[j];
        val := rowData.Values[colName];
        line := line + CSVEscape(val);
        if j < headers.Count - 1 then
          line := line + ',';
      end;
      outFile.Add(line);
      rowData.Free;
    end;
    Rows.Clear;
    Rows.Free;

    csvFileName := 'DIAL_export.csv';
    Log(2, 'Saving CSV to ' + ProgramPath + csvFileName);
    // Save in local ANSI codepage
    outFile.SaveToFile(ProgramPath + csvFileName);

    Log(2, 'Done! CSV export finished.');
  finally
    headers.Free;
    outFile.Free;
    TargetSignatures.Free;
    NonAggregatedPaths.Free;
    AllColumnNames.Free;
  end;
  Result := 0;
end;

end.
