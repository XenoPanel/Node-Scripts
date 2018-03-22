#!/bin/bash
#
# XenoPanel Source Installer
# Last Synced: 10/02/2018
#
# We recommend you leave this file alone UNLESS you have experiance with Linux & SteamCMD.
# 
# ** WARNING ** 
# When you sync/update the machines XenoPanel version from within the panel it will re-create this file.
#
game_id="$1"
server_id="$2"
server_short="$3"
server_username="$4"
login_username="$5"
login_password="$6"
#
server_base="/home/XenoPanel/servers/$server_username"
server_main="/home/XenoPanel/servers/$server_username/$server_id"
server_directory="/home/XenoPanel/servers/$server_username/$server_id/steamcmd"
#
server_install="+login $login_username $login_password +force_install_dir $server_base/$server_id +app_update $game_id validate +quit"
#
#
echo "{INSTALLER_START}"
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
# Starting Message
#
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
    apt-get install -y wget tar lib32gcc1 libgcc_s.so.1 libstdc++.i686 lib32tinfo5 ncurses-libs.i68 gdb hashdeep &> /dev/null
fi

if [ "$packman" == "yum" ]; then
    yum install -y wget tar lib32gcc1 glibc.i686 libstdc++.i686 libgcc_s.so.1 lib32tinfo5 ncurses-libs.i68 gbp hashdeep &> /dev/null
fi
#
# Check if installed
#
if [ $? -eq 0 ]; then
    echo -e "[DONE]"
else
    echo -e "[ERROR]"
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
    echo -e "[DONE]"
else
    echo -e "[ERROR]"
    exit
fi
#
# Run SteamCMD
#
printf "Running SteamCMD and installing your game files... "
chown -R $server_username:panel $server_base &> /dev/null
cd $server_directory &> /dev/null
./steamcmd.sh $server_install &> /dev/null
if [ $? -eq 0 ]; then
    echo -e "[DONE]"
else
    echo -e "[ERROR]"
    exit
fi
#
# Copy final files
#
printf "Copying final files for future updating... "
chown -R $server_username:panel $server_base &> /dev/null
mkdir -p .steam/sdk32 &> /dev/null
cp -v linux32/steamclient.so .steam/sdk32/steamclient.so &> /dev/null
if [ $? -eq 0 ]; then
    echo -e "[DONE]"
else
    echo -e "[ERROR]"
    exit
fi
#
# Running intergrity stamp
#
printf "Storing intergity details... "
mkdir -p /home/XenoPanel/integrity
hashdeep -r $server_directory > /home/XenoPanel/integrity/$server_id_steamcmd
hashdeep $server_main/srcds_run > /home/XenoPanel/integrity/$server_id_boot
#
chown -R $server_username:panel $server_base &> /dev/null
#
echo -e ""
echo "Install Complete! \n You may now start your server..."
echo "You can configure the game by using the 'Configure' button in the controls bar."
#
echo "{INSTALLER_END}"
#
exit
