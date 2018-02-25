#!/usr/bin/env bash

set -x

sleep "${MINUTES_BEFORE_FIRST_BACKUPS}m"

while true; do

    SECONDS_BEFORE=$(date "+%s")
    zenity --question --text "Time for a backup!\n\nStart now?"

    if [ $? -eq 0 ]; then
	RSYNC_PIPE_FILE=$(mktemp -u)
        mkfifo $RSYNC_PIPE_FILE

        zenity --progress --title "Backing up ..." \
            --text="Scanning..." --percentage=0 --auto-kill < $RSYNC_PIPE_FILE &
        ZENITY_PID=$!

        rsync \
            --progress \
            -azH --no-o --no-g \
            --partial \
            --partial-dir=.rsync-partial \
            --delete-delay \
            --exclude-from="$RSYNC_EXCLUDE_FROM" \
            "--log-file=$RSYNC_LOG_FILE" \
            -e "$RSYNC_SSH_COMMAND" \
            "$RSYNC_SRC" \
            "$RSYNC_DEST" | \
            awk -f rsync2zenity.awk | \
            awk '{gsub(/.{100}/,"&\\n")}1' > $RSYNC_PIPE_FILE
        RSYNC_EXIT_CODE=${PIPESTATUS[0]}

        kill $ZENITY_PID

	rm $RSYNC_PIPE_FILE

        if [ $RSYNC_EXIT_CODE -eq 0 ]; then
            notify-send "Backup complete"
        else
            zenity --error --title "Backup error" --text "Please check the log file:\n$RSYNC_LOG_FILE"
        fi
    fi

    SECONDS_AFTER=$(date "+%s")
    DURATION=$((TIME_BEFORE - TIME_AFTER))

    SECONDS_LEFT=$((MINUTES_BETWEEN_BACKUPS * 60 - DURATION))

    sleep $SECONDS_LEFT

done
