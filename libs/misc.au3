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



    ; Open the file for writing (append to the end of a file) and store the handle to a variable.
    Local $hFileOpen = FileOpen($sFilePath, $FO_APPEND)
    If $hFileOpen = -1 Then
        MsgBox($MB_SYSTEMMODAL, "", "An error occurred whilst writing the temporary file.")
        Return False
    EndIf

    FileWrite($hFileOpen, $log & @CRLF)

    ; Close the handle returned by FileOpen.
    FileClose($hFileOpen)
EndFunc