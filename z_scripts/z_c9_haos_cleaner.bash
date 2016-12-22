#!/bin/bash
set -euo pipefail;
IFS=$'\n\t';
# Sauce for above : http://redsymbol.net/articles/unofficial-bash-strict-mode/ 

# Script Variables
script_version="0.016";
script_log_file_name="C9_CLEANUP_LOG.md";
backup_directory_name="Z_SCRIPT_BACKED_Z_UP";
github_cleanup_ssh_url_string="";
directory_name_being_added="";
directory_being_backed_up="";

function init(){
    say_hello;
    #code_block_func tree;
    prompt_for_continuation;
    set_script_vars;
    code_block_func create_backup_directory_from_clone;
    code_block_func copy_files_to_be_backed_up_into_backup_directory;
    prompt_for_continuation;
    add_commit_push_files_back_to_github;
    say_goodbye;
}

function create_line_across_terminal(){
    printf "\n";
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -;
    printf "\n";
}

function say_hello(){
    create_line_across_terminal;
    printf "Haos C9 Scripted Cleanup!\n";
    printf "\nVersion : $script_version\n";
    printf "\nStart @ : $(date)\n";
    
}

function prompt_for_continuation(){
    create_line_across_terminal;
    read -p "Continue? : " -n 1 -r;
    printf "\`\`\` \$ %s\`\`\`\n" $REPLY;
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        printf "\n #### *USER CONTINUES!*.\n";
    else
        printf "### Exiting Script.\n";
        say_goodbye;
    fi    
    create_line_across_terminal;
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

function code_block_func(){
    create_line_across_terminal;
    printf "**Script Calls :**\n\n \`\`\` $C9_FULLNAME:$PWD \$ %s\`\`\`\n" "$1";
    create_line_across_terminal;
    printf "\`\`\`bash\n";
    $1;
    printf "\`\`\`\n";
    printf "\n(*%s finished.*)\n" "$1";
    create_line_across_terminal;
}

function copy_files_to_be_backed_up_into_backup_directory(){
    create_line_across_terminal;
    printf "directory_being_backed_up = %s\n" "$directory_being_backed_up";
    printf "backup_directory_name = %s\n" "$backup_directory_name";
    create_line_across_terminal;
    rsync -av --progress $directory_being_backed_up/. $backup_directory_name/$directory_name_being_added --exclude $backup_directory_name --exclude .c9 --exclude .git;
}

function add_commit_push_files_back_to_github(){
    create_line_across_terminal;
    cd $backup_directory_name
    git add --all;
    git commit -m "Scripted backup of : $C9_PROJECT";
    git push --all;
    cd $GOPATH;
}

function say_goodbye(){
    create_line_across_terminal;
    printf "Haos C9 Scripted Cleanup!\n";
    printf "\nVersion : $script_version\n";
    printf "\nEnded @ : $(date)\n";
    create_line_across_terminal;
    exit;
}

init 2>&1 | tee -a $script_log_file_name;

mv ./$script_log_file_name ./$backup_directory_name;

# One more time to record log in remote repo.
add_commit_push_files_back_to_github;