#!/bin/sh
ssh minecraft@$FTB_SERVER_HOST "mkdir -p /home/minecraft/world/computer/$1/ && mkdir -p /home/minecraft/world/computer/$2/ && echo \"shell.run('harvest')\" > /home/minecraft/world/computer/$1/startup && echo \"shell.run('plant')\" > /home/minecraft/world/computer/$2/startup"
scp harvest.lua minecraft@$FTB_SERVER_HOST:/home/minecraft/world/computer/$1/harvest
#scp plant.lua minecraft@$FTB_SERVER_HOST:/home/minecraft/world/computer/$2/plant