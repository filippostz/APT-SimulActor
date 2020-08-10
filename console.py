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
                    #print("-"*100)
                    text = line.split("Func ")[1]
                    function = text.split(";DESCRIPTION:")[0]
                    description = text.split(";DESCRIPTION:")[1]
                    print(function)
                    #print(description)
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

    def do_functions(self, arg):
        getFunctions()

    def do_project(self, arg):
        args = arg.split()
        projects = os.listdir()
        if len(args) < 2:
            print("Invalid number of arguments")
            return
        else:
            project_name = args[0]
            action_type = args[1]
            if action_type == 'new':
                with open(project_name + '.au3', 'w') as fp:
                    fp.write("#include '" + APT_SimulActor_path + "'\n")
                    fp.write("init()" + "\n")
                    return None
            if project_name + ".au3" in projects:
                if action_type == 'add':
                    module = args[2]
                    with open(project_name + '.au3', 'a') as fp:
                        fp.write(module + "\n")
                if action_type == 'compile':
                    os.system(Aut2exe + " /in " + project_name + '.au3')

    def do_update(self, arg):
        update()

    def do_exit(self, arg):
        return True

if __name__ == '__main__':
    console().cmdloop()
