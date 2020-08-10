import os
import urllib.request
import ssl
from cmd import Cmd

ssl._create_default_https_context = ssl._create_unverified_context

DISCLAIMER="The APT-SimulActor use requires authorization from proper stakeholders.\nAuthor and Contributors will not be responsible for the malfunctioning or weaponization of the tool."

url='https://raw.githubusercontent.com/filippostz/APT-SimulActor/master/APT-SimulActor.au3'
Aut2exe = '"C:\\Program Files (x86)\\AutoIt3\\Aut2Exe\\Aut2exe.exe"'
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
    intro = DISCLAIMER + "\n\nType ? to list commands\n"

    def do_functions(self, inp):
        getFunctions()

    def do_template(self, inp):
        with open('sample.au3', 'w') as fp:
            fp.write("#include '" + APT_SimulActor_path + "'\n")
            fp.write("init()" + "\n")

    def do_compile(self, inp):
        #https://www.autoitscript.com/autoit3/docs/intro/compiler.htm
        #Aut2exe.exe / In < infile.au3 >[/out < outfile.exe >][/icon < iconfile.ico >][/comp 0 - 4][/nopack][/x64][/bin < binfile.bin >]
        os.system(Aut2exe + " /in " + "sample.au3 ")

    def do_update(self, inp):
        update()

    def do_exit(self, inp):
        return True

console().cmdloop()
