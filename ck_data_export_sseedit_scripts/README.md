# SSEEdit Script: Export_Flatten_To_CSV

## Introduction
The Export_Flatten_To_CSV script exports records from Skyrim mods via SSEEdit as a CSV file. You can choose which signatures are exported (e.g., INFO, QUST, ARMO, etc.) and which subrecords (fields) are included. To enable quick analysis, the script flattens the relationship between subrecords and handles the encoding of special characters.

For those comfortable with the Creation Kit Editor, SSEEdit, and modifying script configurations, the full script is available at the end of this document (or as a separate file); here is the configuration overview.
SSEEdit (the Skyrim SE version of the xEdit tool​ on nexusmods.com) is an advanced plugin viewer and editor widely used to inspect and modify Skyrim plugin files (.esp/.esm).

Importantly, this script is read-only – it does not alter your mod files; it only reads data and writes an external report.

### What are "record signatures"?
In Skyrim plugin files, every record has a four-letter type code (or signature) that identifies its category (e.g. ARMO for Armour, WEAP for Weapon). The script’s name highlights that it works with these record signatures to organise output. For reference, Skyrim plugin files are composed of records and fields (UESP reference), and each record’s signature indicates what kind of object or data it represents (for example, ARMO = Armour). You can find a full list of record signatures on the UESP wiki’s Skyrim Mod File Format page. Understanding record signatures can help you filter or select the right records when using the script.

## Requirements
1. SSEEdit 4.x – Make sure you have SSEEdit (also known as xEdit for Skyrim Special Edition) installed. You can download it from Nexus Mods. No special plugins or additional tools are required beyond SSEEdit itself.
2. Basic xEdit Knowledge – You should know how to load plugins in SSEEdit and select records. Familiarity with Skyrim record structure (Editor IDs, FormIDs, etc.) is helpful for interpreting the output.
3. Spreadsheet Software – The script outputs a comma-separated values file (.csv). Having a spreadsheet program (such as Microsoft Excel or Google Sheets) will help to open and view the results in a tabular form.

## Usage Instructions
1. Launch SSEEdit and Load Plugins:
   - Open SSEEdit and load the plugin(s) that contain the records you want to export. It’s often wise to back up your plugin files before running any scripts (though this particular script will not modify them).
2. Select Target Records:
   - In the SSEEdit tree view, highlight the records or group of records you wish to export.
   - Initially, it is recommended that you run this script on either a single record (e.g., one NPC) or all the records in a mod.
   - You can select an entire category (e.g. all NPC records under an NPC_ group) or specific records.
     - (The script will process only the records under whatever node or selection you right-click. Selecting a top-level category or plugin will include all records within, whereas selecting a specific subgroup will restrict it to that subgroup.)
3. Select or Add the Export Script:
   - In the Apply Script dialogue, choose Export_Flatten_To_CSV from the list of available scripts.
   - If you have already placed the script file in your SSEEdit Edit Scripts folder (or have run it before), it should appear in the dropdown list. Simply select it, then click “OK” to run the script.
4. First-Time Setup: If the script is not yet in the list (for example, if this is your first time using it), you will need to add it manually:
5. In the script selection dropdown, scroll and select <new script> (usually at the top of the list). This will show a new blank script editor window.
6. Copy the full Pascal script code from the Appendix at the end of this manual/separate file and paste it into the editor window.
7. Click the Save button in the script editor. When prompted for a name, enter Export_Flatten_To_CSV (this should match the script’s internal name for consistency).
8. Close the editor window or click OK to run. The new script should now appear selected in the Apply Script dialogue. (Next time, it will be available directly in the list.)
9. Wait for Completion:
   - The script will process each record sequentially. This may take a moment if you selected many records or an entire plugin. SSEEdit’s Messages tab will log progress. Once finished, the Messages log will usually include a confirmation like “Export complete” and the path to the generated CSV file.
10. Open the CSV File:
    - Locate the CSV file created by the script (as specified in the save prompt or log message). You can now open this file with your preferred spreadsheet software to view the results in a table. Each row corresponds to a record from your selection, and each column corresponds to a piece of data (field) from that record. Refer to the next section for details on the output format and how to interpret it.

(Note: You do not need to manually copy the script into any SSEEdit folders if you followed the steps above. SSEEdit will “version” script changes every time you click “Save”; these can be seen in the Edit Scripts subfolder.)

# Configuring the Script
The script comes with three main types of ‘settings’ to configure. Here are the common variables:
1. TargetSignatures
This list tells the script which record types (by signature) to process. For example, 'INFO' will only export dialogue info records:
```
TargetSignatures.Add('INFO');
```
Whereas 'NPC_' and 'INFO' would export both NPC and dialogue info records in the same file:
```
TargetSignatures.Add('INFO');
TargetSignatures.Add('NPC_');
```
You can include as many valid signature types as you wish, for example:

```
TargetSignatures.Add('INFO');
TargetSignatures.Add('NPC_');
TargetSignatures.Add('QUST');
TargetSignatures.Add('DIAL');
```
Conversely, if you only want to export certain record types, remove any signatures you don’t need.

(It is often useful to export only one type of record at a time, because you will end up with many blank cells if exporting record types that do not share similar fields.)
2. NonAggregatedPaths
This list defines which subrecords should be flattened into multiple rows rather than aggregated in one row. For instance, in dialogue INFO records, specifying "Conditions \ Condition" will cause each Condition to appear on its own row in the CSV:
```
NonAggregatedPaths.Add('Conditions \ Condition');
```
That way, if an INFO has multiple conditions, you’ll see one row per condition in the CSV. Similarly, you could flatten things like Responses or Items if working with inventory lists in NPC or container records.

Tip: Be selective—flattening many subrecords can produce very large CSVs if records contain lots of nested data. Start with only what you truly need on a separate row.

Path Format: Usually matches SSEEdit’s naming in the record view. For example, SSEEdit may display nested subrecords as Conditions \ Condition. Check the script’s comments or SSEEdit’s panel for the exact path name.

Records with no children: If a record does not contain children (one good example is FormIDs in FLST (Form List) signatures), then you only need to provide the parent record name, not Parent \ Child.

```
NonAggregatedPaths.Add('FormID');
```
3. Logging Options
EnableLogging: A boolean (True or False) indicating whether the script outputs log messages to SSEEdit’s Messages tab. Set this to True if you need to troubleshoot or want a detailed record of the script’s activity.
```
EnableLogging := True;
```
LogLevel: A numerical value controlling how verbose the logging is. A higher value typically yields more detailed messages (e.g., 1 for minimal logging, 4 for detailed debug logs). Check the script comments for exact meaning per level.
```
LogLevel := 4;
```

### Editing these Configurations:
Open the script file (for instance, Export_Flatten_To_CSV.pas) in a text editor or SSEEdit’s script editor (Right-click -> Apply Script on a record). Look for lines such as:
```
EnableLogging := True;
LogLevel := 4;
TargetSignatures := TStringList.Create;
TargetSignatures.Add('INFO');

NonAggregatedPaths := TStringList.Create;
NonAggregatedPaths.Add('Conditions \ Condition');
```
Adjust the values or add/remove entries to suit your export requirements. Once done, save the .pas file. The next time you apply the script in SSEEdit, it will use your updated configuration.

## Output Format and Examples
Export_Flatten_To_CSV outputs values in a CSV file.

The first three columns are always EditorID, Record Name, and FormID for each record. These identify the record:

EditorID – The record’s Editor ID (a unique identifier used in the Creation Kit and xEdit).

Record Name – The in-game name or descriptive name of the record, if applicable. (For many records, this is the ‘Name’ field or similar; for records without a name field, this may be blank.)

FormID – The record’s Form ID in hexadecimal, including the load order prefix. This uniquely identifies the record in the game data.
Following these, additional columns will appear for each important field that the script exports from the record.

Because the script flattens nested fields, it pulls out data that might normally be nested in subrecords. For example, if a record has condition entries (common in dialogues, quests, perks, etc.), the script will output those conditions in separate columns rather than leaving them buried in a list.

Example snippet of CSV output:
EditorID
Record Name
FormID
Condition Function
Value
DialogueWhiterun01
Whiterun Guard Hello
000D1234
GetIsID
1

EditorID: DialogueWhiterun01 – The Editor ID of a dialogue topic record.

Record Name: Whiterun Guard Hello – The actual dialogue line or object name.

FormID: 000D1234 – The unique Form ID of this record.

Condition Function: GetIsID – The condition function used (meaning the dialogue line is conditioned on a specific NPC or object ID).

Value: 1 – The comparison value for the condition, typically indicating true/yes.

If the condition function requires a reference or form to check against (for example, GetIsID usually checks if an actor is a specific base object), the script will include that information in the output. In many cases, Value will be 1 or 0 for Boolean conditions. For records that have multiple conditions, the script will output each condition in its own set of columns (e.g., Condition Function 2, Value 2, etc.). Conversely, if a record has no conditions (or no such complex fields), the related columns will simply be blank for that row.

Aside from conditions, the script may also flatten other subrecord data. For example, if exporting weapons or armour, you might see columns for each damage type, armour rating, or other stats that are normally fields within the record. The exact columns depend on the record type and what the script is configured to export. The key point is that each relevant piece of nested data becomes a column so you don’t have to dig into subrecords manually.

**Tip:** Once you open the CSV in a spreadsheet, you can use filters or sort by columns to quickly analyse the data. For instance, you could sort by the Value of a condition to see which dialogue lines have that condition set to true or false. You could also filter by Condition Function to group all records using GetIsID vs. other functions. This makes it much easier to audit game data (such as all dialogues conditioned on a certain quest, or all items with a certain keyword) without manually clicking through xEdit’s interface.

## Script Limitations (What the Script Does and Does Not Do)
## What it does:

Exports data in a structured CSV: Ideal for gaining an overview of mod content. This can be especially helpful for dialogue records, item lists, leveled lists, etc.

Flattens specific subrecords: If a record type (like INFO) has multiple conditions or responses, you can list each sub-entry as a separate row, making it simpler to filter or sort.

Handles only the signatures and subpaths you specify: If you add NPC_ to TargetSignatures, you can flatten NPC data; if you list "Conditions \ Condition" in NonAggregatedPaths, you’ll get each condition on a separate row. Otherwise, the script ignores that data.

Produces an ANSI-encoded CSV file: Chosen for broad compatibility, especially with older programs.

## What it does not do (and common misconceptions):
Does not export all data by default: It only processes the record signatures you configure. If you want to see a different record type in the output, you must add its signature to TargetSignatures.

Does not preserve in-game formatting or import changes: The script simply reads raw data from the plugin file. In-game text formatting (e.g. colours, line breaks) may not appear exactly as it does in Skyrim, and there is no mechanism to re-import edited CSV data back into the plugin.

Will not modify your plugin or fix issues: It’s strictly a read-only exporter. If you need to fix or alter data, you must do that in the Creation Kit or with a separate xEdit script designed for editing.

May not capture every nested subrecord: Only those specified in NonAggregatedPaths. Others remain aggregated in the single row.

In short, Export_Flatten_To_CSV is purpose-built to export targeted data and flatten certain lists for easier analysis. It will not overhaul your plugin or gather all fields unless specifically configured.

## Troubleshooting
Even a straightforward export script can encounter issues. Below are common problems and potential fixes:

### Script not appearing in the “Apply Script” list

Ensure the .pas file is named correctly (Export_Flatten_To_CSV.pas if that’s what you saved it as).

Check that it is in the correct Edit Scripts folder for SSEEdit. If you have multiple xEdit tools for different Bethesda games, each has its own folder.

Restart SSEEdit after placing the file; the script should appear alphabetically in the list.

### No CSV created after running

Look in SSEEdit’s Messages tab for errors. Possibly no records matched the signatures in your configuration. (For instance, if TargetSignatures only includes INFO, but your plugin has no dialogue info records, nothing is exported.)

Some scripts try to save in SSEEdit’s folder but may fail if you lack permission (e.g. if SSEEdit is installed under Program Files). Try running SSEEdit as administrator or install SSEEdit in a non-protected directory.

If you see an exception or crash, try enabling logging (EnableLogging := True; LogLevel := 4;) for more diagnostic info in SSEEdit’s log.

### Missing records in CSV

Confirm the signature is listed in TargetSignatures. For instance, if you want to export quest data but only have INFO in TargetSignatures, then QUST records are skipped.

Some scripts skip certain records if they do not contain a specific subrecord. Check the code or read the script comments to ensure it’s not filtering out something unintentionally.

### CSV data looks garbled or columns don’t line up

The file is ANSI encoded. If your spreadsheet software expects UTF-8, characters may appear incorrect. You can fix this by explicitly telling your software to read it as ANSI (or Windows-1252).

If the script fails to quote fields containing commas, columns might shift incorrectly. The provided script should handle quoting properly, but if it’s still off, consider adjusting your spreadsheet’s import settings or check your local decimal/list separators.

### Records appear with partial data

Possibly some nested fields you want are not listed in NonAggregatedPaths, so they remain aggregated or are not exported. Update NonAggregatedPaths if you need to flatten additional subrecords.

If these steps do not resolve the issue, you might consult modding forums (e.g. the SkyrimMods subreddit) or SSEEdit’s community Discord for specialised assistance, mentioning you’re using the Export_Flatten_To_CSV script. The community is typically quite helpful with troubleshooting xEdit scripts.