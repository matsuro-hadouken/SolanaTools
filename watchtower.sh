#!/bin/bash

set -ex

export TELEGRAM_BOT_TOKEN=''
export TELEGRAM_CHAT_ID=-''

args=(
    --validator-identity ""
    --no-duplicate-notifications
    --url "http://localhost:8899"
)

exec solana-watchtower "${args[@]}"
