#!/bin/bash
# ug = update google -
# march 2021 updates from local google folder to permanent one
# march 2021 adding functionality that specific folder can be given as
#   command line parameter

LOCALROOT="/home/peter/local_GoogleDrive/" #root directory of local folder
REMOTEROOT="/home/peter/GoogleDrive/" #root directory of GoogleDrive folder

### Test if command line argument has been provided and set to and from folder
### path accordingly
if [ -z "$1" ]
then
  LOCALFOLDER=$LOCALROOT
  REMOTEFOLDER=$REMOTEROOT
else
  LOCALFOLDER="$LOCALROOT$1/"
  REMOTEFOLDER="$REMOTEROOT$1/"
fi

#echo "local $LOCALFOLDER"
#echo "remote $REMOTEFOLDER"
rsync -a --update --delete -v --exclude '.Trash/*' $LOCALFOLDER $REMOTEFOLDER
