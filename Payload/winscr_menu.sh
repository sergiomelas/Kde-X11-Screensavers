#!/bin/bash
#This script will install autorotate system for KDE

echo  " "
echo  " ##################################################################"
echo  " #                        Choose Option Menu                      #"
echo  " #       Developed for X11 & KDE Plasma  by sergio melas 2024     #"
echo  " #                                                                #"
echo  " #                Emai: sergiomelas@gmail.com                     #"
echo  " #                   Released unde GPV V2.0                       #"
echo  " #                                                                #"
echo  " ##################################################################"


VAR=$0
DIR="$(dirname "${VAR}")"
cd  "${DIR}"

Choice="Choose Screensaver"

echo  ""
echo -n "Plese choose an option"

Choice=$(zenity --list  --title="Win Screensavers Menu" --text "Pick an option" --column "Pick" --column "Answer"  --radiolist  FALSE "Choose Screensaver" FALSE "Test Screensaver"  FALSE "Configure Screensaver"  FALSE "Configure Timeout"  FALSE "About"  )

#process menu choice
case $Choice in
  'Choose Screensaver')
    echo  "Choose Screensaver"
    cmd="/home/$USER/.winscr/winscr_choose.sh"
    kstart5 bash $cmd  &
  ;;
  'Test Screensaver')
    echo  "Test Screensaver"
    cmd="/home/$USER/.winscr/winscr_test.sh"
    kstart5 bash $cmd  &
  ;;
  'Configure Screensaver')
    echo  "Configure Screensaver"
    cmd="/home/$USER/.winscr/winscr_configure.sh"
    kstart5 bash $cmd  &
  ;;
  'Configure Timeout')
    echo  "Configure Timout"
    cmd="/home/$USER/.winscr/winscr_timeout.sh"
    kstart5 bash  $cmd  &
  ;;
  'About')
    echo  "About SCreen"
    cmd="/home/$USER/.winscr/winscr_about.sh"
    kstart5 bash  $cmd  &
    ;;
esac






