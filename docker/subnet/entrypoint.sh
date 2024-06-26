#!/bin/bash

# Import shared functions
source functions.sh

# Create and fund owner wallets
#
# Create a new coldkey with the specified password
echo -e "$COLDKEY_PASSWORD\n$COLDKEY_PASSWORD" | btcli wallet new_coldkey --wallet.name owner --wallet.password

# Create a new hotkey with the specified password
echo -e "$HOTKEY_PASSWORD\n$HOTKEY_PASSWORD" | btcli wallet new_hotkey --wallet.name owner --wallet.hotkey miner_hotkey --wallet.password

# Use the faucet for the owner wallet multiple times to get enough tTAO to register a subnet
for i in {1..4}; do
    run_faucet owner || { echo "Faucet $i failed for owner wallet"; exit 1; }
done

echo -e "Owner faucet has run 4 times, now has 1200 τTAO"

# Register / Create a Subnet using expect to handle the interactive prompt and password
expect << EOF
log_user 1
spawn btcli subnet create --wallet.name owner --subtensor.chain_endpoint ws://subtensor_machine:9945
expect {
    "Do you want to register a subnet for" {
        send "y\r"
        exp_continue
    }
    "Enter password to unlock key:" {
        send "$COLDKEY_PASSWORD\r"
        exp_continue
    }
    eof
}
EOF
sleep 10
btcli subnet list --subtensor.chain_endpoint ws://subtensor_machine:9945


tail -f /dev/null