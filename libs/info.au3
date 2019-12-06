#include <AutoItConstants.au3>

;enumerated administrative users
Func administrators()
   return function_wrapper("net localgroup administrators")
EndFunc

;get sys info
Func systeminfo()
   return function_wrapper("systeminfo")
EndFunc

;list of all installed Windows and software updates applied to that computer
Func updates_installed()
   return function_wrapper("wmic qfe list full")
EndFunc

;get a list of shared resources
Func shared()
   Return function_wrapper("wmic share get")
EndFunc

;who am I?
Func whoami()
   $sReturn = function_wrapper("whoami")
   Return StringSplit(StringRegExpReplace(StringUpper($sReturn), '\n|\r', ''),"\")[2];
EndFunc

;Am I username?
Func AmIusername($username)
   $sReturn = function_wrapper("whoami")
   $current_user = StringSplit(StringRegExpReplace(StringUpper($sReturn), '\n|\r', ''),"\")[2];
   if StringLower($current_user) == StringLower($username) Then
	  Return 1
   Else
	  Return 0
   EndIf

EndFunc

Func function_wrapper($command)
   Local $sOutput = ""
   Local $hPid = Run($command, '', @SW_HIDE, $STDERR_MERGED)
   Do
	   Sleep(100)
	   $sOutput &= StdoutRead($hPid)
   Until @error
   ;$sOutput = StringStripWS($sOutput, $STR_STRIPALL) ; remove all @cr and spaces from output
   Return $sOutput
EndFunc



