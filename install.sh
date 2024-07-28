#!/bin/bash
#This script will install autorotate system for KDE

echo  " "
echo  " ##################################################################"
echo  " #                       Install scrennsaver                      #"
echo  " #       Developed for X11 & KDE Plasma  by sergio melas 2024     #"
echo  " #                                                                #"
echo  " #                Emai: sergiomelas@gmail.com                     #"
echo  " #                   Released unde GPV V2.0                       #"
echo  " #                                                                #"
echo  " ##################################################################"
echo  " "

echo  ""

if [ $XDG_SESSION_TYPE  != 'x11' ] || [ $DESKTOP_SESSION != 'plasma' ]
then
  echo  " "
  echo  " ############################################################################"
  echo  " #  KDE Windows Screensavers support only systems with KDE Plasma on Xorg   #"
  echo  " #                     Installation Aborted                                 #"
  echo  " ############################################################################"
  echo  " "
  exit 0
fi

VAR=$0
DIR="$(dirname "${VAR}")"
cd  "${DIR}"


echo  "Login as administrator to install"
sudo ls >/dev/null
echo  ""

echo  "Installing Libraries:"
echo  ""
sudo apt-get install libnotify-bin
sudo apt-get install xprintidle
sudo apt-get install xdotool
sudo apt-get install zenity
sudo apt-get install wine
sudo apt-get install appmenu-gtk2-module appmenu-gtk3-module



#Install wine bottle for scresavers
rm -r /home/$USER/.winscr
WINEARCH=win32 WINEPREFIX=/home/$USER/.winscr winecfg

#copy screensavers in the bottle
cd ./'Scr files'
cp * /home/$USER/.winscr/drive_c/windows/system32/

cd ..

#Copy scripts in the bottle
cd ./Payload

cp * /home/$USER/.winscr

cd ..

#Copy autostart and settings lachers
cd ./'Launch'
sudo cp ./WinScreensaver.desktop /usr/share/applications/
rm  /home/$USER/.config/autostart/winscr_screensaver.sh.desktop
cp  ./winscr_screensaver.sh.desktop /home/$USER/.config/autostart/
cd  /home/$USER/.config/autostart/
#Icon=<path>/.icon/shredder.png
command="Exec=/home/$USER/.winscr/winscr_screensaver.sh"
file="'./winscr_screensaver.sh.desktop'"
command="echo \""$command" \">>  "$file
eval $command

#Run the first config
kstart5 bash /home/$USER/.winscr/winscr_choose.sh


















