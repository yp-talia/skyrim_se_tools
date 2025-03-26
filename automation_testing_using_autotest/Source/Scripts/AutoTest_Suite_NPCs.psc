Scriptname AutoTest_Suite_NPCs extends AutoTest_Suite
{
  Collection of script functions testing NPCs using screenshots of actors.
  This helps in finding issues with missing textures, incompatible body types, etc.
}

; --- Properties ---
; Marker where the player is teleported for screenshots
ObjectReference Property ViewPointAnchor Auto

; Marker where the NPCs are teleported for screenshots
ObjectReference Property TeleportAnchor Auto

; --- Constants ---
string LOGNAME = "NPCScreenshots"  ; Central log name definition
string JSON_FILE = "AutoTest_NPCs_Statuses.json"  ; Status storage file

; --- API Functions (Required by AutoTest_Suite) ---

; Initialize the script
; [API] This function is mandatory and has to use SetTestType
function InitTests()
  SetTestType("NPCs")
  
  ; Ensure log directory exists and is accessible
  string logPath = "Data/SKSE/Plugins/StorageUtilities/AutoTest/"
  MiscUtil.WriteToFile(logPath + LOGNAME + ".log", "=== " + LOGNAME + " Log Started ===\n", false)
  
  LogMessage("Log file initialized")
  Debug.Notification(LOGNAME + " log initialized")
endFunction

; Register tests
; [API] This function is mandatory
function RegisterTests()
  RegisterTestNPCs()
endFunction

; Prepare the environment for tests
; [API] This function is optional
function BeforeTestsRun()
  ; Enable god mode, disable AI, and UI for clean screenshots
  ConsoleUtil.ExecuteCommand("tgm")
  ConsoleUtil.ExecuteCommand("tcai")
  ConsoleUtil.ExecuteCommand("tai")
  ConsoleUtil.ExecuteCommand("tm")
endFunction

; Run a given registered test
; [API] This function is mandatory
;
; Parameters:
; * *testName* (string): The test name to run
function RunTest(string testName)
  string[] fields = StringUtil.Split(testName, "/")
  
  ; Parse baseId - supports both hex (0x...) and decimal formats
  int baseId = 0
  if (StringUtil.SubString(fields[1], 0, 2) == "0x")
    baseId = HexToInt(StringUtil.SubString(fields[1], 2))
  else
    baseId = fields[1] as int
  endIf
  
  ScreenshotOf(baseId, fields[0])
  SetTestStatus(testName, "ok")
endFunction

; Restore environment after tests
; [API] This function is optional
function AfterTestsRun()
  ; Restore AI and UI, disable god mode
  ConsoleUtil.ExecuteCommand("tai")
  ConsoleUtil.ExecuteCommand("tcai")
  ConsoleUtil.ExecuteCommand("tgm")
  ConsoleUtil.ExecuteCommand("tm")
endFunction

; --- Test Registration Functions ---

; Register test NPCs to be screenshotted
function RegisterTestNPCs()
  ; Main characters
  RegisterScreenshotOf(0x00013BBD, "Skyrim.esm")  ; Balgruuf
  RegisterScreenshotOf(0x000A2C8E, "Skyrim.esm")  ; Lydia
  RegisterScreenshotOf(0x0001A696, "Skyrim.esm")  ; Aela
  RegisterScreenshotOf(0x0001414D, "Skyrim.esm")  ; Ulfric
  
  ; Different sized NPCs
  RegisterScreenshotOf(0x0023AAE, "Skyrim.esm")   ; Giant
  RegisterScreenshotOf(0x00067CD9, "Skyrim.esm")  ; Child
  RegisterScreenshotOf(0x0200283A, "Skyrim.esm")  ; Spider
  
  ; Add more NPCs as needed
endFunction

; Register a screenshot test of a given BaseID
;
; Parameters:
; * *baseId* (Integer): The BaseID to clone and take screenshot
; * *espName* (String): The name of the ESP containing this base ID
function RegisterScreenshotOf(int baseId, string espName)
  RegisterNewTest(espName + "/" + baseId)
endFunction

; --- Core Screenshot Functions ---

; Take a screenshot of a given BaseID
;
; Parameters:
; * *baseId* (Integer): The BaseID to clone and take screenshot
; * *espName* (String): The name of the ESP containing this base ID
function ScreenshotOf(int baseId, string espName)
  ; Get the full form ID including load order
  int fullFormId = baseId + Game.GetModByName(espName) * 16777216
  Form formToSpawn = Game.GetFormFromFile(fullFormId, espName)
  string testId = espName + "/" + baseId
  
  ; Check if form exists
  if formToSpawn == None
    LogMessage("ERROR: Form not found: 0x" + IntToHex(baseId) + " in " + espName)
    SetDetailedStatus(testId, "error_not_found", baseId)
    return
  endif
  
  string formName = formToSpawn.GetName()
  LogMessage("Taking screenshot of " + formName + " (0x" + IntToHex(baseId) + ")")
  Debug.Notification("Processing: " + formName)
  
  ; Setup test environment
  Game.DisablePlayerControls()
  
  ; Store original player scale
  float originalPlayerScale = Game.GetPlayer().GetScale()
  
  ; Position player at viewpoint and reset rotation
  Game.GetPlayer().MoveTo(ViewPointAnchor)
  Game.GetPlayer().SetAngle(0.0, 0.0, 0.0)
  
  ; Force first person view
  Game.ForceFirstPerson()
  Utility.Wait(0.1)
  
  ; Spawn the NPC at anchor position
  ObjectReference newRef = TeleportAnchor.PlaceAtMe(formToSpawn)
  
  ; Remove clothes if configured
  if GetConfig("non_nude") != "true"
    newRef.RemoveAllItems()
  endif
  
  ; Wait for model to fully load
  while !newRef.Is3DLoaded()
    Utility.Wait(0.2)
  endwhile
  Utility.Wait(0.1)
  
  ; Get original NPC scale
  float originalNPCScale = newRef.GetScale()
  
  ; Adjust NPC scale based on original size for better visibility
  AdjustNPCScale(newRef, originalNPCScale)
  
  ; Apply standard FOV setting
  float fovSetting = 75.0
  ConsoleUtil.ExecuteCommand("fov " + fovSetting)
  Utility.Wait(0.2)
  
  ; Make NPC face the player
  newRef.SetAngle(0.0, 0.0, 180.0)
  
  ; Force player to look at NPC
  ConsoleUtil.ExecuteCommand("prid " + IntToHex(newRef.GetFormID()))
  Utility.Wait(0.1)
  
  ; Take the screenshot
  LogMessage("Taking screenshot now...")
  Input.TapKey(183) ; PrintScreen key
  Utility.Wait(0.2)
  
  ; Record status with baseID
  SetDetailedStatus(testId, "ok", baseId)
  
  ; Clean up - restore NPC original scale before deletion
  newRef.SetScale(originalNPCScale)
  newRef.DisableNoWait()
  newRef.Delete()
  
  ; Restore player controls and scale
  Game.EnablePlayerControls()
  Game.GetPlayer().SetScale(originalPlayerScale)
  
  LogMessage("Processing complete for " + formName)
endFunction

; --- Helper Functions ---

; Adjust NPC scale based on original size for better screenshots
;
; Parameters:
; * *npcRef* (ObjectReference): The NPC reference to adjust
; * *originalScale* (float): The original scale of the NPC
function AdjustNPCScale(ObjectReference npcRef, float originalScale)
  if originalScale < 0.3
    ; Very small creatures - make them bigger for the screenshot
    npcRef.SetScale(2.5)
    LogMessage("Small NPC detected, scaling up for visibility")
  elseif originalScale < 0.65
    ; Smaller than average - increase scale a bit
    npcRef.SetScale(1.50)
  elseif originalScale > 1.2
    ; Large creatures - make them smaller for the screenshot
    npcRef.SetScale(0.6)
  elseif originalScale > 1.5
    ; Very large creatures - make them smaller for the screenshot
    npcRef.SetScale(0.45)
    LogMessage("Large NPC detected, scaling down to fit in frame")
  endif
endFunction

; Set detailed status information for an NPC
;
; Parameters:
; * *testName* (string): Original test name (espName/baseId)
; * *status* (string): Test status (ok, error, etc.)
; * *baseId* (int): Base ID without load order
function SetDetailedStatus(string testName, string status, int baseId)
  ; Basic status
  SetTestStatus(testName, status)
  
  ; Extended information using flat structure with dot notation
  ; Store only status and BaseIDHex using the flat structure
  JsonUtil.SetStringValue(JSON_FILE, testName + ".status", status)
  JsonUtil.SetStringValue(JSON_FILE, testName + ".baseidhex", IntToHex(baseId))
  
  ; Save changes
  JsonUtil.Save(JSON_FILE)
  
  LogMessage("Recorded status for " + testName + ": " + status)
  LogMessage("  BaseIDHex: 0x" + IntToHex(baseId))
endFunction

; Centralized logging function
;
; Parameters:
; * *msg* (string): The message to log
function LogMessage(string msg)
  ; Log to Papyrus log (requires enabling in Skyrim.ini)
  Debug.Trace("[" + LOGNAME + "] " + msg)
  
  ; Also write to our custom log file
  string timestamp = Utility.GetCurrentGameTime() + " - "
  string logPath = "Data/SKSE/Plugins/StorageUtilities/AutoTest/"
  MiscUtil.WriteToFile(logPath + LOGNAME + ".log", timestamp + msg + "\n", true)
endFunction

; --- String/Number Conversion Functions ---

; Convert an int to hex string
;
; Parameters:
; * *value* (int): The integer value to convert
;
; Returns:
; * (string): Hexadecimal representation without 0x prefix
string function IntToHex(int value)
  if value == 0
    return "0"
  endif
  
  int tmp = value
  string hexStr = ""
  string hexChars = "0123456789ABCDEF"
  
  while tmp != 0
    int remainder = tmp % 16
    tmp = tmp / 16
    
    ; Extract the corresponding hex character
    hexStr = StringUtil.GetNthChar(hexChars, remainder) + hexStr
  endwhile
  
  return hexStr
endFunction

; Function to convert hex to int
;
; Parameters:
; * *hexString* (string): The hex string to convert (without 0x prefix)
;
; Returns:
; * (int): Decimal value
int function HexToInt(string hexString)
  int result = 0
  int len = StringUtil.GetLength(hexString)
  
  int i = 0
  while (i < len)
    string char = StringUtil.SubString(hexString, i, 1)
    int digit = 0
    
    ; Convert hex character to value
    if (char >= "0" && char <= "9")
      digit = (StringUtil.AsOrd(char) - StringUtil.AsOrd("0"))
    elseif (char >= "A" && char <= "F")
      digit = (StringUtil.AsOrd(char) - StringUtil.AsOrd("A")) + 10
    elseif (char >= "a" && char <= "f")
      digit = (StringUtil.AsOrd(char) - StringUtil.AsOrd("a")) + 10
    endif
    
    result = result * 16 + digit
    i += 1
  endwhile
  
  return result
endFunction