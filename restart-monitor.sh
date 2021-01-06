#!/bin/bash

# This use https://github.com/matsuro-hadouken/debian-scripts/tree/master/telegram for notifications.
# Is ultimate solution written by 'Nicolas Bernaerts' https://github.com/NicolasBernaerts and absolute requirement.

# 'SETUP' uncomment like 31 and run it once to populate database. Comment after it.
# Run from cron: * * * * *     cd /usr/local/bin/ && bash restart-monitor.sh > /dev/null 2>&1

unit_name='solana' # unit to monitor
restart_db='/usr/local/bin/db.restart' # we will store here last restart for comparison

export PATH=$PATH:/usr/local/bin # path to telegram-notify, cron stupid by default

function CheckRestart() {

  LAST_RESTART=$(systemctl show "$unit_name" --property=ActiveEnterTimestamp | sed 's/^[^=]*=//' | tr -d 'UTC')

  PREV_RESTART=$(cat "$restart_db")

  if ! [[ "$LAST_RESTART" =~ $PREV_RESTART ]]; then

    telegram-notify --error --text "ERROR: Solana restart $PREV_RESTART - $LAST_RESTART"
    echo "$LAST_RESTART" >"$restart_db"

    sleep 5

  fi

}

# uncomment for setup:
# systemctl show "$unit_name" --property=ActiveEnterTimestamp | sed 's/^[^=]*=//' | tr -d 'UTC' >"$restart_db"

CheckRestart
