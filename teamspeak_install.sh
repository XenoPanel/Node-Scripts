#!/bin/bash
#
# XenoPanel Teamspeak Installer
# Last Synced:
#
# We recommend you leave this file alone UNLESS you have experiance with Linux.
# 
# ** WARNING ** 
# When you sync/update the machines XenoPanel version from within the panel it will re-create this file.
#
bold=`tput bold`
info=`tput setaf 3`
normal=`tput sgr0`
#
installs_dir="/home/XenoPanel/teamspeak"
#
server_id="$1"
ip_address="$2"
machine_id="$3"
#
voice_port="$4"
file_port="$5"
query_port="$6"
#
panel_ip="$7"
#
architecture=$(uname -m)
#
server_dir=${server_id}
server_name=teamspeak-${server_id}
monitor_name=monitor-${server_id}
#
voice_ip=${ip_address}
file_ip=${ip_address}
query_ip=${ip_address}
#
# Function to display download progress bar @ wget and hide everything else
#
wget_filter ()
{
    local flag=false c count cr=$'\r' nl=$''
    while IFS='' read -d '' -rn 1 c
    do
        if $flag
        then
            printf '%c' "$c"
        else
            if [[ $c != $cr && $c != $nl ]]
            then
                count=0
            else
                ((count++))
                if ((count > 1))
                then
                    flag=true
                fi
            fi
        fi
    done
}
#
echo "{INSTALLER_START}"
printf "Welcome to the XenoPanel2 Voice installer!\n" 
printf "We are now downloading Teamspeak! This may take a while...\n"
printf "\n"
printf "Service Downloading: Teamspeak 3"
printf "\n\n"
#  
# Go to the TeamSpeak directory
#
cd ${installs_dir}
#
if id -u teamspeak &> /dev/null; then
	printf "${bold}Service account already exists${normal}"
else
	# Create TS3 user account
	printf "${bold}Creating Service account)${normal}"
	useradd -d ${installs_dir} -m teamspeak
fi
echo " [DONE]"
#
# Download, unpack, and install the TeamSpeak application
#
if [[ ${architecture} == "x86_64" ]]; then
	# You're running 64-bit
	printf "${bold}Downloading latest 64-bit version of TeamSpeak 3${normal}"
	wget --tries=5 --progress=bar:force http://dl.4players.de/ts/releases/3.0.13.8/teamspeak3-server_linux_amd64-3.0.13.8.tar.bz2 -O teamspeak3-64.tar.bz2 2>&1 | wget_filter
	tar xjf teamspeak3-64.tar.bz2
	rm -f teamspeak3-64.tar.bz2
	mv teamspeak3-server_linux_amd64/* ${server_dir}
	cd ${server_dir}
	chmod +x ts3server_startscript.sh
else 
	# You're running 32-bit
	printf "${bold}Downloading latest 32-bit version of TeamSpeak 3${normal}"
	wget --tries=5 --progress=bar:force http://dl.4players.de/ts/releases/3.0.13.8/teamspeak3-server_linux_x86-3.0.13.8.tar.bz2 -O teamspeak3-32.tar.bz2 2>&1 | wget_filter
	tar xjf teamspeak3-32.tar.bz2
	rm -f teamspeak3-32.tar.bz2
	mv teamspeak3-server_linux_x86/* ${server_dir}
	cd ${server_dir}
	chmod +x ts3server_startscript.sh
fi
printf "${bold}Generating TeamSpeak 3 config file @ ${server_dir}/server.ini${normal}"
#
# Create the default ini file
#
echo "machine_id=
default_voice_port=
voice_ip=0.0.0.0
licensepath=
filetransfer_port=
filetransfer_ip=0.0.0.0
query_port=
query_ip=0.0.0.0
query_ip_whitelist=query_ip_whitelist.txt
query_ip_blacklist=query_ip_blacklist.txt
dbplugin=ts3db_sqlite3
dbpluginparameter=
dbsqlpath=sql/
dbsqlcreatepath=create_sqlite/
dbconnections=10
logpath=logs
logquerycommands=0
dbclientkeepdays=30
logappend=1
query_skipbruteforcecheck=0" >> ${installs_dir}/${server_dir}/server.ini
echo " [DONE]"
#
# Setup server.ini configuration
#
touch ${installs_dir}/${server_dir}/query_ip_whitelist.txt

echo $panel_ip >> ${installs_dir}/${server_dir}/query_ip_whitelist.txt

sed -i -e "s|machine_id=|machine_id=$machine_id|g" ${installs_dir}/${server_dir}/server.ini
sed -i -e "s|licensepath=|licensepath=/home/XenoPanel/teamspeak/|g" ${installs_dir}/${server_dir}/server.ini
sed -i -e "s|voice_ip=0.0.0.0|voice_ip=$voice_ip|g" ${installs_dir}/${server_dir}/server.ini
sed -i -e "s|filetransfer_ip=0.0.0.0|filetransfer_ip=$file_ip|g" ${installs_dir}/${server_dir}/server.ini
sed -i -e "s|query_ip=0.0.0.0|query_ip=$query_ip|g" ${installs_dir}/${server_dir}/server.ini
sed -i -e "s|default_voice_port=|default_voice_port=$voice_port|g" ${installs_dir}/${server_dir}/server.ini
#
sed -i 's|COMMANDLINE_PARAMETERS="${2}"|COMMANDLINE_PARAMETERS="${2} inifile=server.ini"|g' ${installs_dir}/${server_dir}/ts3server_startscript.sh
sed -i 's|${COMMANDLINE_PARAMETERS} > /dev/null|${COMMANDLINE_PARAMETERS} >> logs/console.log|g' ${installs_dir}/${server_dir}/ts3server_startscript.sh
#sed -i 's|echo "TeamSpeak 3 server started, for details please view the log file"|exit|g' ${installs_dir}/${server_dir}/ts3server_startscript.sh
#
sed -i 's/query_port=.*/'"query_port=$query_port"'/' ${installs_dir}/${server_dir}/server.ini
sed -i 's/filetransfer_port=.*/'"filetransfer_port=$file_port"'/' ${installs_dir}/${server_dir}/server.ini
#
# Generate the service script
#
# If CentOS / Fedora
if [ -f /etc/redhat-release ]; then
printf "${bold}Generating TeamSpeak 3 service @ /etc/rc.d/init.d/${server_name}${normal}"
cat <<EOF > /etc/rc.d/init.d/${server_name}
#!/bin/sh
# chkconfig: 2345 95 20
# description: TeamSpeak 3 Server
# processname: ${server_name}
secret = "$2"
cd ${installs_dir}/${server_dir}
case "\$1" in
	'start')
		su teamspeak -c "${installs_dir}/${server_dir}/ts3server_startscript.sh start serveradmin_password=$secret";;
	'stop')
		su teamspeak -c "${installs_dir}/${server_dir}/ts3server_startscript.sh stop serveradmin_password=$secret";;
	'restart')
		su teamspeak -c "${installs_dir}/${server_dir}/ts3server_startscript.sh restart serveradmin_password=$secret";;
	'status')
		su teamspeak -c "${installs_dir}/${server_dir}/ts3server_startscript.sh status serveradmin_password=$secret";;
	'monitor-start')
		# In case of restart of existing monitored instances
		if [ -f ${installs_dir}/${server_dir}/${server_id}.pid ]; then
			rm -f ${installs_dir}/${server_dir}/${server_id}.pid
		fi
		while true; do
			# If server responds with "No server running" then restart it
			if [[ \$(service ${server_name} status) == *"No server"* ]]; then
				su teamspeak -c "${installs_dir}/${server_dir}/ts3server_startscript.sh start serveradmin_password=$secret" &> /dev/null
			fi
			sleep 5
		# Echo the PID to a file to be used to kill process later
		done & echo \$! > ${installs_dir}/${server_dir}/${server_id}.pid
	;;
	'monitor-stop')
		# Only stop the monitor if we know it's actually started first
		if [ -f ${installs_dir}/${server_dir}/${server_id}.pid ]; then
			# Kill monitor process, hide the output, and remove the PID file
			kill -9 \$(cat ${installs_dir}/${server_dir}/${server_id}.pid)
			wait \$(cat ${installs_dir}/${server_dir}/${server_id}.pid) 2>/dev/null
			rm -f ${installs_dir}/${server_dir}/${server_id}.pid
		fi
	;;
	*)
	echo "Usage: ${server_name} start|stop|restart|status|monitor-start|monitor-stop"
	exit 1;;
esac
EOF
else
# If Ubuntu / Debian
printf "\n${bold}Generating TeamSpeak 3 service @ /etc/init.d/${server_name}${normal}"
cat <<EOF > /etc/init.d/${server_name}
#!/bin/sh
### BEGIN INIT INFO
# Provides: ${server_name}
# Required-Start: networking
# Required-Stop:
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: TeamSpeak Server Daemon
# Description: Starts/Stops/Restarts the TeamSpeak Server Daemon
### END INIT INFO
secret = "$2"
cd ${installs_dir}/${server_dir}
case "\$1" in
	'start')
		su teamspeak -c "${installs_dir}/${server_dir}/ts3server_startscript.sh start serveradmin_password=$secret";;
	'stop')
		su teamspeak -c "${installs_dir}/${server_dir}/ts3server_startscript.sh stop serveradmin_password=$secret";;
	'restart')
		su teamspeak -c "${installs_dir}/${server_dir}/ts3server_startscript.sh restart serveradmin_password=$secret";;
	'status')
		su teamspeak -c "${installs_dir}/${server_dir}/ts3server_startscript.sh status serveradmin_password=$secret";;
	'monitor-start')
		# In case of restart of existing monitored instances
		if [ -f ${installs_dir}/${server_dir}/${server_id}.pid ]; then
			rm -f ${installs_dir}/${server_dir}/${server_id}.pid
		fi
		while true; do
			# If server responds with "No server running" then restart it
			if service ${server_name} status | grep "No server"; then
				su teamspeak -c "${installs_dir}/${server_dir}/ts3server_startscript.sh start serveradmin_password=$secret" &> /dev/null
			fi
			sleep 5
		# Echo the PID to a file to be used to kill process later
		done & echo \$! > ${installs_dir}/${server_dir}/${server_id}.pid
	;;
	'monitor-stop')
		# Only stop the monitor if we know it's actually started first
		if [ -f ${installs_dir}/${server_dir}/${server_id}.pid ]; then
			# Kill monitor process, hide the output, and remove the PID file
			kill -9 \$(cat ${installs_dir}/${server_dir}/${server_id}.pid)
			wait \$(cat ${installs_dir}/${server_dir}/${server_id}.pid) 2>/dev/null
			rm -f ${installs_dir}/${server_dir}/${server_id}.pid
		fi
	;;
	echo "Usage: ${server_name} start|stop|restart|status|monitor-start|monitor-stop"
	exit 1;;
esac
EOF
fi
echo " [DONE]"
#
# Change ownership of all TeamSpeak files to TeamSpeak user and make start script executable
#
chown -R teamspeak:teamspeak ${installs_dir}
chmod +x ${installs_dir}/${server_dir}/ts3server_startscript.sh
#
# Fixing common error @ http://forum.teamspeak.com/showthread.php/68827-Failed-to-register-local-accounting-service
#
if ! mount|grep -q "/dev/shm"; then
	echo "tmpfs /dev/shm tmpfs defaults 0 0" >> /etc/fstab
	mount -t tmpfs tmpfs /dev/shm
fi
#
# Initiate the TeamSpeak service and set to run @ boot
#
printf "${bold}Adding TeamSpeak 3 ${server_dir} to boot sequence and setting runlevels${normal}"
if [ -f /etc/redhat-release ]; then
	chmod +x /etc/rc.d/init.d/${server_name}
	chkconfig --add ${server_name}
	chkconfig --level 2345 ${server_name} on
else
	chmod +x /etc/init.d/${server_name}
	update-rc.d ${server_name} defaults
fi
echo " [DONE]"
#
echo -e ""
echo "Install Complete! \n You may now start your server... "
echo "{INSTALLER_END}"
exit 0