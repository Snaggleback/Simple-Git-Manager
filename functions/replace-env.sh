#!/bin/bash

replace_env() {
    local path="$1"
    path="${path/'$HOME'/$HOME}"
    path="${path/'~'/$HOME}"
    echo "${path}"
}
