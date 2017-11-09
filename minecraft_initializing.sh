#!/bin/bash
#
# XenoPanel Installer
# Last Synced:
#
# We recommend you leave this file alone UNLESS you have experiance with Linux.
# 
# ** WARNING ** 
# When you sync/update the machines XenoPanel version from within the panel it will re-create this file.
#
server_id="$1"
server_directory="$2"
server_ip="$3"
server_port="$4"
server_slots="$5"
server_memory="$6"
server_jar="$7"
#
default_jar="https://xenopanel.com/api/server_defaults/minecraft_server.jar"
default_properties="https://xenopanel.com/api/server_defaults/server.properties"
#
# Deletect either apt-get or yum.
#
if [[ ! -z 'which yum' ]]; then
    packman="yum"
fi
#
if [[ ! -z 'which apt-get' ]]; then
    packman="apt-get"
fi
#
# Kill screen if already running
#
printf "Killing screen $server_id if found... "
if screen -list | grep -q "$server_id"; then
    /usr/bin/screen -X -S $server_id quit; &> /dev/null
fi
if [ $? -eq 0 ]; then
    echo -e "\E[32m\033[1m[DONE]\033[0m"
else
    echo -e "\E[31m\033[1m[ERROR]\033[0m"
    exit
fi
#
# Delete .sh scripts
# TO-DO: Remove when TO-DO below has been completed.
#
cd $server_directory
printf "Removing SH scripts... "
find . -name '*.sh' -type f -delete &> /dev/null
if [ $? -eq 0 ]; then
    echo -e "\E[32m\033[1m[DONE]\033[0m"
else
    echo -e "\E[31m\033[1m[ERROR]\033[0m"
    exit
fi
#
# Prevent Memory Manipulation & Abuse
# TO-DO: Create a default boot script to allow restart on crash ONLY with the unique script.
#
printf "Removing Memory Manipulation methods (1/2)... "
if [[ -f $server_directory/spigot.yml ]]; then 
    sed -i 's/restart-on-crash:.*/restart-on-crash: false/g' spigot.yml &> /dev/null
fi
if [ $? -eq 0 ]; then
    echo -e "\E[32m\033[1m[OK]\033[0m"
else
    echo -e "\E[31m\033[1m[ERROR]\033[0m"
    exit
fi
#
printf "Removing Memory Manipulation methods (2/2)... "
if [[ -f $server_directory/spigot.yml ]]; then 
    sed -i 's/restart-script:.*/restart-script:/g' spigot.yml &> /dev/null
fi
if [ $? -eq 0 ]; then
    echo -e "\E[32m\033[1m[OK]\033[0m"
else
    echo -e "\E[31m\033[1m[ERROR]\033[0m"
    exit
fi
#
# Download default Minecraft if JAR is not found
#
printf "Checking if the Default JAR is needed... "
if [ ! -f $server_directory/minecraft_server.jar ]; then 
    wget –q -np -nd -N -q -P $server_directory $default_jar &> /dev/null
fi
if [ $? -eq 0 ]; then
    echo -e "\E[32m\033[1m[DONE]\033[0m"
else
    echo -e "\E[31m\033[1m[DOWNLOADED]\033[0m"
fi
#
# Download default Minecraft Server Properties if not found
printf "Checking if the Default Properties is needed... "
if [ ! -f $server_directory/server.properties ]; then 
    wget –q -np -nd -N -q $default_properties &> /dev/null
fi
if [ $? -eq 0 ]; then
    echo -e "\E[32m\033[1m[DOWNLOADED]\033[0m"
else
    echo -e "\E[31m\033[1m[DOWNLOADED]\033[0m"
fi
#
# Correct the server properties to ensure no server hopping & slot switching
#
printf "Updating server properties... "
sed -i 's/%IP%.*/'"$server_ip"'/' *properties &> /dev/null
sed -i 's/%PORT%.*/'"$server_port"'/' *properties &> /dev/null
sed -i 's/%SLOTS%.*/'"$server_slots"'/' *properties &> /dev/null
sed -i 's/server-ip=.*/'"server-ip=$server_ip"'/' *properties &> /dev/null
sed -i 's/enable-query=.*/enable-query=true/g' *properties &> /dev/null
sed -i 's/server-port=.*/'"server-port=$server_port"'/' *properties &> /dev/null
sed -i 's/max-players=.*/'"max-players=$server_slots"'/' *properties &> /dev/null
if [ $? -eq 0 ]; then
    echo -e "\E[32m\033[1m[DONE]\033[0m"
else
    echo -e "\E[31m\033[1m[ERROR]\033[0m"
    exit
fi
#
# Done!
#
printf "Done!"
# 
# Exit and start the server!
#
exit
