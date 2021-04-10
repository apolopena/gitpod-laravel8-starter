# shellcheck shell=bash
# This file is sourced into ~/.bashrc
# Add any alias you would like here

alias lint-starter-scripts='find "$GITPOD_REPO_ROOT/.gp" -type d \( -name node_modules \) -prune -false -o -name "*.sh" -exec shellcheck -x -P "$GITPOD_REPO_ROOT/.gp" {} \;'
# Updates all passwords related to phpmyadmin from values set in .starter.env
# Requires .starter.env to have all phpmyadmin related keys set with values
# Empty string value will break the script
# See .starter.env.example for the required phpmyadmin keys
alias update_pma_pws='bash $GITPOD_REPO_ROOT/.gp/bash/change-passwords.sh phpmyadmin'
# Shows help for update_pma_pws
alias help_update_pma_pws='cat "$GITPOD_REPO_ROOT/.gp/bash/snippets/messages/help-update-pma-pws.txt"'
# opens or refreshes the preview browser to the web root
alias op='bash "$GITPOD_REPO_ROOT/.gp/bash/open-preview.sh"'