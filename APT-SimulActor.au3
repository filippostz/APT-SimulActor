;DISCLAIMER: The APT-SimulActor use requires authorization from proper stakeholders. Author and Contributors will not be responsible for the malfunctioning or weaponization of the tool.

#NoTrayIcon

#include <Inet.au3>
#include <MsgBoxConstants.au3>
#include <FileConstants.au3>
#include <WinAPIFiles.au3>
#include <File.au3>
#include <AutoItConstants.au3>
#include <Crypt.au3>
#include <ScreenCapture.au3>

#include "modules\Core.au3"
#include "modules\Registry.au3"
#include "modules\FileSystem.au3"
#include "modules\Process.au3"
#include "modules\Network.au3"
#include "modules\System.au3"
#include "modules\Clipboard.au3"

Global $g_sPsToolsUrl = "https://download.sysinternals.com/files/PSTools.zip"
Global $g_s7ZipUrl    = "https://www.7-zip.org/a/7za920.zip"
