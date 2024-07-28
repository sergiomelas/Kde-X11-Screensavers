#!/bin/bash
#This script will install autorotate system for KDE

echo  " "
echo  " ##################################################################"
echo  " #                       Remove scrennsaver                       #"
echo  " #       Developed for X11 & KDE Plasma  by sergio melas 2024     #"
echo  " #                                                                #"
echo  " #                Emai: sergiomelas@gmail.com                     #"
echo  " #                   Released unde GPV V2.0                       #"
echo  " #                                                                #"
echo  " ##################################################################"
echo  " "

echo  ""


echo  "Login as administrator to romove"
sudo ls >/dev/null
echo  ""

#remove wine bottle for scresavers
rm -r /home/$USER/.winscr

#remove lauchers
rm /home/$USER/.config/autostart/winscr_screensaver.sh.desktop
sudo rm /usr/share/applications/WinScreensaver.desktop









