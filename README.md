# APT-SimulActor

> [!CAUTION]
> **Use of APT-SimulActor requires prior authorization from the relevant stakeholders.
> The authors and contributors accept no responsibility for misuse or any damage resulting from unauthorized use.**

APT-SimulActor is an AutoIt library for red team operators and EDR validation engineers. It provides a collection of reusable, [MITRE ATT&CK](https://attack.mitre.org/)–mapped primitives for simulating adversary behaviour on Windows systems, designed to validate detection coverage and test defensive controls in authorised environments.

Functions are grouped by **technical primitive** — the Windows subsystem or mechanism each function touches — rather than by MITRE tactic, since many techniques span multiple tactics. MITRE tactic and technique metadata is captured in each function's inline comment and in the reference tables below.

---

## Prerequisites

- **AutoIt v3** — [download](https://www.autoitscript.com/site/autoit/downloads/)

---

## Usage

Include the entry point at the top of any scenario script. All modules and global variables are loaded automatically.

```autoit
#include "APT-SimulActor.au3"

HandleRelocation()

If IsInternetReachable() Then
   If GetLoginCount(GetCurrentUser()) > 2 Then
      If IsRunningFromDir("C:\WINDOWS\TEMP") Then
         SetRunKeyPersistence()
         DownloadFile($g_sPsToolsUrl, "certutil")
      Else
         MoveAndExec("C:\WINDOWS\TEMP")
      EndIf
   EndIf
EndIf
```

## Function reference

### Core.au3 — generic helpers

| Function | Description | MITRE Tactic | MITRE Technique |
|---|---|---|---|
| `ExecCommand($sCommand)` | Run a shell command hidden and return merged stdout/stderr | — | — |
| `GenerateFilename($sExt)` | Generate a random 8-character alphanumeric filename; default extension `.exe` | — | — |
| `PauseSeconds($iSeconds)` | Block execution for N seconds | — | — |
| `ShowMessage($sText)` | Display a modal message box | — | — |
| `ShowPopup()` | Show a Windows Forms message box via PowerShell | — | — |

---

### Registry.au3 — registry operations

| Function | Description | MITRE Tactic | MITRE Technique |
|---|---|---|---|
| `SetRunKeyPersistence()` | Add the current executable to `HKCU\Software\Microsoft\Windows\CurrentVersion\Run` | Persistence | T1547.001 |
| `SearchRegistry($sQuery)` | Search HKCU for a string via `reg query`; falls back to a full hive export | Credential Access | T1552.002 |

---

### FileSystem.au3 — file and directory operations

| Function | Description | MITRE Tactic | MITRE Technique |
|---|---|---|---|
| `ReadFile($sFilePath)` | Read a file and return its content as a string | Collection | T1005 |
| `LogToFile($sData, $sFilePath)` | Append a data buffer to a file | Collection | T1005 |
| `MutateFileHash($sFilePath)` | Append a byte to a file to alter its hash without affecting execution | Defense Evasion | T1027 |
| `GetDesktopFiles()` | Return a newline-separated list of files on the current user's Desktop | Discovery | T1083 |
| `EnumerateShares()` | Enumerate mapped network drives and read their file contents | Collection | T1039 |
| `FindFiles($sDir, $sPattern)` | Recursively find files matching a pattern; returns `[0]=count, [1..n]=paths` | Discovery | T1083 |
| `SearchFileContent($sDir, $sPattern, $sKeyword)` | Find files matching a pattern whose content contains a given keyword | Collection | T1005 |
| `CaptureScreenshot($sFilePath)` | Capture the full screen to a file | Collection | T1113 |
| `GetBrowserCredentialFiles()` | Locate Chrome, Edge, and Firefox credential store files | Credential Access | T1555.003 |
| `EncryptFiles($sPassword, $sTarget)` | AES-256 encrypt all regular files in a directory or a single file | Impact | T1486 |
| `DecryptFiles($sPassword, $sFolder)` | AES-256 decrypt all `.crypt` files in a directory | Impact | T1486 |
| `Unzip($sSource, $sDestination)` | Extract a zip archive via PowerShell `Expand-Archive` | — | — |

---

### Process.au3 — process spawning, scheduling, and relocation protocol

| Function | Description | MITRE Tactic | MITRE Technique |
|---|---|---|---|
| `HandleRelocation()` | Call at entry point — if launched by `MoveAndExec`/`CopyAndExec`, terminates and optionally deletes the parent instance | Defense Evasion | T1036 |
| `IsRunningFromDir($sFolder)` | Return `True` if the script is currently executing from the specified folder | Defense Evasion | T1036 |
| `MoveAndExec($sDestDir, $sNewName)` | Move the executable to a new location, mutate its hash, re-execute, and delete the original | Defense Evasion | T1036 |
| `CopyAndExec($sDestDir, $sNewName)` | Copy the executable to a new location, mutate its hash, and re-execute while keeping the original | Defense Evasion | T1036 |
| `RunElevated($sPsCommand)` | Run a PowerShell command in an elevated process via UAC prompt | Execution, Privilege Escalation | T1059.001, T1548.002 |
| `ExecViaWMI($sCommand)` | Execute a command via WMI process creation — parent process is WMI, not the calling executable | Execution | T1047 |
| `ExecViaMshta($sUrl)` | Execute a remote HTA script via `mshta.exe` (LOLBin) | Execution | T1218.005 |
| `CreateScheduledTask($sExePath)` | Create a scheduled task that runs the given executable every minute | Persistence | T1053.005 |
| `DeleteScheduledTask($sTaskName)` | Delete a scheduled task by name | Persistence | T1053.005 |
| `AddToStartupFolder($sExePath)` | Copy an executable to the current user's Startup folder | Persistence | T1547.001 |
| `CreateService($sName, $sExePath)` | Create and start a Windows service for persistent execution | Persistence | T1543.003 |
| `Mimikatz()` | Invoke a Mimikatz credential dump via the Empire PowerShell module | Credential Access | T1003.001 |

---

### Network.au3 — network I/O

| Function | Description | MITRE Tactic | MITRE Technique |
|---|---|---|---|
| `IsInternetReachable()` | Return `True` if an external host is reachable via ICMP | Discovery | T1016 |
| `DnsLookup($sAddress)` | Perform a DNS lookup — returns the output string or `0` if the host does not exist | Discovery | T1018 |
| `ScanTcpPort($sIp, $iPort)` | Return `"open"` or `"closed"` for a given TCP endpoint | Discovery | T1046 |
| `ScanSubnet($iPort, $iStartHost, $iStopHost)` | Scan the local /24 subnet for hosts with a given port open; returns `[0]=count, [1..n]=IPs` | Discovery | T1046 |
| `DownloadFile($sUrl, $sMode, $sFilePath)` | Download a file — `$sMode`: `"native"` \| `"curl"` \| `"certutil"` \| `"bits"` | C2 | T1105 |
| `FetchUrl($sUrl)` | Return the raw content of a remote HTTP/S resource | C2 | T1102 |
| `HttpPost($sHost, $sTag, $sPort, $sData)` | HTTP POST data to a remote listener | Exfiltration | T1041 |
| `ReverseShell($sRemoteIp, $iRemotePort)` | Open a PowerShell TCP reverse shell to a remote listener | Execution, C2 | T1059.001, T1095 |

---

### System.au3 — OS enumeration and sandbox detection

| Function | Description | MITRE Tactic | MITRE Technique |
|---|---|---|---|
| `GetCurrentUser()` | Return the current username in uppercase | Discovery | T1033 |
| `IsCurrentUser($sUsername)` | Return `True` if the process is running as the specified user | Discovery | T1033 |
| `GetLoginCount($sUser)` | Return the `NumberOfLogons` value for an account via WMI | Discovery | T1033 |
| `GetLocalAdmins()` | Enumerate members of the local Administrators group | Discovery | T1069.001 |
| `GetDomainAdmins()` | Return members of the Domain Admins group | Discovery | T1069.002 |
| `GetSystemInfo()` | Return full `systeminfo` output | Discovery | T1082 |
| `GetInstalledUpdates()` | List all installed Windows updates via WMI | Discovery | T1082 |
| `GetSharedResources()` | List all shares exposed by the local machine via WMI | Discovery | T1135 |
| `GetRunningProcesses()` | Return full `tasklist` output | Discovery | T1057 |
| `GetDomainInfo()` | Return domain trust relationships via `nltest` | Discovery | T1482 |
| `GetWifiPasswords()` | Return saved Wi-Fi SSIDs and their cleartext keys via `netsh` | Credential Access | T1552.001 |
| `DetectSandboxMouse()` | Return `True` if the mouse moves within 5 seconds; exit if no movement is detected | Defense Evasion | T1497.002 |
| `DetectSandboxSleep()` | Return `True` if `Sleep()` runs at real speed — sandboxes often accelerate time to skip delays | Defense Evasion | T1497.003 |
| `DetectVM()` | Return `True` if VMware, VirtualBox, Hyper-V, or QEMU artefacts are found | Defense Evasion | T1497.001 |
| `ClearEventLogs()` | Clear the System, Security, and Application Windows event logs | Defense Evasion | T1070.001 |

---

### Clipboard.au3 — clipboard monitoring

| Function | Description | MITRE Tactic | MITRE Technique |
|---|---|---|---|
| `ClipboardToLog($iTimeout, $sLogPath)` | Poll the clipboard and append each new value to a local file | Collection | T1115 |
| `ClipboardToWeb($sHost, $sTag, $sPort, $iTimeout)` | Poll the clipboard and POST each new value to a remote listener | Collection, Exfiltration | T1115, T1041 |

---

## Examples

| File | Summary |
|---|---|
| `relocate_persist_download.au3` | Baseline scenario: sandbox checks → relocate to TEMP → set run-key persistence → download PSTools via certutil |
| `recon_and_exfil.au3` | Full recon pass: host and domain enumeration, subnet scan, file hunting, HTTP POST exfiltration |
| `persistence_and_evasion.au3` | Layered persistence: relocate → run key + Startup folder + scheduled task → BITS download |
