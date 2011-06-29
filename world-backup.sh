#!/bin/bash

# Title: Minecraft World Backup
# Author: Koodough, Linuxraptor
# NO WARRANTIES YOU CREEPER


#Path to your world folder
WORLD="/home/minecraft/world_storage"
WORLD_DIRNAME="`dirname $WORLD`"

#VOLATILE is the path the World symlink is going to be located linked to the 
#NOTE: Make sure your server.properties is pointing to the World_in_RAM
VOLATILE="$WORLD_DIRNAME/World_in_RAM"

SCREEN_NAME="Minecraft"

echo "Issuing save-on command..."
screen -p $SCREEN_NAME -X stuff "$(printf "save-on\r")"
sleep 1
echo "Issuing save-all command, wait 5s..."
screen -p $SCREEN_NAME -X stuff "$(printf "save-all\r")" 
sleep 5
echo "Issuing save-off command..."
screen -p $SCREEN_NAME -X stuff "$(printf "save-off\r")"
sleep 1


rsync -ravu --delete --force "$VOLATILE" "$WORLD"

screen -p Minecraft -X stuff "$(printf "say RAM sync complete.\r")"

#Option --cron will create a cronjob for this script

case $1 in
	--cron)
		#Write out backup crontab
		BACKUP_CRON="backup_minecraft_cron"
		crontab -l > $BACKUP_CRON
		#echo new cron into cron file
		echo "Creating cron job for $PWD/`basename $0` every 20mins"
		echo "*/20 * * * * $PWD/`basename $0`" >> $BACKUP_CRON
		#install new cron file
		crontab $BACKUP_CRON
		rm $BACKUP_CRON
esac



#screen -S minecraft -p 0 -X stuff "$(printf "say RAM synced successully.\r")"
#A warning every five minutes filled the logs and got really annoying.

# RSYNC
# -r        recursive
# -a        archiving mode (preserve premissions, time, all that stuff.
#           it's more elegant than just preserving time)
# -v        verbose like a sailor
# -u        update, so it doesnt sync fucking everything every single time
# --delete  also remove files from the destination if they were
#           previously removed in the volatile directory
# --force   same as above except allows removing nonempty directories
#
# Also, note the trailing slashes at the end of the directories.
# These ensure we're copying the contents of one directory to the contents of
# another. Rsync gets very picky about this.

