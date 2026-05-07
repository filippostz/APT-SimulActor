#include "..\APT-SimulActor.au3"

; CAUTION: The APT-SimulActor use requires authorization from proper stakeholders.
; Author and Contributors will not be responsible for the malfunctioning or weaponization of the tool.

; Smoke test suite for APT-SimulActor.
;
; Run from the tests\ directory:
;   AutoIt3.exe /AutoIt3ExecuteScript smoke.au3
;
; Exit code 0 = all passed, 1 = one or more failures.
; Results are written to tests\smoke_results.log.
;
; Scope: pure functions and read-only OS calls only.
; Destructive functions (EncryptFiles, ClearEventLogs, SetRunKeyPersistence,
; MoveAndExec, ReverseShell, etc.) are not exercised here — test those
; manually in a dedicated snapshot VM.

Local $sLogPath = @ScriptDir & "\smoke_results.log"
Local $iPass    = 0
Local $iFail    = 0

FileDelete($sLogPath)
FileWriteLine($sLogPath, "APT-SimulActor smoke test  " & _NowCalc() & @CRLF)

; ── Helper ─────────────────────────────────────────────────────────────────────

Func _Assert($sName, $bResult)
    Local $sLine
    If $bResult Then
        $iPass += 1
        $sLine = "[PASS] " & $sName
    Else
        $iFail += 1
        $sLine = "[FAIL] " & $sName
    EndIf
    ConsoleWrite($sLine & @LF)
    FileWriteLine($sLogPath, $sLine)
EndFunc

; ── Core ───────────────────────────────────────────────────────────────────────

ConsoleWrite("--- Core" & @LF)
FileWriteLine($sLogPath, "--- Core")

Local $sName1 = GenerateFilename(".exe")
Local $sName2 = GenerateFilename(".dll")
_Assert("GenerateFilename: length is 12",           StringLen($sName1) = 12)
_Assert("GenerateFilename: .exe extension",         StringRight($sName1, 4) = ".exe")
_Assert("GenerateFilename: .dll extension",         StringRight($sName2, 4) = ".dll")
_Assert("GenerateFilename: names differ each call", $sName1 <> GenerateFilename(".exe"))

Local $sCmd = ExecCommand("cmd /c echo apttest")
_Assert("ExecCommand: returns output",              StringInStr($sCmd, "apttest"))

; ── Process ────────────────────────────────────────────────────────────────────

ConsoleWrite("--- Process" & @LF)
FileWriteLine($sLogPath, "--- Process")

_Assert("IsRunningFromDir: matches @ScriptDir",     IsRunningFromDir(@ScriptDir))
_Assert("IsRunningFromDir: rejects wrong dir",      Not IsRunningFromDir("C:\NonExistentDir_APT12345"))

; ── FileSystem ─────────────────────────────────────────────────────────────────

ConsoleWrite("--- FileSystem" & @LF)
FileWriteLine($sLogPath, "--- FileSystem")

Local $sTmp = @TempDir & "\aptsmoke_" & @AutoItPID
DirCreate($sTmp)

FileWriteLine($sTmp & "\alpha.txt",   "password=hunter2")
FileWriteLine($sTmp & "\beta.txt",    "nothing interesting here")
FileWriteLine($sTmp & "\gamma.docx",  "document content")

_Assert("ReadFile: returns content",                StringInStr(ReadFile($sTmp & "\alpha.txt"), "hunter2"))
_Assert("ReadFile: missing file returns empty",     ReadFile($sTmp & "\missing.txt") = "")

Local $aAll = FindFiles($sTmp, "*.txt")
_Assert("FindFiles: returns array",                 IsArray($aAll))
_Assert("FindFiles: count is 2",                    IsArray($aAll) And $aAll[0] = 2)

Local $aNone = FindFiles($sTmp, "*.xyz")
_Assert("FindFiles: no match returns False",        $aNone = False)

Local $aHit = SearchFileContent($sTmp, "*.txt", "password")
_Assert("SearchFileContent: finds keyword",         IsArray($aHit) And $aHit[0] = 1)
_Assert("SearchFileContent: result is alpha.txt",   IsArray($aHit) And StringInStr($aHit[1], "alpha.txt"))

Local $aMiss = SearchFileContent($sTmp, "*.txt", "zzznomatch")
_Assert("SearchFileContent: no match returns False",$aMiss = False)

Local $aDocx = FindFiles($sTmp, "*.docx")
_Assert("FindFiles: finds docx",                    IsArray($aDocx) And $aDocx[0] = 1)

LogToFile("appended line", $sTmp & "\logtest.txt")
_Assert("LogToFile: file created",                  FileExists($sTmp & "\logtest.txt"))
_Assert("LogToFile: content written",               StringInStr(ReadFile($sTmp & "\logtest.txt"), "appended line"))

Local $sDesktop = GetDesktopFiles()
_Assert("GetDesktopFiles: returns string",          IsString($sDesktop))

DirRemove($sTmp, 1)

; ── System ─────────────────────────────────────────────────────────────────────

ConsoleWrite("--- System" & @LF)
FileWriteLine($sLogPath, "--- System")

Local $sUser = GetCurrentUser()
_Assert("GetCurrentUser: not empty",                $sUser <> "")
_Assert("GetCurrentUser: uppercase",                $sUser = StringUpper($sUser))

_Assert("IsCurrentUser: matches self",              IsCurrentUser($sUser))
_Assert("IsCurrentUser: rejects other",             Not IsCurrentUser("__no_such_user__"))

Local $iLogins = GetLoginCount($sUser)
_Assert("GetLoginCount: returns number >= 0",       IsInt($iLogins) And $iLogins >= 0)

Local $sSysInfo = GetSystemInfo()
_Assert("GetSystemInfo: not empty",                 StringLen($sSysInfo) > 10)
_Assert("GetSystemInfo: contains Host Name",        StringInStr($sSysInfo, "Host Name"))

Local $sProcs = GetRunningProcesses()
_Assert("GetRunningProcesses: not empty",           StringLen($sProcs) > 0)
_Assert("GetRunningProcesses: contains svchost",    StringInStr(StringLower($sProcs), "svchost"))

Local $sAdmins = GetLocalAdmins()
_Assert("GetLocalAdmins: not empty",                StringLen($sAdmins) > 0)

Local $sShares = GetSharedResources()
_Assert("GetSharedResources: returns string",       IsString($sShares))

_Assert("DetectSandboxSleep: Sleep runs at speed",  DetectSandboxSleep())

; ── Network ────────────────────────────────────────────────────────────────────

ConsoleWrite("--- Network" & @LF)
FileWriteLine($sLogPath, "--- Network")

Local $sBadDns = DnsLookup("this.domain.does.not.exist.invalid")
_Assert("DnsLookup: non-existent returns 0",        $sBadDns = 0)

; Port scan against loopback — does not generate external traffic
Local $sLoopback = ScanTcpPort("127.0.0.1", 80)
_Assert("ScanTcpPort: returns open or closed",      $sLoopback = "open" Or $sLoopback = "closed")

; ── Summary ────────────────────────────────────────────────────────────────────

Local $sSummary = @CRLF & "Results: " & $iPass & " passed, " & $iFail & " failed"
ConsoleWrite($sSummary & @LF)
FileWriteLine($sLogPath, $sSummary)
ConsoleWrite("Log: " & $sLogPath & @LF)

If $iFail > 0 Then Exit 1
