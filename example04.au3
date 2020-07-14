#include "libs/settings.au3"
#include "libs/network.au3"
#include "libs/info.au3"
#include "libs/misc.au3"

if InternetCheck()	Then

   if DetectMouseMoving() Then

	  If numberOfLogins(whoami()) > 15 Then

		 MessageBox("Debug","Not a Sandbox!")

	  EndIf

   EndIf

EndIf
