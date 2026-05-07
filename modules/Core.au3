#include-once

; Core utilities: error handling, generic helpers

Global $g_oErrorHandler = ObjEvent("AutoIt.Error", "_OnComError")

Func _OnComError()
   Local $sHex = Hex($g_oErrorHandler.number, 8)
   Return SetError(1, 0, $sHex)
EndFunc

Func PauseSeconds($iSeconds) ;DESCRIPTION:Block execution for N seconds;MITRE:-
   Sleep($iSeconds * 1000)
   Return 1
EndFunc

Func ShowMessage($sText) ;DESCRIPTION:Display a modal message box;MITRE:-
   MsgBox($MB_SYSTEMMODAL, StringSplit(@ScriptName, ".")[1], $sText)
EndFunc

Func ShowPopup() ;DESCRIPTION:Show a Windows Forms popup via PowerShell;MITRE:-
   Local $sPsCmd = "[Reflection.Assembly]::LoadWithPartialName('''System.Windows.Forms''');[Windows.Forms.MessageBox]::show('''Hello World''', '''My PopUp Message Box''')"
   RunWait("C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -windowstyle hidden -nop -exec bypass -c " & $sPsCmd)
EndFunc

Func GenerateFilename($sExt = ".exe") ;DESCRIPTION:Generate a random 8-char alphanumeric filename;MITRE:-
   Local $sResult = ""
   Local $aPool[3]
   For $i = 1 To 8
      $aPool[0] = Chr(Random(65, 90, 1))   ; A-Z
      $aPool[1] = Chr(Random(97, 122, 1))  ; a-z
      $aPool[2] = Chr(Random(48, 57, 1))   ; 0-9
      $sResult &= $aPool[Random(0, 2, 1)]
   Next
   Return $sResult & $sExt
EndFunc

Func ExecCommand($sCommand) ;DESCRIPTION:Run a shell command hidden and return merged stdout/stderr;MITRE:-
   Local $sOutput = ""
   Local $hPid = Run($sCommand, "", @SW_HIDE, $STDERR_MERGED)
   Do
      Sleep(100)
      $sOutput &= StdoutRead($hPid)
   Until @error
   Return $sOutput
EndFunc
