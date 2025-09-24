#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'


install_repository(){
    source /usr/local/lib/git-utility/install_repository.sh
}

pull_repository(){
    source /usr/local/lib/git-utility/pull_repository.sh
}

push_repository(){
    source /usr/local/lib/git-utility/push_repository.sh
}

exit_program() {
    echo "Exiting program."
    exit 0
}

config_git() {
    source /usr/local/lib/git-utility/config_git.sh
}


delete_app() {
    source /usr/local/lib/git-utility/delete_app.sh
}

clean_history() {
    source /usr/local/lib/git-utility/clean_history.sh
}



# Example utility function
log_info() {
    echo "[INFO] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
}