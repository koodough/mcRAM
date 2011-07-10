#!/bin/bash
#
# Title: Automatic remote Minecraft backup
# Editor: Linuxraptor
# ORIGINAL CODE is from minecraft.sh in /home/minecraft
# and can be found in minecraftforums.net.




#Path to your world folder
WORLD="/home/minecraft/world_storage"

WORLD_NAME="`basename $WORLD`"
WORLD_DIRNAME="`dirname $WORLD`"

# Backups
BACKUP_PATH=$WORLD_DIRNAME/automatic_backups
BACKUP_FULL_LINK=${BACKUP_PATH}/${WORLD_NAME}_full.tgz
BACKUP_DAYS_FULL=5

#VOLATILE is the path the World symlink is going to be located linked to the 
#NOTE: Make sure your server.properties is pointing to the World_in_RAM
VOLATILE="$WORLD_DIRNAME/World_in_RAM"

SCREEN_NAME="Minecraft"

#Check to see if the backup dirtectory exits
if [[ ! -d $BACKUP_PATH  ]]; then
	
	#If not then make the backup directory
	if ! mkdir -p $BACKUP_PATH; then
		echo "Backup path $BACKUP_PATH does not exist and I could not create the directory! Permissions maybe?"
		rm $BACKUP_PATH/$WORLD_NAME.lock
		exit 1 #FAIL :(
	fi
fi

#Check to see if there is already a backup running. If not make a lock and then proceed
if [[ -e $BACKUP_PATH/$WORLD_NAME.lock ]]; then
	echo "Backup already in progress.  Aborting."
	exit 1
else
	touch $BACKUP_PATH/$WORLD_NAME.lock
fi

cd $BACKUP_PATH

#If the file exists then warn players and start backup
if [[ -e $WORLD ]]; then
	echo "Server running, warning players : backup in 10s."
	#screen -S $SCREEN_NAME -p 0 -X stuff "$(printf "say Backing up the map in 10s\r")"
	screen -p $SCREEN_NAME -X stuff "$(printf "say Backing up the map in 10s\r")"
	sleep 10
	screen -p $SCREEN_NAME -X stuff "$(printf "say Now backing up the map...\r")"
	echo "Issuing save-on command..."
	screen -p $SCREEN_NAME -X stuff "$(printf "save-on\r")"
	sleep 1
	echo "Issuing save-all command, wait 5s..."
	screen -p $SCREEN_NAME -X stuff "$(printf "save-all\r")"
	sleep 5
	echo "Issuing save-off command..."
	screen -p $SCREEN_NAME -X stuff "$(printf "save-off\r")"
	sleep 1
	echo "Syncing RAM to physical disk..."
	rsync -ravu --delete --force "$VOLATILE" "$WORLD" && sleep 1 && echo "Physical memory SYNCED."

	cd $BACKUP_PATH

	if ! mkdir -p $BACKUP_PATH; then
		echo "Backup path $BACKUP_PATH does not exist and I could not create the directory!"
		rm $BACKUP_PATH/$WORLD_NAME.lock
		exit 1
	fi
fi

cd $BACKUP_PATH

#Date to name the file
DATE=$(date +%Y-%m-%d-%Hh%M)


BACKUP_FILENAME=$WORLD_NAME-$DATE
BACKUP_FILES=$BACKUP_PATH/list.$DATE

# Make full backup, and remove old incrementals
BACKUP_FILENAME=$BACKUP_FILENAME-full.tgz

# Remove full archives older than $BACKUP_DAYS_FULL
find ./$WORLD_NAME-*-full.tgz -type f -mtime +$BACKUP_DAYS_FULL -print >> purgelist
rm -f $(cat purgelist) purgelist

# Now make our full backup
pushd $WORLD_DIRNAME
find $WORLD_NAME -print > $BACKUP_FILES
tar -czhf $BACKUP_PATH/$BACKUP_FILENAME --files-from=$VOLATILE

# tar -czhf $BACKUP_PATH/$BACKUP_FILENAME --files-from=$BACKUP_FILES
# 
# You're tarring the backup files directory. And dumping
# them into a file inside that directory as well. So 
# we're making an infinite tarball.
#
#
popd

rm -f $BACKUP_FULL_LINK 
ln -s $BACKUP_FILENAME $BACKUP_FULL_LINK

rm -f $BACKUP_FILES

if [[ 1 -eq $ONLINE ]]; then
	#                                        echo "Issuing save-on command..."
	#                                        screen -p $SCREEN_NAME -X stuff "$(printf "save-on\r")"
	#                                        sleep 1
	screen -p $SCREEN_NAME -X stuff "$(printf "say Backup is done, have fun !\r")"
fi
echo "Backup process is over."
rm $BACKUP_PATH/$WORLD_NAME.lock
