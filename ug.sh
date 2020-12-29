#!/bin/bash
# ug = update google
# Dec 2020 rysncs the local and remote copies of googe according to specified command line arguments

# command line parameters
# $1 is action to do
# $2; # optional, sub-directory to synchronize

# default directories and files
LLOC="/home/peter/local_GoogleDrive" # location of local directory
RLOC="/home/peter/GoogleDrive" # location of remote direct synched with ocaml-fuse
FILES="/home/peter/.local_GoogleDrive_files" # list of directories to synchronize

# if no directory has been specified then check that the default list of files
# to synchronize exists
if [ -z $2 ]; then
	if [ ! -f $FILES ]; then
		echo "Cannot find files to transfer in file $FILES"
		exit 0
	fi
fi

if [ -z $1 ]; then
	echo "This script uses rsync to synchronize local and remote copies of Google Drive"
	echo "local copy is at $LLOC"
	echo "remote copy is at $RLOC"
	echo "usage: sh ug.sh <REQUIRED: action parameter choose one of the numbers below> <OPTIONAL: name sub directory to synchronize, default are files listed in $FILES"
	echo "0: delete local directory and copy remote directories to local"
	echo "1: same as 0, but dry run only"
	echo "2: update remote copy with new versions of local files (no file deletion)"
	echo "3: same as 2, but dry run only"
	echo "4: update local copy with new versions of remote files (no file deletion)"
	echo "5: same as 4, but dry run only"
	exit 0
elif [ $1 -eq 0 ]; then
	rm -rf $LLOC/*
	if [ $2 ]; then # both options $1 and $2 have been selected
		rsync -r -v $RLOC/$2/ $LLOC/$2/
		exit 0
	else # only options $1 is selected
		rsync -r -v --files-from=$FILES $RLOC/ $LLOC/
		exit 0
	fi
elif [ $1 -eq 1 ]; then
#	rm -rf $LLOC/*
	if [ $2 ]; then # both options $1 and $2 have been selected
		rsync -r -v -n $RLOC/$2/ $LLOC/$2/
		exit 0
	else # only options $1 is selected
		rsync -r -v -n --files-from=$FILES $RLOC/ $LLOC/
		exit 0
	fi
elif [ $1 -eq 2 ]; then
	if [ $2 ]; then # both options $1 and $2 have been selected
		rsync -r -v --update $LLOC/$2/ $RLOC/$2/
		exit 0
	else # only options $1 is selected
		rsync -r -v --update --files-from=$FILES $LLOC/ $RLOC/
		exit 0
	fi
elif [ $1 -eq 3 ]; then
	if [ $2 ]; then # both options $1 and $2 have been selected
		rsync -r -v -n --update $LLOC/$2/ $RLOC/$2/
		exit 0
	else # only options $1 is selected
		rsync -r -v -n --update --files-from=$FILES $LLOC/ $RLOC/
		exit 0
	fi
elif [ $1 -eq 4 ]; then
	if [ $2 ]; then # both options $1 and $2 have been selected
		rsync -r -v --update $RLOC/$2/ $LLOC/$2/
		exit 0
	else # only options $1 is selected
		rsync -r -v --update --files-from=$FILES $RLOC/ $LLOC/
		exit 0
	fi
elif [ $1 -eq 5 ]; then
	if [ $2 ]; then # both options $1 and $2 have been selected
		rsync -r -v -n --update $RLOC/$2/ $LLOC/$2/
		exit 0
	else # only options $1 is selected
		rsync -r -v -n --update --files-from=$FILES $RLOC/ $LLOC/
		exit 0
	fi
else
	echo "Error, command line parameter $1 is not valid"
	exit 0
fi
