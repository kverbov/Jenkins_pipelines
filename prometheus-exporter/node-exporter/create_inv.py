import sys

hosts = sys.argv[1]
invFile = sys.argv[2]

hosts = hosts.replace(' ', '')

setFile = open(invFile, 'w+')
setFile.write("[hosts]\n")
if hosts.find(';') > 0:
    hostlist = hosts.split(';')
    for i in hostlist:
        setFile.write(i + "        ansible_connection=ssh\n")
else:
    setFile.write(hosts + "        ansible_connection=ssh\n")
setFile.close()
