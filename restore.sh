#!/bin/sh

BKDIR="`basename ./backup-*`"

function yes_no {
	MSG=$1
	while :
	do
		echo -n "${MSG}
        [y/N]: "
		read ans
		case $ans in
		[yY]) return 0 ;;
		[nN]) return 1 ;;
		esac
	done
}

function restore1 {
	yes_no "Do you restore to backe up data?"
	if [ $? -eq 0 ]; then
		\cp -rpvf `pwd`/backup-*/private/etc/apt/sources.list.d/* /etc/apt/sources.list.d/
		\cp -rpvf `pwd`/backup-*/private/var/lib/cydia/* /var/lib/cydia/
		echo "Done!"
		yes_no "Do you refresh your repositories?"
		if [ $? -eq 0 ]; then
			apt-get update
			echo "Done!"
		fi
	fi
	
	yes_no "Do you restore to back up data from your list file?"
	if [ $? -eq 0 ]; then
		cd backup-*
		dpkg --set-selections < cydiaapp.lst
		cd ../
		apt-get -u dselect-upgrade --fix-missing -f
		echo "Done!"
	fi
	
	yes_no "Do you restore your back up file?"
	if [ $? -eq 0 ]; then
		rm -rf `pwd`/backup-*/cydiaapp.lst
		\cp -rpvf `pwd`/backup-*/* /
		rm /private/var/mobile/Library/Caches/com.apple.mobile.installation.plist
		rm -rf `pwd`/backup-*
		echo "Done!"
	fi
	
	echo "

++++ Restore Complete ++++
"
}

if [ -e `pwd`/iosbkup_*.tar.gz ]; then
	yes_no "Do you unzip your back up file?"
	if [ $? -eq 0 ]; then
		rm -rf `pwd`/backup-*
		tar xfpvz `pwd`/iosbkup_*.tar.gz
		BKDIR="`basename ./backup-*`"
		restore1
	elif ! [ -e `pwd`/backup-* ]; then
		echo "Error"
	else
		BKDIR="`basename ./backup-*`"
		restore1
	fi
elif ! [ -e `pwd`/backup-* ]; then
	echo "Error"
else
	BKDIR="`basename ./backup-*`"
	restore1
fi
