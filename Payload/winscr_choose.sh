#!/bin/bash
#This script will install autorotate system for KDE

echo  " "
echo  " ##################################################################"
echo  " #                        Choose scrennsaver                      #"
echo  " #       Developed for X11 & KDE Plasma  by sergio melas 2024     #"
echo  " #                                                                #"
echo  " #                Emai: sergiomelas@gmail.com                     #"
echo  " #                   Released unde GPV V2.0                       #"
echo  " #                                                                #"
echo  " ##################################################################"
echo  " "

echo  ""


echo  ""
echo -n "Choose the screensaver : "

rm /home/$USER/.winscr/scrensaver.conf
readarray array < <((cd  /home/$USER/.winscr/drive_c/windows/system32 &&ls *.scr))
array=( "Dummy" "${array[@]}" )
SCR=$(zenity --entry --title "Winscr Chooser" --text "${array[@]}" --text "Plese choose the screensaver")
if [ -z "$SCR" ]
then
      zenity --info --timeout 2 --text="No screesaver chosen!" #user aborted
else
    echo  -n "The chosen screesaver is:  $SCR"
    echo $SCR   |  tee -a /home/$USER/.winscr/scrensaver.conf       > /dev/null
fi

#reopen menu
cmd="/home/$USER/.winscr/winscr_menu.sh"
kstart5 bash $cmd  &





