#!/bin/bash

workspace_log='/var/log/workspace-image.log'
init_log='/var/log/workspace-init.log'
echo -e "\n\e[38;5;183mSUMMARY\e[0m\n"
echo -en "\e[38;5;194mResults of building the workspace image\e[0m \e[38;5;34m$workspace_log\e[0m ➥\n\e[38;5;171m"
cat $workspace_log
echo -en "\e[0m"
echo ''
echo -en "\e[38;5;194mResults of the gitpod initialization\e[0m \e[38;5;34m$init_log\e[0m ➥\e[38;5;39m"
cat $init_log
echo -en "\e[0m"
echo -e "\n\e[38;5;183mALL DONE\e[0m\n"
echo "If everything looks good in the above results then push the newly created project files to your git repo and get started coding your project 🚀\n"