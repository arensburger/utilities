#!/bin/bash
# ug = update google -
# march 2021 updates from local google folder to permanent one

rsync -a --update --delete -v /home/peter/local_GoogleDrive/ /home/peter/GoogleDrive/
