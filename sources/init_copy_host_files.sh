#!/bin/bash
#==================== Configuration ========================#
# Configuration generale
. /massa-guard/config/default_config.ini
# Import custom library
. /massa-guard/sources/lib.sh

## Copy/refresh massa_mount wallet and config files if exists
if [ $IP ]; then
	myIP=$IP
else
	myIP=$(GetPublicIP)
fi
# Conf node file
if [ -e $PATH_MOUNT/config.toml ]
then
	cp $PATH_MOUNT/config.toml $PATH_NODE_CONF/config.toml
	green "INFO" "Load $PATH_MOUNT/config.toml"

# If ref config.toml dont exist in massa_mount
else

	echo "[protocol]" > $PATH_MOUNT/config.toml
	echo "routable_ip = \"$myIP\"" >> $PATH_MOUNT/config.toml
	cp $PATH_MOUNT/config.toml $PATH_NODE_CONF/config.toml

	green "INFO" "Create your default config.toml with $myIP as routable IP"
fi

# Custom node config
if [ -e $PATH_MOUNT/node_config_$VERSION.toml ]
then
	cp $PATH_MOUNT/node_config_$VERSION.toml $PATH_NODE/base_config/config.toml
	green "INFO" "Load $PATH_MOUNT/node_config_$VERSION.toml"
else
	# Set bootstrap mode to ipv4 only
	toml set --toml-path $PATH_NODE/base_config/config.toml bootstrap.bootstrap_protocol "IPv4"
	cp $PATH_NODE/base_config/config.toml $PATH_MOUNT/node_config_$VERSION.toml
fi

# Wallet to use
if [ -e $PATH_MOUNT/wallet_* ]
then
	cp $PATH_MOUNT/wallet_* $PATH_CLIENT/wallets/
	green "INFO" "Load wallet from massa_mount to client"
fi
