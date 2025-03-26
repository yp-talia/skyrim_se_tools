Scriptname AutoTest_Suite_NPCsHead extends AutoTest_Suite_NPCs
{
  Collection of script functions testing NPCs head (using screenshots of actors).
  This helps in finding issues with neck seams and facial details.
  Dependencies:
  * ConsoleUtil (https://www.nexusmods.com/skyrimspecialedition/mods/24858)
  * SKSE for StringUtil (https://skse.silverlock.org/)
}

; --- Properties ---
; These are inherited from AutoTest_Suite_NPCs

; --- Constants ---
string LOGNAME = "NPCHeadScreenshots"  ; Central log name definition

; --- Head Screenshots Variables ---
float gPreviousFov = 65.0      ; Store original FOV
float gPreviousScale = 1.0     ; Store original player scale
float HEAD_FOCUS_FOV = 20.0    ; Default FOV for head shots (narrower than full body)

; --- API Functions (Required Overrides) ---

; Initialize the script
; [API] This function is mandatory and has to use SetTestType
function InitTests()
  SetTestType("NPCsHead")
  
  ; Ensure log directory exists and is accessible
  string logPath = "Data/SKSE/Plugins/StorageUtilities/AutoTest/"
  MiscUtil.WriteToFile(logPath + LOGNAME + ".log", "=== " + LOGNAME + " Log Started ===\n", false)
  
  LogMessage("Head screenshots log file initialized")
  Debug.Notification(LOGNAME + " log initialized")
endFunction

; Prepare the environment for head screenshot tests
; [API] This function is optional - overrides parent
function BeforeTestsRun()
  ; Store current settings to restore later
  gPreviousFov = Utility.GetINIFloat("fDefault1stPersonFOV:Display")
  gPreviousScale = Game.GetPlayer().GetScale()
  
  ; Enable god mode, disable AI and UI for clean screenshots
  ConsoleUtil.ExecuteCommand("tgm")
  ConsoleUtil.ExecuteCommand("tcai")
  ConsoleUtil.ExecuteCommand("tai")
  ConsoleUtil.ExecuteCommand("fov " + HEAD_FOCUS_FOV)
  ConsoleUtil.ExecuteCommand("sucsm 5") ; Set smooth camera movement speed (higher = faster)
  ConsoleUtil.ExecuteCommand("tm")
endFunction

; Restore environment after tests
; [API] This function is optional - overrides parent
function AfterTestsRun()
  ; Restore original settings
  ConsoleUtil.ExecuteCommand("fov " + gPreviousFov)
  ConsoleUtil.ExecuteCommand("player.setscale " + gPreviousScale)
  ConsoleUtil.ExecuteCommand("sucsm 10") ; Restore default camera speed
  
  ; Re-enable AI and UI, disable god mode
  ConsoleUtil.ExecuteCommand("tai")
  ConsoleUtil.ExecuteCommand("tcai")
  ConsoleUtil.ExecuteCommand("tgm")
  ConsoleUtil.ExecuteCommand("tm")
endFunction

; --- Override Core Screenshot Function ---

; Take a screenshot focusing on NPC's head
; Overrides the parent ScreenshotOf method to focus on head
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
  LogMessage("Taking head screenshot of " + formName + " (0x" + IntToHex(baseId) + ")")
  Debug.Notification("Processing head shot: " + formName)
  
  ; Setup test environment
  Game.DisablePlayerControls()
  
  ; Move player to viewpoint
  Game.GetPlayer().MoveTo(ViewPointAnchor)
  Game.GetPlayer().SetAngle(0.0, 0.0, 0.0) ; Reset rotation
  
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
  Utility.Wait(1.0)
  
  ; Get NPC Scale - we'll use original scale for dialogue camera
  float npcScale = newRef.GetScale()
  
  ; Dialogue camera handles positioning automatically, but we'll
  ; adjust FOV for optimal framing of different sized NPCs
  float playerFOV = AdjustFOVForHeadShot(npcScale)
  ConsoleUtil.ExecuteCommand("fov " + playerFOV)
  
  ; Force first person view
  Game.ForceFirstPerson()
  
  ; Position the NPC to face the player
  newRef.SetAngle(0.0, 0.0, 180.0)
  
  ; --- HEAD FOCUS APPROACH FOR ALL NPC TYPES ---
  ; This approach uses targeted camera positioning that works for all NPC sizes
  
  ; 1. Target the NPC
  ConsoleUtil.ExecuteCommand("prid " + IntToHex(newRef.GetFormID()))
  Utility.Wait(0.1)
  
  ; 2. Use the tfc (toggle free camera) with noclip for precise positioning
  ConsoleUtil.ExecuteCommand("tfc 1") ; Enable free camera with time freeze
  Utility.Wait(0.2)
  
  ; 3. Get NPC position
  float[] npcPos = new float[3]
  npcPos[0] = newRef.GetPositionX()
  npcPos[1] = newRef.GetPositionY()
  npcPos[2] = newRef.GetPositionZ()
  
  ; 4. Calculate head position based on NPC scale and race
  float headHeight = CalculateHeadHeight(newRef)
  LogMessage("NPC " + formName + " calculated head height: " + headHeight)
  
  ; 5. Position camera at optimal distance and height for the head shot
  float cameraDistance = 150.0 * npcScale ; Distance scales with NPC size
  if (cameraDistance < 80.0)
    cameraDistance = 80.0 ; Minimum distance for very small NPCs
  elseif (cameraDistance > 300.0)
    cameraDistance = 300.0 ; Maximum distance for very large NPCs
  endif
  
  ; 6. Position the camera
  float camX = npcPos[0] 
  float camY = npcPos[1] - cameraDistance ; Position camera in front of NPC
  float camZ = npcPos[2] + headHeight ; Position at head height
  
  ; 7. Move free camera to position
  ConsoleUtil.ExecuteCommand("setcamerapos " + camX + " " + camY + " " + camZ)
  Utility.Wait(0.2)
  
  ; 8. Point camera at NPC's head
  ConsoleUtil.ExecuteCommand("setcameratarget " + npcPos[0] + " " + npcPos[1] + " " + (npcPos[2] + headHeight))
  Utility.Wait(0.3)
  
  ; Take the screenshot
  LogMessage("Taking head screenshot now...")
  Input.TapKey(183) ; PrintScreen key
  Utility.Wait(0.2)
  
  ; Record status with baseID
  SetDetailedStatus(testId, "ok", baseId)
  
  ; Clean up free camera
  CleanupFreeCamera()
  
  ; Clean up - delete NPC reference
  newRef.DisableNoWait()
  newRef.Delete()
  
  ; Restore player controls
  Game.EnablePlayerControls()
  
  LogMessage("Head processing complete for " + formName)
endFunction

; --- Helper Functions ---

; Adjust FOV setting based on NPC scale for optimal head framing
;
; Parameters:
; * *scale* (float): The adjusted player scale
;
; Returns:
; * (float): Optimal FOV value for head shot
float function AdjustFOVForHeadShot(float scale)
  float fov = HEAD_FOCUS_FOV ; Default FOV
  
  if scale < 0.5
    fov = 12.0 ; Narrower FOV for very small NPCs
  elseif scale < 0.7
    fov = 15.0 ; For small NPCs
  elseif scale < 1.0
    fov = 20.0 ; For medium NPCs
  elseif scale < 1.5
    fov = 25.0 ; For large NPCs
  else
    fov = 30.0 ; For very large NPCs
  endif
  
  return fov
endFunction

; Calculate head height based on NPC race and scale
;
; Parameters:
; * *npcRef* (ObjectReference): The NPC reference
;
; Returns:
; * (float): Height to the head position in game units
float function CalculateHeadHeight(ObjectReference npcRef)
  Actor npcActor = npcRef as Actor
  
  ; Default base height for NPCs
  float baseHeight = 128.0
  float headRatio = 0.85 ; Head position is roughly at 85% of height for humans
  
  ; Check actor race to determine appropriate head position ratio
  if npcActor
    Race npcRace = npcActor.GetRace()
    string raceName = npcRace.GetName()
    
    ; Adjust head position ratio based on race type 
    if StringUtil.Find(raceName, "Child") >= 0
      ; Child races - head is proportionally higher
      headRatio = 0.75
      baseHeight = 96.0
    elseif StringUtil.Find(raceName, "Giant") >= 0
      ; Giants - head is proportionally smaller
      headRatio = 0.90
      baseHeight = 350.0
    elseif StringUtil.Find(raceName, "Spider") >= 0 || StringUtil.Find(raceName, "Insect") >= 0
      ; Spiders/Insects - head is at front, not top
      headRatio = 0.5 
      baseHeight = 70.0
    elseif StringUtil.Find(raceName, "Dragon") >= 0
      ; Dragons - head is at front
      headRatio = 0.7
      baseHeight = 180.0
    elseif StringUtil.Find(raceName, "Wolf") >= 0 || StringUtil.Find(raceName, "Dog") >= 0 || StringUtil.Find(raceName, "Sabre Cat") >= 0
      ; Four-legged creatures - head is at front, not top
      headRatio = 0.6
      baseHeight = 90.0
    elseif StringUtil.Find(raceName, "Falmer") >= 0
      ; Hunched races
      headRatio = 0.75
      baseHeight = 120.0
    endif
  endif

  ; Scale based on NPC's scale value and get final head height
  float totalHeight = baseHeight * npcRef.GetScale()
  return totalHeight * headRatio
endFunction

; Clean up free camera
;
; Should be called after taking the screenshot
function CleanupFreeCamera()
  ; Disable free camera and return to normal view
  ConsoleUtil.ExecuteCommand("tfc 0")
  Utility.Wait(0.1)
  
  ; Force back to first person
  Game.ForceFirstPerson()
endFunction

; Override the LogMessage function to use our head-specific log name
function LogMessage(string msg)
  ; Log to Papyrus log
  Debug.Trace("[" + LOGNAME + "] " + msg)
  
  ; Also write to our custom log file
  string timestamp = Utility.GetCurrentGameTime() + " - "
  string logPath = "Data/SKSE/Plugins/StorageUtilities/AutoTest/"
  MiscUtil.WriteToFile(logPath + LOGNAME + ".log", timestamp + msg + "\n", true)
endFunction