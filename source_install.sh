#!/bin/bash
#
#
game_id="$1"
server_id="$2"
server_short="$3"
server_username="$4"
server_base="$5"
server_directory="$server_base/$server_id/steamcmd"
server_install="+login anonymous +force_install_dir $server_base/$server_id +app_update $game_id validate +quit"
#
#
echo "{SOURCE_INSTALLER_START}"
printf "\n"
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
# Install Figlet ready to use!
#
if [ "$packman" == "apt-get" ]; then
    apt-get install -y figlet &> /dev/null
    figlet 'XP2 Installer' -f standard
fi

if [ "$packman" == "yum" ]; then
    yum install -y figlet &> /dev/null
    figlet 'XP2 Installer' -f standard
fi
#
# Starting Message
#
printf "\n"
printf "Welcome to the XenoPanel2 Source Game installer!\n" 
printf "We are now downloading SteamCMD and installing your selected game. This may take a while...\n"
printf "\n"
printf "Game Downloading: $server_short"
printf "\n\n"
sleep 1
#
# Install dependancies
#
printf "Checking and installing dependencies... "
if [ "$packman" == "apt-get" ]; then
    apt-get install -y wget tar lib32gcc1 &> /dev/null
fi

if [ "$packman" == "yum" ]; then
    yum install -y wget tar glibc.i686 libstdc++.i686 &> /dev/null
fi
#
# Check if installed
#
if [ $? -eq 0 ]; then
    echo -e "\E[32m\033[1m[DONE]\033[0m"
else
    echo -e "\E[31m\033[1m[ERROR]\033[0m"
    exit
fi
#
# Download SteamCMD
#
printf "Downloading SteamCMD files... "
cd /tmp &> /dev/null
curl -sSL -o steamcmd.tar.gz http://media.steampowered.com/installer/steamcmd_linux.tar.gz &> /dev/null
mkdir -p $server_directory &> /dev/null
tar -xzvf steamcmd.tar.gz -C $server_directory/ &> /dev/null
cd $server_directory &> /dev/null
if [ $? -eq 0 ]; then
    echo -e "\E[32m\033[1m[DONE]\033[0m"
else
    echo -e "\E[31m\033[1m[ERROR]\033[0m"
    exit
fi
#
# Run SteamCMD
#
printf "Running SteamCMD and installing your game file... "
chown -R $server_username:panel $server_base &> /dev/null
cd $server_directory &> /dev/null
./steamcmd.sh $server_install &> /dev/null
if [ $? -eq 0 ]; then
    echo -e "\E[32m\033[1m[DONE]\033[0m"
else
    echo -e "\E[31m\033[1m[ERROR]\033[0m"
    exit
fi
#
# Copy final files
#
printf "Copying final files for future updating... "
chown -R $server_username:panel $server_base &> /dev/null
mkdir -p $server_full/.steam/sdk32 &> /dev/null
cp -v linux32/steamclient.so $server_full/.steam/sdk32/steamclient.so &> /dev/null
if [ $? -eq 0 ]; then
    echo -e "\E[32m\033[1m[DONE]\033[0m"
else
    echo -e "\E[31m\033[1m[ERROR]\033[0m"
    exit
fi
#
chown -R $server_username:panel $server_base &> /dev/null
figlet 'Install Complete' -f standard
#
echo -e ""
#
printf "\n"
echo "{SOURCE_INSTALLER_END}"
#
exit
