#!/bin/bash

# clear && echo

STAKING_PATH='./path/to/keys/' # path to keys

Owner="$STAKING_PATH/owned.input.json"

stakeAuthority="$STAKING_PATH/stakeAuthorityjson"
withdrawAuthority="$STAKING_PATH/withdrawAuthority.json"
feePayer="$STAKING_PATH/feePayer.json"

STAKING_ACCOUNT="$STAKING_PATH/StakingAccount.json"

VALIDATOR='BEFSdm32yAzSDcGe3JB5jRhMB4dG1Mf47GP4ymXud3kw'

AMOUNT='5000' # how much coins to stake
WithdrawAmount='5' # for withdraw

# --------------------------------------------------------------

STAKING_ACCOUNT_ADDRESS=$(solana-keygen pubkey $STAKING_ACCOUNT)

function get_clue() {

    echo "Delegator:                $(solana-keygen pubkey $Owner)"
    echo "Stake Authority:          $(solana-keygen pubkey $stakeAuthority)"
    echo "Withdraw Authority:       $(solana-keygen pubkey $withdrawAuthority)"
    echo "Fee Payer:                $(solana-keygen pubkey $feePayer)" && echo

    echo "Staking Account:          $(solana-keygen pubkey $STAKING_ACCOUNT)" && echo

    echo "Staking account address:  $STAKING_ACCOUNT_ADDRESS" && echo
    echo "Validator voting address: $VALIDATOR" && echo
    echo "Staking amount:           $AMOUNT"

}

function activate_staking_account() {

    solana create-stake-account --from $Owner $STAKING_ACCOUNT "$AMOUNT" \
        --stake-authority $stakeAuthority --withdraw-authority $withdrawAuthority \
        --fee-payer $feePayer

}

function stake_on_validator() {

    solana delegate-stake --stake-authority $stakeAuthority $STAKING_ACCOUNT_ADDRESS $VALIDATOR \
        --fee-payer $feePayer

}

function undelegate() {

    solana deactivate-stake --stake-authority $stakeAuthority $STAKING_ACCOUNT_ADDRESS $VALIDATOR \
        --fee-payer $feePayer

}

function withdraw() {

    solana withdraw-stake --withdraw-authority $stakeAuthority $STAKING_ACCOUNT_ADDRESS $VALIDATOR $Owner $WithdrawAmount \
        --fee-payer $feePayer

}

function changeValidator() {

    solana split-stake --stake-authority $stakeAuthority $STAKING_ACCOUNT_ADDRESS \
        --fee-payer $feePayer <NEW_STAKE_ACCOUNT_KEYPAIR >$AMOUNT

}

get_clue

activate_staking_account # THIS IS ONLY NEED TO RUN ONCE FOR ACTIVATING STAKING ACCOUNT, KEYS WILL BE REVOCED AFTER THE PROCESS: https://docs.solana.com/staking/stake-accounts#account-address

stake_on_validator

solana stake-account "$STAKING_ACCOUNT_ADDRESS"
