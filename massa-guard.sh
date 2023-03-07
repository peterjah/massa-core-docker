#!/bin/bash
#====================== Configuration ==========================#
# Global configuration
. /massa-guard/config/default_config.ini
# Import custom library
. /massa-guard/sources/lib.sh

echo "TOML PARSED!! PATH_NODE_CONF= $PATH_NODE_CONF"
# toml --help

# TOML=$(toml get --toml-path $PATH_NODE_CONF/config.toml network.routable_ip)
# echo "TOML PARSED!! $TOML"
# Wait node booststrap
WaitBootstrap

#====================== Check and load ==========================#
# Load Wallet and Node key or create it and stake wallet
CheckOrCreateWalletAndNodeKey
# Get stacking address
WalletAddress=$(GetWalletAddress)


if [ ! $DISCORD == "NULL" ]; then
	# Check and get faucet of current day
	PingFaucet
fi

IS_ACTIVATED="${MASSAGUARD:-"1"}"
DYNIP="${DYNIP:-"0"}"
NODE_TESTNET_REGISTRATION="${NODE_TESTNET_REGISTRATION:-"KO"}"
TARGET_ROLL_AMOUNT="${TARGET_ROLL_AMOUNT:-"NULL"}"

#==================== Massa-guard circle =========================# 
# Infinite check
while true
do
	# If massa-guard features enabled
	if [ "$IS_ACTIVATED" == "1" ]
	then

		# Check node status
		CheckNodeResponsive
		NodeResponsive=$?

		# Check ram consumption percent in integer
		CheckNodeRam

		NodeRam=$?

		# Restart node if issue
		CheckAndReloadNode "$NodeRam" "$NodeResponsive"
		if [ $? -eq 0 ]
		then
			# Get candidate rolls
			CandidateRolls=$(GetCandidateRoll "$WalletAddress")
			# Get MAS amount
			MasBalance=$(GetMASAmount "$WalletAddress")
			# Buy max roll or 1 roll if possible when candidate roll amount = 0
			BuyOrSellRoll "$CandidateRolls" "$MasBalance" "$WalletAddress"

			# If Discord feature enable
			if [ ! $DISCORD == "NULL" ]
			then
				# Check and registrer node with massabot if necessary
				CheckTestnetNodeRegistration "$WalletAddress"

				# If dynamical IP feature enable and public IP is new
				if ([ "$DYNIP" == "1" ] && [ $(CheckPublicIP) -eq 1 ])
				then
					# Refresh config.toml + restart node + push new IP to massabot
					RefreshPublicIP
				fi
			fi
		fi
	fi
	# Wait before next loop
	sleep 2m
done
