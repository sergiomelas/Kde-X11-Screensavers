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


readarray array < <((cd  /home/$USER/.winscr/drive_c/windows/system32 &&ls *.scr))

#for i in "${!array[@]}"; do
#        elem="$array[$i]"
#        elem=${elem::-4}
#        array[$i]="$elem"
#done

for i in "${!array[@]}"; do
 arrayz[$i]=$( basename -a "${array[$i]%.*}" )
done
arrayz=( "Dummy" "${arrayz[@]}" )
SCR=$(zenity --entry --title "Winscr Chooser" --text "${arrayz[@]}" --text "Plese choose the screensaver")
SCR=$SCR.scr
SCR_SAVER=$( cat /home/$USER/.winscr/scrensaver.conf )
if [ -z "$SCR" ]
then
    zenity --info --timeout 2 --text="No screesaver chosen!" #user aborted
    SCR=$SCR_SAVER
else
    echo  -n "The chosen screesaver is:  $SCR"
fi
rm /home/$USER/.winscr/scrensaver.conf
echo $SCR | tee -a /home/$USER/.winscr/scrensaver.conf  > /dev/null

#reopen menu
cmd="/home/$USER/.winscr/winscr_menu.sh"
kstart5 bash $cmd  &





