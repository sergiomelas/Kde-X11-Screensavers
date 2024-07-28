#!/bin/bash
#This script will install autorotate system for KDE

echo  " "
echo  " ##################################################################"
echo  " #                        Choose Timeout                      #"
echo  " #       Developed for X11 & KDE Plasma  by sergio melas 2024     #"
echo  " #                                                                #"
echo  " #                Emai: sergiomelas@gmail.com                     #"
echo  " #                   Released unde GPV V2.0                       #"
echo  " #                                                                #"
echo  " ##################################################################"


Tim=15;
rm /home/$USER/.winscr/timeout.conf

echo  ""
echo -n "Choose the theme : "
#array=( 'dummy' '30 seconds' '2 minutes' '5 minutes'  '10 minutes' '15 minutes' 'Screensaver Disabled' )
#Time=$(zenity --entry --title "Window title" --text "${array[@]}" --text "Plese choose the screensaver timeout.")

Tim=$( cat /home/$USER/.winscr/timeout.conf )


echo $Tim

case  "${Tim}"  in
   <29-31>)
      Time=$(zenity --list  --title="Win Screensavers Menu" --text "Pick an option (press 'Cancel' when finished)" --column "Pick" --column "Answer" --radiolist  TRUE "30 seconds" FALSE "2 minutes"  FALSE "5 minutes"  FALSE "10 minutes"  FALSE "15 minutes" FALSE "Screensaver Disabled"  )
   ;;
   <119-121>)
      Time=$(zenity --list  --title="Win Screensavers Menu" --text "Pick an option (press 'Cancel' when finished)" --column "Pick" --column "Answer" --radiolist  FALSE "30 seconds" TRUE  "2 minutes"  FALSE "5 minutes"  FALSE "10 minutes"  FALSE "15 minutes" FALSE "Screensaver Disabled"  )
   ;;
   <299-301>)
      Time=$(zenity --list  --title="Win Screensavers Menu" --text "Pick an option (press 'Cancel' when finished)" --column "Pick" --column "Answer" --radiolist  FALSE "30 seconds" FALSE  "2 minutes"  TRUE "5 minutes"  FALSE "10 minutes"  FALSE "15 minutes" FALSE "Screensaver Disabled"  )
    ;;
   <599-601>)
      Time=$(zenity --list  --title="Win Screensavers Menu" --text "Pick an option (press 'Cancel' when finished)" --column "Pick" --column "Answer" --radiolist  FALSE "30 seconds" FALSE  "2 minutes"  FALSE "5 minutes"  TRUE "10 minutes"  FALSE "15 minutes" FALSE "Screensaver Disabled"  )
    ;;
   <899-901>)
      Time=$(zenity --list  --title="Win Screensavers Menu" --text "Pick an option (press 'Cancel' when finished)" --column "Pick" --column "Answer" --radiolist  FALSE "30 seconds" FALSE  "2 minutes"  FALSE "5 minutes"  FALSE "10 minutes"  TRUE "15 minutes" FALSE "Screensaver Disabled"  )
    ;;
    *)
      Time=$(zenity --list  --title="Win Screensavers Menu" --text "Pick an option (press 'Cancel' when finished)" --column "Pick" --column "Answer" --radiolist  FALSE "30 seconds" FALSE  "2 minutes"  FALSE "5 minutes"  FALSE "10 minutes"  FALSE "15 minutes" TRUE "Screensaver Disabled"  )
    ;;
esac


if [ -z "$Time" ]
then
      zenity --info --timeout 2 --text="No timeout chosen!" #user aborted
else
    echo  -n "The chosen screesaver is:  $SCR"
    echo $SCR   |  tee -a /home/$USER/.winscr/scrensaver.conf       > /dev/null

    case $Time in
   '30 seconds')
      echo  "30 seconds"
      Tim=30;
   ;;
   '2 minutes')
      echo  "2 minutes"
      Tim=120;
   ;;
   '5 minutes')
      echo  "5 minutes"
      Tim=300;
    ;;
   '10 minutes')
      echo  "10 minutes"
      Tim=600;
    ;;
   '15 minutes')
      echo  "15 minutes"
     Tim=900;
    ;;
    'Screensaver Disabled')
      echo  "Screensaver Disabled"
     Tim=-1;
    ;;
    esac

    echo $Tim   |  tee -a /home/$USER/.winscr/timeout.conf       > /dev/null

fi


cmd="/home/$USER/.winscr/winscr_menu.sh"
kstart5 bash $cmd  &



