#!/bin/bash

if [ -z "$1" ]; then
   exit;
fi

numberOfDays=$1

folder=/home/${USER}/Cauet/`date -d "${numberOfDays} days ago" '+%Y/%m/%d'`

if [ -d "$folder" ]; then
   rm -rf "$folder"
fi
