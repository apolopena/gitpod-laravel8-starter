# shellcheck shell=bash
# shellcheck disable=2142
# This file is sourced into ~/.bashrc
# Add any alias you would like here

alias lint-starter-scripts='find "$GITPOD_REPO_ROOT/.gp" -type d \( -name node_modules \) -prune -false -o -name "*.sh" -exec shellcheck -x -P "$GITPOD_REPO_ROOT/.gp" {} \;'
# Updates all passwords related to phpmyadmin from values set in .starter.env
# Requires .starter.env to have all phpmyadmin related keys set with values
# Empty string value will break the script
# See .starter.env.example for the required phpmyadmin keys
alias update-pma-pws='bash $GITPOD_REPO_ROOT/.gp/bash/change-passwords.sh phpmyadmin'
# Shows help for update_pma_pws
alias update-pma-pws-help='cat "$GITPOD_REPO_ROOT/.gp/snippets/messages/update-pma-pws-help.txt"'
# opens or refreshes the preview browser to the web root
alias op='f(){ bash "$GITPOD_REPO_ROOT"/.gp/bash/open-preview.sh "$1";  unset -f f; }; f'