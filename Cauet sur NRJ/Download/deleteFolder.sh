#!/bin/bash

numberOfDays=$1

folder=/home/${USER}/Cauet/`date -d "${numberOfDays} days ago" '+%Y/%m/%d'`

rm -rf $folder
