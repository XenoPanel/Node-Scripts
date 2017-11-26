#!/bin/bash
#
#
game_id="$1"
server_id="$2"
server_short="$3"
server_username="$4"
login_username="$5"
#
server_base="/home/XenoPanel/$server_username"
server_directory="/home/XenoPanel/$server_username/$server_id/steamcmd"
#
server_install="+login $login_username +force_install_dir $server_base/$server_id +app_update $game_id validate +quit"
#
#
echo "{SOURCE_INSTALLER_START}"
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
    apt-get install -y wget tar lib32gcc1 libgcc_s.so.1 gdb &> /dev/null
fi

if [ "$packman" == "yum" ]; then
    yum install -y wget tar glibc.i686 libstdc++.i686 libgcc_s.so.1 gbp &> /dev/null
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
mkdir -p $server_full/.steam/sdk32 &> /dev/null
cp -v linux32/steamclient.so $server_full/.steam/sdk32/steamclient.so &> /dev/null
if [ $? -eq 0 ]; then
    echo -e "[DONE]"
else
    echo -e "[ERROR]"
    exit
fi
#
chown -R $server_username:panel $server_base &> /dev/null
#
echo -e ""
echo "Install Complete! \n You may now start your server..."
echo "You can configure the game by using the 'Configure' button in the controls bar."
#
echo "{SOURCE_INSTALLER_END}"
#
exit
