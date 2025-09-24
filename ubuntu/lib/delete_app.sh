#!/bin/bash

APP_NAME="git-utility"
BIN_DIR="/usr/local/bin"   # or use ~/bin for user-only
LIB_DIR="/usr/local/lib/$APP_NAME"

sudo rm -rf $BIN_DIR/$APP_NAME
sudo rm -rf $LIB_DIR

echo "$APP_NAME removed successfully!"
exit 0
