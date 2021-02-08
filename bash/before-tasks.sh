#!/bin/bash

# Gitpod currently does not persist files in the home directory so we must write them 
# in everytime the workspace starts. We do this in the  -before task in .gitpod.yml

# Log to the console and a file
log () {
  if [ -z "$2" ]; then
    bash bash/utils.sh log "$1" /var/log/workspace-init.log
  else
    bash bash/utils.sh log "$1" /var/log/workspace-init.log -e
  fi
}

# Log only to a file
log_silent () {
  if [ -z "$2" ]; then
    bash bash/utils.sh log_silent "$1" /var/log/workspace-init.log
  else
    bash bash/utils.sh log_silent "$1" /var/log/workspace-init.log -e
  fi
}

# Hack: Persist any important files outside of /workspace
bash bash/helpers.sh persist_file /var/log/workspace-image.log
bash bash/helpers.sh persist_file /var/log/workspace-init.log

# Rake tasks (will be written to ~/.rake).
# Some rake tasks are dynamic and depend on the configuration in starter.ini
msg="Writing rake tasks"
log "$msg" &&
bash bash/init-rake-tasks.sh

# Aliases for git
msg="Writing git aliases"
log "$msg" &&
bash bash/utils.sh add_file_to_file_after \\[alias\\] bash/snippets/emoji-log ~/.gitconfig &&
bash bash/utils.sh add_file_to_file_after \\[alias\\] bash/snippets/git-aliases ~/.gitconfig &&
log "try: git a    or: git aliases    for a list your git aliases.\n"