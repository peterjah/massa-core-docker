#!/bin/bash

# Import custom library
. /massa-guard/sources/lib.sh

export DYNIP="${DYNIP:-0}"
export TARGET_ROLL_AMOUNT="${TARGET_ROLL_AMOUNT:-0}"
export MINIMAL_FEE="${MINIMAL_FEE:-0}"

/massa-guard/sources/init_copy_host_files.sh

if [ "$?" = 1 ]; then
    warn "ERROR" "Initialization failed. Exiting..."
    exit 1
fi

/massa-guard/massa-guard.sh &

# Launch node
cd $PATH_NODE
./massa-node -a -p $WALLETPWD
