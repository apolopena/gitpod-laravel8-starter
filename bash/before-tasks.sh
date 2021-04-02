#!/bin/bash
#
# SPDX-License-Identifier: MIT
# Copyright © 2021 Apolo Pena
#
# before-tasks.sh
# Description:
# Tasks that should be run everytime the worspace is created or started.
# 
# Notes:
# Gitpod currently does not persist files in the home directory so we must write them 
# in everytime the workspace starts. We do this in the 'before' task in .gitpod.yml

# Load logger
. bash/workspace-init-logger.sh

# Rake tasks (will be written to ~/.rake).
# Some rake tasks are dynamic and depend on the configuration in starter.ini
if [[ $(bash bash/utils.sh parse_ini_value starter.ini github-changelog-generator install) ]]; then
  msg="Writing rake tasks"
  log_silent "$msg" &&
  if bash bash/init-rake-tasks.sh; then 
    log_silent "SUCCESS: $msg"
  else
    log -e "ERROR: $msg"
  fi
fi

# Aliases for git
msg="git aliases have been written"
bash bash/utils.sh add_file_to_file_after "\\[alias\\]" bash/snippets/emoji-log ~/.gitconfig &&
bash bash/utils.sh add_file_to_file_after "\\[alias\\]" bash/snippets/git-aliases ~/.gitconfig &&
log_silent "$msg" &&
log_silent "try: git a    or: git aliases to see what is available."

# Restore files marked as persistant such as workspace-init.log
# See persist_file in bash/helpers.sh for how to system works
# Keep this block at the bottom of the file so that any logging from this
# script is only written to file upon initialization! Otherwise workspace-init.log 
# will get written to from this script upon every workspace restart.
if [[ $(bash bash/helpers.sh is_inited) == 1 ]]; then
  bash bash/helpers.sh restore_persistent_files "$GITPOD_REPO_ROOT"
fi