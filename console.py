import os
import urllib.request
import ssl
from cmd import Cmd

ssl._create_default_https_context = ssl._create_unverified_context

url='https://raw.githubusercontent.com/filippostz/APT-SimulActor/master/APT-SimulActor.au3'
APT_SimulActor_path='APT-SimulActor.au3'

def getFunctions(filename = APT_SimulActor_path):
    with open(filename, 'r') as filehandle:
        for line in filehandle:
            if "Func " in line:
                try:
                    print("-"*100)
                    text = line.split("Func ")[1]
                    function = text.split(";DESCRIPTION:")[0]
                    description = text.split(";DESCRIPTION:")[1]
                    print(function)
                    print(description)
                except:
                    pass

def checkInstallation():
    if not os.path.isfile(APT_SimulActor_path):
        return 0
    else:
        return 1

def update():
    print("Download...")
    urllib.request.urlretrieve(url, APT_SimulActor_path)

class console(Cmd):
    prompt = 'ATPsimulActor>'
    intro = "\nType ? to list commands\n"

    def do_functions(self, inp):
        getFunctions()

    def do_update(self, inp):
        update()

    def do_exit(self, inp):
        return True

console().cmdloop()
