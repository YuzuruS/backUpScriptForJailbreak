#!/bin/sh
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

BTIME=`date +"%F_%H-%M"`

DIRNAME="backup-`date +%Y.%m.%d`"
if [ -e $DIRNAME ]; then
	rm -rf $DIRNAME
	echo "Remove $DIRNAME"
else
	mkdir $DIRNAME
	echo "Create $DIRNAME"
fi

yes_no "Do you back up your jailbreak apps?"
if [ $? -eq 0 ]; then
	dpkg --get-selections > `pwd`/$DIRNAME/cydiaapp.lst
fi

yes_no "Do you start to back up your files?"
if [ $? -eq 0 ]; then
	if [ -e `pwd`/backuplist.lst ]; then
		rsync -avL --delete --exclude-from=`pwd`/backuplist.lst / `pwd`/$DIRNAME
		tar cfpvz iosbkup_$BTIME.tar.gz $DIRNAME
	else
		echo "backuplist.lst file not found."
	fi
else
	if [ -e `pwd`/$DIRNAME/cydiaapp.lst ]; then
		tar cfpvz iosbkup_applist_$BTIME.tar.gz `pwd`/$DIRNAME/cydiaapp.lst
		echo "Remove cydiaapplist"
		rm -rf `pwd`/$DIRNAME/cydiaapp.lst
	fi
fi

if [ -e `pwd`/cydiaapp.lst ]; then
	echo "Remove cydiaapplist"
	rm -rf `pwd`/$DIRNAME/cydiaapp.lst
fi

rm -rf $DIRNAME
echo "Remove $DIRNAME"
echo "

++++ Backup Complete ++++
"