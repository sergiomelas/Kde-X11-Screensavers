#!/bin/bash
# filename: winscr_import.sh
# Final version 2026 - Smart Discovery + Selective Extension Correction + Sandbox QA

echo " "
echo " ##################################################################"
echo " #                                                                #"
echo " #                  Windows screensavers importer                 #"
echo " #    Developed for X11/Wayland & KDE Plasma by sergio melas 2026 #"
echo " #                                                                #"
echo " ##################################################################"
echo " "

WINEPREFIX_PATH="$HOME/.winscr"
SCR_DEST="$WINEPREFIX_PATH/drive_c/windows/system32"

# --- HELPER: STANDARDIZED RELAUNCH ---
relaunch_menu() {
    # 0. Safely append newly imported screensavers to the random pool without wiping custom selections
    local RANDOM_CONF="$WINEPREFIX_PATH/random_list.conf"
    if [ ! -f "$RANDOM_CONF" ]; then
        find "$SCR_DEST" -maxdepth 1 -iname "*.scr" -printf "%f\n" > "$RANDOM_CONF" 2>/dev/null
    else
        # Append any installed screensaver not already present in the config
        while IFS= read -r scr_file; do
            if ! grep -qxF "$scr_file" "$RANDOM_CONF"; then
                echo "$scr_file" >> "$RANDOM_CONF"
            fi
        done < <(find "$SCR_DEST" -maxdepth 1 -iname "*.scr" -printf "%f\n" 2>/dev/null)
    fi

    # 1. Clean the lock file so the new menu can start
    rm -f "$WINEPREFIX_PATH/.running"

    # 2. Heal the Daemon (Only if not already running)
    if ! pgrep -f "winscr_screensaver.sh" >/dev/null; then
        pkill -f "winscreensaver" 2>/dev/null
        wineserver -k 2>/dev/null
        sleep 0.5
        bash "$WINEPREFIX_PATH/winscr_screensaver.sh" &
    fi

    # 3. Only launch a new menu instance if one isn't already active in the background
    if ! pgrep -f "winscr_menu.sh" >/dev/null; then
        bash "$WINEPREFIX_PATH/winscr_menu.sh" &
    fi

    # 4. Exit
    exit 0
}

# --- QA TESTER (Surgical) ---
test_screensaver() {
    local screen_path="$1"
    local proc_base=$(basename "$screen_path")

    # Database path declaration
    local db_file="$WINEPREFIX_PATH/scr_database"
    touch "$db_file"

    local ext="${proc_base##*.}"
    local base="${proc_base%.*}"
    local target_name="${base}.${ext,,}"

    # REQUIREMENT 2: Test DXVK first. If it works, save as dxvk.
    if run_qa_pass "$screen_path" "$proc_base" "native,builtin"; then
        update_database_registry "$target_name" "dxvk"
        return 0
    fi

    # REQUIREMENT 2: If DXVK fails, test standard. If it works, save as standard.
    if run_qa_pass "$screen_path" "$proc_base" "builtin"; then
        update_database_registry "$target_name" "standard"
        return 0
    fi

    # REQUIREMENT 2: If both fail, skip (return failure)
    return 1
}

run_qa_pass() {
    local screen_path="$1"
    local proc_base="$2"
    local d3d_override="$3"
    local retries=1

    while [ $retries -gt 0 ]; do
        # Launch wine with specific DLL override and capture PID
        WINEDLLOVERRIDES="d3d9,dxgi=$d3d_override" wine "$screen_path" /s >/dev/null 2>&1 &
        local test_pid=$!
        sleep 3 # Give it time to initialize

        # SESSION-SPECIFIC DETECTION
        if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
            local is_visible="NO"
            if qdbus org.kde.KWin /KWin org.kde.KWin.queryWindowInfo 2>/dev/null | grep -q "pid: $test_pid"; then
                is_visible="YES"
            fi

            kill -9 "$test_pid" 2>/dev/null
            pkill -9 -P "$test_pid" 2>/dev/null
            wineserver -k 2>/dev/null

            if [[ "$is_visible" == "YES" ]]; then
                return 0
            fi
        else
            local log_file="/tmp/wine_test.log"
            export DISPLAY=:0
            export WAYLAND_DISPLAY=$WAYLAND_DISPLAY
            export XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR

            if ! pgrep -f "$proc_base" >/dev/null || wmctrl -l 2>/dev/null | grep -qi "Program Error"; then
                pkill -f "$proc_base" 2>/dev/null
                wmctrl -c "Program Error" 2>/dev/null
                rm -f "$log_file"
            else
                pkill -f "$proc_base" 2>/dev/null
                rm -f "$log_file"
                return 0
            fi
        fi

        ((retries--))
        sleep 1
    done

    return 1
}

update_database_registry() {
    local filename="$1"
    local backend="$2"
    local db_file="$WINEPREFIX_PATH/scr_database"

    # Remove existing entry if present, then append new tag
    if [ -f "$db_file" ]; then
        grep -v "^${filename}:" "$db_file" > "${db_file}.tmp" && mv "${db_file}.tmp" "$db_file"
    fi
    echo "${filename}:${backend}" >> "$db_file"
}


# --- SMART AUTO-DISCOVERY  ---
echo "Scanning home for screensaver collections..."
BEST_FOLDER=$(find "$HOME" -maxdepth 9 -iname "*.scr" -not -path "*/.*" -not -path "$WINEPREFIX_PATH/*" -print -quit 2>/dev/null | xargs -0 -I {} dirname "{}")

SCR_SOURCE=$(zenity --file-selection --directory --title="Select folder containing .scr files" --filename="${BEST_FOLDER}" --width=600)

# --- MAIN LOGIC BLOCK ---
if [ -n "$SCR_SOURCE" ]; then
    imported=0
    skipped=0

    # Check for Assets
    CRITICAL_ASSETS=$(find "$SCR_SOURCE" -maxdepth 1 -type f -not -iname "*.scr" -not -iname "*.txt" | wc -l)

    if [ "$CRITICAL_ASSETS" -gt 0 ]; then
        CHECKLIST_ARGS=()
        while IFS= read -r -d '' file; do
            CHECKLIST_ARGS+=("TRUE" "$file")
        done < <(find "$SCR_SOURCE" -maxdepth 1 -type f -not -path "$SCR_SOURCE" -printf "%f\0" | sort -z)

        CHOICE=$(zenity --list --title="Selective Import" --width=800 --height=450 --checklist --text="Select files to import:" --column="Pick" --column="File Name" "${CHECKLIST_ARGS[@]}" --separator="|")

        if [ $? -eq 0 ] && [ -n "$CHOICE" ]; then
            IFS="|" read -ra SELECTED_FILES <<< "$CHOICE"
            for filename in "${SELECTED_FILES[@]}"; do
                local ext="${filename##*.}"
                local base="${filename%.*}"
                local target_name="${base}.${ext,,}"
                if [ -f "$SCR_DEST/$target_name" ]; then continue; fi

                if [[ "${filename,,}" == *.scr ]]; then
                    if test_screensaver "$SCR_SOURCE/$filename"; then
                        cp -vn "$SCR_SOURCE/$filename" "$SCR_DEST/$target_name"
                        ((imported++))
                    else
                        ((skipped++))
                    fi
                else
                    cp -vn "$SCR_SOURCE/$filename" "$SCR_DEST/$target_name"
                fi
            done
        fi
    else
        # Surgical Import with Progress Bar
        total_files=$(find "$SCR_SOURCE" -maxdepth 1 -iname "*.scr" | wc -l)
        # Initialize with 3 counters (Imported:Skipped:Existing)
        echo "0:0:0" > /tmp/import_stats

        (
            current_file=0
            while IFS= read -r -d '' full_path; do
                filename=$(basename "$full_path")
                ext="${filename##*.}"
                base="${filename%.*}"
                target_name="${base}.${ext,,}"

                # 1. SKIP & INCREMENT EXISTING COUNTER
                if [ -f "$SCR_DEST/$target_name" ]; then
                    IFS=":" read -r imp skip exist < /tmp/import_stats
                    echo "$imp:$skip:$((exist+1))" > /tmp/import_stats
                    continue
                fi

                ((current_file++))
                echo "$((current_file * 100 / total_files))"
                echo "# Testing: $filename"

                if test_screensaver "$full_path"; then
                    cp -vn "$full_path" "$SCR_DEST/${target_name,,}"
                    IFS=":" read -r imp skip exist < /tmp/import_stats
                    echo "$((imp+1)):$skip:$exist" > /tmp/import_stats
                else
                    IFS=":" read -r imp skip exist < /tmp/import_stats
                    echo "$imp:$((skip+1)):$exist" > /tmp/import_stats
                fi
            done < <(find "$SCR_SOURCE" -maxdepth 1 -iname "*.scr" -print0)
        ) | zenity --progress --title="Importing & Testing" --text="Validating..." --percentage=0 --auto-close

        IFS=":" read -r imported skipped existing < /tmp/import_stats
        rm -f /tmp/import_stats

        # Final Summary
        zenity --info --title="Import Summary" \
            --text="Process complete!\n\nImported: $imported\nSkipped: $skipped\nAlready Installed: $existing" \
            --width=300
    fi
fi

relaunch_menu
exit 0
