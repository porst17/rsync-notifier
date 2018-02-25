#!/usr/bin/env bash

set -x

SELFDIR=`dirname "$0"`
SELFDIR=`cd "$SELFDIR" && pwd`
cd "$SELFDIR"

USERNAME=backup

export MINUTES_BEFORE_FIRST_BACKUPS=10
export MINUTES_BETWEEN_BACKUPS=$((60 * 3))
export RSYNC_SRC=`cd ~ && pwd`/
export RSYNC_DEST="diskstation:/volume1/$USERNAME/$RSYNC_SRC"
export RSYNC_SSH_COMMAND="ssh -l $USERNAME"
export RSYNC_LOG_FILE=$RSYNC_SRC"rsync_notifier.log"
export RSYNC_EXCLUDE_FROM="exclude.txt"

$SELFDIR/rsync-notifier.sh
