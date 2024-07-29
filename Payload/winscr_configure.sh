#!/bin/bash
#This script will install autorotate system for KDE

echo  " "
echo  " ##################################################################"
echo  " #                     Configure scrennsaver                      #"
echo  " #       Developed for X11 & KDE Plasma  by sergio melas 2024     #"
echo  " #                                                                #"
echo  " #                Emai: sergiomelas@gmail.com                     #"
echo  " #                   Released unde GPV V2.0                       #"
echo  " #                                                                #"
echo  " ##################################################################"
echo  " "

echo  ""


SCR_SAVER=$( cat /home/$USER/.winscr/scrensaver.conf )
WINEPREFIX=/home/$USER/.winscr
wine /home/$USER/.winscr/drive_c/windows/system32/"$SCR_SAVER"

echo  ""
rm /home/$USER/.winscr/lockscreen.conf
echo -n "Choose the locksession : "
array=( 'dummy' 'Yes' 'No'  )
LockScr=$(zenity --entry --title "Lock Screen Configuration:" --text "${array[@]}" --text "Do you want to lock the session after screensaver?")

if [ -z "$LockScr" ]
then
      zenity --info --timeout 2 --text="No option chosen! Defaulting to lock screen" #user aborted
      LockSc=1;
else
    echo  -n "The chosen lockscreen option is:  $LockScr"

    case $LockScr in
     'Yes')
        echo  "Lock screen active"
        LockSc=1;
        ;;
      'No')
        echo  "Lock screen inactive"
        LockSc=0;
   ;;
   *)
   zenity --info --timeout 2 --text="No option chosen! Defaulting to lock screen" #user aborted
   LockSc=1;
   ;;
   esac


fi

echo $LockSc   |  tee -a /home/$USER/.winscr/lockscreen.conf       > /dev/null

#reopen menu
cmd="/home/$USER/.winscr/winscr_menu.sh"
kstart5 bash $cmd  &
