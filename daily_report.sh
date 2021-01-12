#!/bin/bash

# This use https://github.com/matsuro-hadouken/debian-scripts/tree/master/telegram for notifications.
# Is ultimate solution written by 'Nicolas Bernaerts' https://github.com/NicolasBernaerts and absolute requirement.

# Do not run this as root, this can mess up permissions in ledger and bring to weird consequences which is very hard to debug later.
# Run this as appropriate user for example 'solanaman' or who run unit in your configuration.

# This script require allot of permissions to be configured properly and should be run from crontab from right user. This is not out of the box solution.
# Cron example: '0 * * * *     cd /usr/local/bin/ && bash daily_statistics.sh > /dev/null 2>&1'

# Solana is complex thing, 'running anything extra on validator side can lead to allot of butt hurt' 

validator="" # Validator ID

HOST_ID="☘ My Super Node ☘"

PARTITION_NAME="vg-root" # root partition or whatever 'df -h'

export PATH=$PATH:/usr/local/bin # Path to telegram-notify

export PATH=/home/solana/target/bin # Path to solana binary

function BlockProduction() {

    read -r -a arr1 < <(echo $(solana block-production --url http://127.0.0.1:8899 | grep "$validator" | tr -d '%') | cut -d' ' -f2-)

    leader_slots="${arr1[0]}"
    blocks_produced="${arr1[1]}"
    skipped_slots="${arr1[2]}"
    skipped_slot_precentage="${arr1[3]} %"

    echo "$HOST_ID" >>"$TMP_FILE" && echo >>"$TMP_FILE"
    echo "➡️️ Skip rate: $skipped_slot_precentage" >>"$TMP_FILE"
    echo >>"$TMP_FILE"

    echo "Leader slots: $leader_slots" >>"$TMP_FILE"
    echo "Produced blocks: $blocks_produced" >>"$TMP_FILE"
    echo "Skipped slots: $skipped_slots" >>"$TMP_FILE"
    echo >>"$TMP_FILE"
}

function DiskSpace() {

    read -r -a arr2 < <(df -BG | grep "$PARTITION_NAME" | cut -d' ' -f2-)

    disk_used="${arr2[1]}"
    disk_available="${arr2[2]}"
    disk_use_precentage="${arr2[3]}"

    echo "Used: $disk_used" >>"$TMP_FILE"
    echo "Available: $disk_available" >>"$TMP_FILE"
    echo "Used precentage: $disk_use_precentage" >>"$TMP_FILE"
    echo >>"$TMP_FILE"
}

function MemoryUsage() {

    read -r -a arr3 < <(free -h | grep 'Mem' | cut -d' ' -f2- | tr -d 'i')

    # memory_total="${arr3[0]}"
    memory_used="${arr3[1]}"
    memory_free="${arr3[2]}"
    memory_shared="${arr3[3]}"
    memory_buffer_cache="${arr3[4]}"
    memory_available="${arr3[5]}"

    # echo "Total: $memory_total" >>"$TMP_FILE"
    echo "Used: $memory_used" >>"$TMP_FILE"
    echo "Free: $memory_free" >>"$TMP_FILE"
    echo "Shared: $memory_shared" >>"$TMP_FILE"
    echo "Bufer Cache: $memory_buffer_cache" >>"$TMP_FILE"
    echo "Available: $memory_available" >>"$TMP_FILE"
    echo >>"$TMP_FILE"
}

trap 'rm -f "$TMP_FILE"' EXIT
TMP_FILE=$(mktemp -t t_report.XXXXXXX) || exit 1

time_stamp=$(date "+%Y.%m.%d-%H:%M:%S %Z")

echo "$time_stamp" >"$TMP_FILE" && echo >>"$TMP_FILE"

BlockProduction

echo "▪️ disk »" >>"$TMP_FILE" && echo >>"$TMP_FILE"

DiskSpace

echo "▪️ memory »" >>"$TMP_FILE" && echo >>"$TMP_FILE"

MemoryUsage

telegram-notify --success --text "Report:" --file "$TMP_FILE" # thie need telegram-notify
