#!/bin/sh

CONNECTION=minecraft@$CREEPERHOST_SERVER_HOST

if [ "$#" -ne 1 ]; then
  echo "Most recent computer ID is: `ssh $CONNECTION cat /home/minecraft/world/computer/lastid.txt`"
else
  DEST=/home/minecraft/world/computer/$1/tree
  URL=https://raw.github.com/jarrett/treeFarm/master/tree.lua
  COMMAND="wget -O $DEST $URL"
  echo "Running remotely: $COMMAND"
  ssh $CONNECTION $COMMAND
fi

