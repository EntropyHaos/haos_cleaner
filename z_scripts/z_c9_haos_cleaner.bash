#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';
# Sauce for above : http://redsymbol.net/articles/unofficial-bash-strict-mode/ 

# Script Variables

backup_directory_name="";
github_cleanup_ssh_url_string="";
directory_name_being_added="";
directory_being_backed_up="";

function init(){
    say_hello;
    set_script_vars;
    create_backup_directory_from_clone;
    copy_files_to_be_backed_up_into_backup_directory;
    add_commit_push_files_back_to_github;
}

function say_hello(){
    clear;
    printf "\nHello World!\n";
}

function set_script_vars(){
    backup_directory_name="Z_SCRIPT_BACKED_Z_UP";
    github_cleanup_ssh_url_string="git@github.com:EntropyHaos/Cloud9_Backups_Fall_2016.git";
    directory_name_being_added="$C9_PROJECT";
    directory_being_backed_up="$PHPRC";
}

function create_backup_directory_from_clone(){
    git clone $github_cleanup_ssh_url_string $backup_directory_name;
}

function copy_files_to_be_backed_up_into_backup_directory(){
    printf "directory_being_backed_up = %s\n" "$directory_being_backed_up";
    printf "backup_directory_name = %s\n" "$backup_directory_name";
    rsync -av --progress $directory_being_backed_up/. $backup_directory_name/$directory_name_being_added --exclude $backup_directory_name --exclude .c9 --exclude .git;
}

function add_commit_push_files_back_to_github(){
    cd $backup_directory_name
    git add --all;
    git commit -m "Scripted backup of : $C9_PROJECT";
    git push --all;
    cd $GOPATH;
}

init;