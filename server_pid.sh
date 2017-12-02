#!/bin/bash
#
# XenoPanel Server PID Checker
# Last Synced:
#
# We recommend you leave this file alone UNLESS you have experiance with Linux.
# 
# ** WARNING ** 
# When you sync/update the machines XenoPanel version from within the panel it will re-create this file.
#
server_id="$1"
server_directory="/home/XenoPanel/pids/"
search_word="$2"
#
cd $server_directory;
#
if [ ! -e $server_id.pid ]
then
    echo '' > $server_id.pid
fi
#
if [[ $(cat $1.pid) = *$2* ]]; then
    echo "yes"
else
    echo "$2" > $server_id.pid
fi
#
exit