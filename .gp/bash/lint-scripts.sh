#!/bin/bash
#
# SPDX-License-Identifier: MIT
# Copyright © 2021 Apolo Pena
#
# lint-scripts.sh
# Description:
# Finds all .sh files that the starter uses, runs them through shellcheck and
# outputs a simple success summary or just the standard output if shellcheck 
# finds anything that needs attention. 
#
# Note: 
# Pass in an optional -V or --verbose if you would like to output a list of the files being checked

path() {
  if [[ -z $GITPOD_REPO_ROOT ]]; then
    echo '.gp'
  else
    echo "$GITPOD_REPO_ROOT/.gp"
  fi
}

list_all_scripts() {
  find "$(path)" -type d \( -name node_modules \) -prune -false -o -name "*.sh"
}

script_total() {
  list_all_scripts | wc -l
}

main() {
  local total result skip skip_msg
  if [[ $1 == '-V' || $1 == '--verbose' ]]; then
    echo -e "\e[38;5;87mRunning all starter scripts through shellcheck\e[0m"
    echo -ne "\e[38;5;45m"
    list_all_scripts;  echo -ne "\e[0m"
  fi
  total=$(script_total)
  (( total == 0 )) && echo -e "\e[38;5;124mInternal Error:\e[0m no scripts found to lint" && exit 1
  if [[ ! -e $(pwd)/.gp ]]; then
    skip_msg="\e[38;5;208mWARNING: You did not lint the starter scripts from the project root so shellcheck error \e[0mSC1091\e[38;5;208m was be excluded.\e[0m"
    skip='-e SC1091'
  fi
  result=$(find "$(path)" -type d \( -name node_modules \) -prune -false -o -name "*.sh" -exec shellcheck -x -P "$(path)" $skip {} \; | tee >(wc -l))
  if [[ $result == 0 ]]; then
    [[ -n $skip_msg ]] && echo -e "$skip_msg"
    echo -e "\e[38;5;76mSUCCESS:\e[0m \e[38;5;40mall \e[0;36m$total\e[0m \e[38;5;40mscripts in the system passed the shellcheck.\e[0m"
    exit
  fi
  find "$(path)" -type d \( -name node_modules \) -prune -false -o -name "*.sh" -exec shellcheck -x -P "$(path)" $skip {} \;
  [[ -n $skip_msg ]] && echo -e "$skip_msg"
}

main "$1"
