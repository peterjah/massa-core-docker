#!/bin/bash
# Import custom library
. /massa-guard/sources/lib.sh

WaitBootstrap

#====================== Check and load ==========================#
# Load Wallet and Node key or create it and stake wallet
CheckOrCreateWalletAndNodeKey

#==================== Massa-guard circle =========================#
# Infinite check
while true; do

	# Check node status
	CheckNodeResponsive
	NodeResponsive=$?

	# Check ram consumption percent in integer
	CheckNodeRam
	ramCheck=$?

	# Restart node if issue
	if [[ $NodeResponsive -eq 1 || $ramCheck -eq 1 ]]; then
		RestartNode
		exit
	fi

	# Buy max roll or 1 roll if possible when candidate roll amount = 0
	BuyOrSellRoll

	# If dynamical IP feature enable and public IP is new
	if [[ "$DYNIP" == "1" ]]; then

		CheckPublicIP
		publicIpChanged=$?
		if [[ $publicIpChanged -eq 1 ]]; then
			# Refresh config.toml + restart node
			RefreshPublicIP
		fi
	fi

	sleep 2m
done
