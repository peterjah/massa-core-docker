#!/bin/bash

# Shorcut to use massa-client from outside of the container
cd $PATH_CLIENT
./massa-client -p $WALLETPWD "$@"