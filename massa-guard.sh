#!/bin/bash
# Import custom library
. /massa-guard/sources/lib.sh

# Consecutive failed health checks before the node is restarted. One slow
# answer is not worth a restart: every restart forces a full re-bootstrap, and
# the official bootstrap servers then rate-limit us for hours.
UNRESPONSIVE_THRESHOLD=${UNRESPONSIVE_THRESHOLD:-3}

# Grace period after bootstrap, while the node replays the slots it missed and
# is at its least responsive.
BOOTSTRAP_GRACE=${BOOTSTRAP_GRACE:-300}

WaitBootstrap

#====================== Check and load ==========================#
# Load Wallet and Node key or create it and stake wallet
CheckOrCreateWalletAndNodeKey

green "INFO" "Health checks start in ${BOOTSTRAP_GRACE}s (post-bootstrap catch-up)"
sleep ${BOOTSTRAP_GRACE}s

#==================== Massa-guard circle =========================#
unresponsiveCount=0

# Infinite check
while true; do

	# Check node status
	CheckNodeResponsive
	NodeResponsive=$?

	# Check ram consumption percent in integer
	CheckNodeRam
	ramCheck=$?

	if [[ $NodeResponsive -eq 1 ]]; then
		unresponsiveCount=$((unresponsiveCount + 1))
		warn "WARN" "Health check failed ($unresponsiveCount/$UNRESPONSIVE_THRESHOLD): $NODE_STATUS_ERROR"
	else
		if [[ $unresponsiveCount -gt 0 ]]; then
			green "INFO" "Node is responsive again after $unresponsiveCount failed check(s)"
		fi
		unresponsiveCount=0
	fi

	# Restart node if issue
	if [[ $unresponsiveCount -ge $UNRESPONSIVE_THRESHOLD || $ramCheck -eq 1 ]]; then
		warn "ERROR" "Restarting node after $unresponsiveCount consecutive failed check(s)"
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
