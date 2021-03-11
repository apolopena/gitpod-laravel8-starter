#!/bin/bash

# helpers.sh
# Author: Apolo Pena
# Description: A variety of useful functions with that depend on gitpod
# and other binaries, aliases and functions such as code in .bashrc
# other than coreutils.
# Note: Do not execute this script witout calling a function from it
# Additional Note: some functions use functions from .bashrc so the -i flag
# is the safest way to invoke functions from this script.
#
# Usage: bash -i <function name> arg1 arg2 arg3 ...
#

version () {
  echo "helpers.sh version 0.0.4"
}

# start_server
# Description:
# Starts up the default server or a specific server ($1)
#
# Notes:
# It is assumed that starter.ini is in the project root.
# Valid servers are: apache, php
#
# Usage:
# Example: start the default server
# start_server
start_server() {
  local usage='Usage: start_server [server-type]'
  local err='Error: start_server():'
  local server
  local s
  s=$(bash bash/utils.sh parse_ini_value starter.ini development default_server)
  # Bump the value of the default_server in starter.ini to lowercase
  server=$(echo "$s" | tr '[:upper:]' '[:lower:]')
  if [ -z "$1" ]; then
  case "$server" in
    'php')
    start_php_dev
    ;;
    'apache')
    start_apache
    ;;
    *)
    echo "$err invalid default server: $server. Check the file $GITPOD_REPO_ROOT/starter.ini"
    ;;
  esac
  else
  echo $(echo "$1" | tr '[:upper:]' '[:lower:]')
  case $(echo "$1" | tr '[:upper:]' '[:lower:]') in
    'php')
    start_php_dev
    ;;
    'apache')
    start_apache
    ;;
    *)
    echo "$err invalid server type: $1"
    ;;
  esac
  fi
}

# add_global_rake_task
# Description:
# Writes a rake task multiline string ($1) to a file named by the command ($2) in ~/.rake
#
# Notes:
# Depending on how the task is written you may need to
# invoke a global rake task using the -g flag like so: rake -g hello-world
# Do not use the .rake suffic in your command. The rake file name will
# automatically written as to "$2.rake"
# Any exisitng rake command in ~/.rake will be clobbered.
#
# Usage:
# Example: a dynamically created hello world rake task
# # create a safe multiline string (with variable interpolation) to pass to add_global_rake_task
# name='Apolo'
# rake_task_name='hello'
# IFS='' read -r -d '' __task <<EOF
# task "$rake_task_name" do
#    puts "Hello $name, this is a global rake task"
# end
# EOF
# bash bash/helpers.sh add_global_rake_task "$__task" "$rake_task_name"
add_global_rake_task() {
  local root=~/.rake
  local file="$2.rake"
  local err="Helpers.sh: Error: add_global_rake_task:"
  local usage="Usage: add_global_rake_task task file.rake"

  [[ -z $1 || -z $2 ]] && echo "$err requires exactly two arguments." && echo $usage && return

  mkdir -p $root
  touch -c "$root/$2"
  echo -e "$1" > "$root/$file"
}

# show_first_run_logs
# Description:
# Outputs a summarized and colorized dump of /var/log/workspace-image.log
# and /var/log/workspace-init.log
#
# Usage:
# show_first_run_summary
show_first_run_summary() {
  workspace_log='/var/log/workspace-image.log'
  init_log='/var/log/workspace-init.log'
  echo -e "\n\e[38;5;171mSUMMARY 👀\e[0m\n"
  echo -en "\e[38;5;194mResults of building the workspace image\e[0m \e[38;5;34m$workspace_log\e[0m ➥\n\e[38;5;183m"
  cat $workspace_log
  echo -en "\e[0m"
  echo ''
  echo -en "\e[38;5;194mResults of the gitpod initialization\e[0m \e[38;5;34m$init_log\e[0m ➥\e[38;5;39m"
  echo ''
  cat $init_log
  echo -en "\e[0m"
  echo -en "\n\e[38;5;171mALL DONE 🚀\e[0m\n"
}

# Begin: persistance hacks
get_store_root() {
  echo "/workspace/$(basename $GITPOD_REPO_ROOT)--store"
}

persist_file() {
  local err="helpers.sh: persist: error:"
  local store=$(get_store_root)
  local dest="$store/$(dirname ${1#/})"
  local file="$dest/$(basename "$1")"
  mkdir -p $store && mkdir -p $dest
  [ -f $1 ] && cp $1 $file || echo "$err $1 does not exist"
}

# For some reason $GITPOD_REPO_ROOT is not avaialable when this is called (from before task)
# So just pass it in from there as $1
restore_persistent_files() {
  local err="helpers.sh: restore_persistent_files: error:"
  # TODO make this dynamic
  local init_log_orig=/var/log/workspace-init.log
  local store="/workspace/$(basename $1)--store"
  local init_log="$store$init_log_orig"
  [ -e $init_log ] && cp $init_log $init_log_orig || echo "$err $init_log NOT FOUND"
}

inited_file () {
  echo "$(get_store_root)/is_inited.lock"
}

mark_as_inited() {
  local file=$(inited_file)
  local store=$(get_store_root)
  mkdir -p $(get_store_root)
  [ ! -e $file ] && touch $file
}

is_inited() {
  [ -e $(inited_file) ] && echo 1 || echo 0
}
# End: persistance hacks

# Begin: installation information API
# parses starter.ini for installation for the install key of a section ($1)
get_install() {
  echo "$(bash bash/utils.sh parse_ini_value starter.ini $1 install)"
}

# parses starter.ini and echos a string showing installtaion information for any installs key in the list.
# The install key list is set in this function. The install key list is order specific.
# phpmyadmin needs to be first, the next three installs are the frontend scaffolding installs.
# You can add any additional installs to the end of this string delimited by a space character.
get_installs() {
  # Space delimited list of installs to check
  # starter.ini must have a section named by the string and a key named install
  # So not change the order of installs in this string, just add more to the end if needed
  local installs='phpmyadmin react vue bootstrap'
  for i in $installs; do
    data+=$i:$(get_install $i)
  done
  echo $data
}

# parses starter.ini for installation information
# Echos 1 if any install key in list (see installs varaible in get_install function) in starter.ini
# has a value of 1.
# Echos 0 if no keys in the list have a value of 1 
has_installs() {
  local result=$(echo $(get_installs) | grep -oP '\d' | tr -d '[:space:]')
  local pattern='.*[1-9].*'
  if [[ $result =~ $pattern ]]; then 
    echo 1
  else
    echo 0
  fi
}

# parses starter.ini for installation information
# Echos 1 if the install key for phpmyadmin is set to 1 and no frontend scaffolding keys are set to 1
# There are three possible frontend scaffolding keys: react, vue and bootstrap
# Echos 0 if the install key for phpmyadmin is not set to 1 or if it is set to 0 but any frontend
# scaffolding key is set to 1
has_only_phpmyadmin_install() {
  local result=$(echo $(get_installs) | grep -oP '\d' | tr -d '[:space:]')
  local all_zeros='^0$|^0*0$'
  # if the string starts with a 1 phpmyadmin is installed
  if [[ $result =~ ^1 ]]; then 
    # trim the first character from the string
    local installs="${result:1}"
    # if the trimmed string is all zeros
    if [[ $installs =~ $all_zeros ]]; then
      # only phpmyadmin is installed
      echo 1
    else
      # phpmyadmin is not the only install
      echo 0
    fi
  else
    # phpmyadmin is not the only install
    echo 0
  fi
}

# parses starter.ini for installation information
# Echos 1 if the install key for phpmyadmin is set to 0 and any frontend scaffolding key is set to 1
# There are three possible frontend scaffolding keys: react, vue and bootstrap
# Echos 0 if the install key for phpmyadmin is set to 1 and any frontend scaffolding key is set to 1
has_only_frontend_scaffolding_install() {
  local result=$(echo $(get_installs) | grep -oP '\d' | tr -d '[:space:]')
  local all_zeros='^0$|^0*0$'
  # if the string starts with a 0 phpmyadmin is not installed
  if [[ $result =~ ^0 ]]; then 
    # trim the first character from the string
    local installs="${result:1}"
     # Trim the next three characters in the string (there are only three possible front end scaffolding)
     # and gnore any other installs besides front end scaffolding and phpmyadmin (the rest of the string)
    local scaff_installs=$(echo ${installs:0:3})
    # if the trimmed string is all zeros
    if [[ $scaff_installs =~ $all_zeros ]]; then
      # no frontend scaffolding is installed
      echo 0
    else
      # only frontend scaffolding is installed
      echo 1
    fi
  else
    # More than frontend scaffolding is installed
    echo 0
  fi
}

# parses starter.ini for installation information
# Echos 1 if the install key either react, vue or bootrap is set to 1
# There are three possible frontend scaffolding keys: react, vue and bootstrap
# Echos 0 if neither react, vue or bootrap has an install key value of 1
has_frontend_scaffolding_install() {
  local result=$(echo $(get_installs) | grep -oP '\d' | tr -d '[:space:]')
  local all_zeros='^0$|^0*0$'
  # Trim the first character from the string (this is the phpmyadmin value)
  local installs="${result:1}"
  # Trim the next three characters in the string (there are only three possible front end scaffolding)
  local scaff_installs=$(echo ${installs:0:3})
  if [[ $scaff_installs =~ $all_zeros ]]; then
    echo 0
  else
    echo 1
  fi
}
# End: installation information API

# Call functions from this script gracefully
if declare -f "$1" > /dev/null
then
  # call arguments verbatim
  "$@"
else
  echo "helpers.sh: '$1' is not a known function name." >&2
  exit 1
fi
