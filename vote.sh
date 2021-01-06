#!/bin/bash

# Requirements:

# Rust need to be updated to 'minimum 1.4.7' ( 'rustup update' ), check: 'cargo --version'
# Install spl feature: 'cargo install spl-feature-proposal-cli'

vote_spl='123'                # How much tokens spend for vote

mint_address=' '                 # Tokens been minted for specific proposal
acceptance_proposal_address=' '  # This is apparently target for vote
lookup_address='  '              # Lookup address

OWNER='identity.json'            # Owner key

ENDPOINT='https://api.mainnet-beta.solana.com/' # endpoint

# --------------------------------------------------------

echo && echo "Using mint address: $mint_address" && echo

echo "Quety vote token address and balance ..." && echo

# First look up your pico-inflation SPL vote token address via:

X_VoteTokenAddress=$(spl-token --owner "$OWNER" accounts "$mint_address" --url "$ENDPOINT" | tail -1)

VoteTokenAddress=$(echo "$X_VoteTokenAddress" | cut -d ' ' -f 1)
VoteTokensAmount=$(echo "$X_VoteTokenAddress" | cut -d ' ' -f 2)

echo "Vote token address: $VoteTokenAddress"
echo "Vote tokens amount: $VoteTokensAmount"

echo && echo "Broadcasting vote deploy, SPL used $vote_spl ..." && echo

# Validators can submit their vote by sending some or all of the SPL tokens in their ownership to the pico-inflation testnet acceptance
# address: '$acceptance_proposal_address'. This is done via:

spl-token --owner "$OWNER" transfer "$VoteTokenAddress" "$vote_spl" "$acceptance_proposal_address" --fee-payer "$OWNER" --url "$ENDPOINT"

echo "Query current proposals statuses ..." && echo

# count votes: ( what a fuck is this address where he come from ? )

spl-feature-proposal tally "$lookup_address"

echo
