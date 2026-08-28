#!/bin/bash
# filename: winscr_backend.sh
# Final version 2026 - Rendering Backend Configuration Manager

echo " "
echo " ##################################################################"
echo " #                                                                #"
echo " #               Rendering Backend Manager                        #"
echo " #    Developed for X11/Wayland & KDE Plasma by sergio melas 2026 #"
echo " #                                                                #"
echo " #                Email: sergiomelas@gmail.com                    #"
echo " #                    Released under GPL V2.0                     #"
echo " #                                                                #"
echo " ##################################################################"
echo " "

# --- 1. PATH CONFIGURATION ---
WINEPREFIX_PATH="$HOME/.winscr"
SCR_DIR="$WINEPREFIX_PATH/drive_c/windows/system32"
DB_FILE="$WINEPREFIX_PATH/scr_database"
export WINEPREFIX="$WINEPREFIX_PATH"

# Ensure database exists
touch "$DB_FILE"

# --- HELPER: STANDARDIZED RELAUNCH ---
relaunch_menu() {
    # 1. Clean the lock file so the new menu can start
    rm -f "$WINEPREFIX_PATH/.running"

    # 2. Heal the Daemon (Only if not already running)
    if ! pgrep -f "winscr_screensaver.sh" >/dev/null; then
        pkill -f "winscreensaver" 2>/dev/null
        wineserver -k 2>/dev/null
        sleep 0.5
        bash "$WINEPREFIX_PATH/winscr_screensaver.sh" &
    fi

    # 3. Always launch the menu script directly
    # This ignores the 'winscreensaver' command check and uses your script
    bash "$WINEPREFIX_PATH/winscr_menu.sh" &

    # 4. Exit
    exit 0
}

# --- BUILD BACKEND LIST ---
# Find all installed screensavers
mapfile -t scr_pool < <(find "$SCR_DIR" -maxdepth 1 -iname "*.scr" -printf "%f\n" | sort)

if [ ${#scr_pool[@]} -eq 0 ]; then
    zenity --error --text="No screensavers found in system32." --width=300
    relaunch_menu
fi

ZEN_ARGS=()
for scr in "${scr_pool[@]}"; do
    [[ -z "$scr" ]] && continue
    display_name="${scr%.*}"

    current_backend="standard"
    if [ -f "$DB_FILE" ]; then
        # Case-insensitive match against database keys (ignoring extension case)
        matched_tag=$(grep -iv "^${scr}:" "$DB_FILE" 2>/dev/null | grep -iv "^${display_name}\." "$DB_FILE" | cut -d':' -f2 | head -n 1)
        # Fallback to direct lowercase/uppercase lookup
        if [ -z "$matched_tag" ]; then
            matched_tag=$(grep -i "^${scr}:" "$DB_FILE" | cut -d':' -f2 | head -n 1)
        fi
        if [ -n "$matched_tag" ]; then
            current_backend="$matched_tag"
        fi
    fi

    if [ "$current_backend" == "dxvk" ]; then
        ZEN_ARGS+=(TRUE "$display_name")
    else
        ZEN_ARGS+=(FALSE "$display_name")
    fi
done

CHOICE=$(zenity --list --checklist --title="Rendering Backend Manager" \
    --text="Check screensavers to use DXVK (Unchecked = Standard):" \
    --column="Pick" --column="Screensaver Name" \
    "${ZEN_ARGS[@]}" --height=450 --width=450 --separator="|")

if [ $? -ne 0 ]; then
    relaunch_menu
fi

> "$DB_FILE"

IFS="|" read -ra SELECTED_ITEMS <<< "$CHOICE"
for scr in "${scr_pool[@]}"; do
    [[ -z "$scr" ]] && continue

    is_dxvk=false
    for sel in "${SELECTED_ITEMS[@]}"; do
        if [ "$sel" == "$scr" ]; then
            is_dxvk=true
            break
        fi
    done

    if [ "$is_dxvk" = true ]; then
        echo "${scr}:dxvk" >> "$DB_FILE"
    else
        echo "${scr}:standard" >> "$DB_FILE"
    fi
done

zenity --info --title="Backend Updated" \
    --text="Rendering backends successfully configured!" \
    --width=300 --timeout=2

relaunch_menu
exit 0
