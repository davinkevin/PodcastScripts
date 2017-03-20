#!/bin/bash

cd /home/${USER}/Cauet/$(date --date now '+%Y')/$(date --date now '+%m')/$(date --date now '+%d')/
find . -type f -size -2M -delete
