#!/bin/bash
#This script will lauch windows screensaver

echo  " "
echo  " ##################################################################"
echo  " #                 Windows screensavers laucher                   #"
echo  " #       Developed for X11 & KDE Plasma  by sergio melas 2024     #"
echo  " #                                                                #"
echo  " #                Emai: sergiomelas@gmail.com                     #"
echo  " #                   Released unde GPV V2.0                       #"
echo  " #                                                                #"
echo  " ##################################################################"
echo  " "


# Run the screensaver
trigger_cmd() {
    SCR_SAVER=$( cat /home/$USER/.winscr/scrensaver.conf )
    WINEPREFIX=/home/$USER/.winscr
    wine /home/$USER/.winscr/drive_c/windows/system32/"$SCR_SAVER" /s
    LockSc=$( cat /home/$USER/.winscr/lockscreen.conf )
    if [ $LockSc -gt '0' ]; then
       loginctl lock-session
    fi
}

sleep_time=$IDLE_TIME
triggered=false

# ceil() instead of floor()
while sleep $(((sleep_time+999)/1000)); do
    #screensaver time in seconds
    SCR_TIME=$( cat /home/$USER/.winscr/timeout.conf )
    # Calculate screensaver time in millisencos
    IDLE_TIME=$(($SCR_TIME*1000))
    idle=$(xprintidle)
    echo "Waiting for Screensaver"
    if [ $idle -ge $IDLE_TIME ]; then
        if ! $triggered; then
            echo "Start Screensaver"
            trigger_cmd
            triggered=true
            sleep_time=$IDLE_TIME
        fi
    else
        triggered=false
        # Give 100 ms buffer to avoid frantic loops shortly before triggers.
        sleep_time=$((IDLE_TIME-idle+100))
    fi
    sleep 0.1
done
