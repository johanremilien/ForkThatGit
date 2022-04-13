#!/bin/bash

set -eET # (-e) abort | (-E) show errtrace | (-T) show functrace

print_help() {
	echo -e " ForkThatGit i.e Fork that Git(Hub repository)
 is script/tool to ease the fork-rename process of any GitHub repository

 usage: forkthatgit [-r=<github repository url>]
                    [-u=<github username>]
                    [-o=<old name>] [-n=<new name>]"
	exit 0
}

if [ "$1" == "-h" ]; then
  print_help
  exit 0
fi

while getopts r:u:o:n: flag
do
    case "${flag}" in
    	r) export repo=${OPTARG};;
        u) export user=${OPTARG};;
        o) export old=${OPTARG};;
        n) export new=${OPTARG};;
    esac
done

# Request github's url repo if not defined yet
while  [ -z "$repo" ]; do
	echo enter a valid url:
	read repo
done

# Request github's username if not defined yet
while  [ -z "$user" ]; do
	echo enter a valid username:
	read user
done

# Clone repo
git clone $repo
repo=$(basename "$_" .git)

if [[ -n "$old" && -n "$new" ]]; then
	# Rename repo
	mv $repo ${repo/$old/$new}
	repo=$_
	# Rename director(y|ies)
	for dir in $(find . -name "*$old*" -type d); do mv $dir ${dir/$old/$new}; done

	# Rename file(s)
	for file in $(find . -name "*$old*" -type f); do mv $file ${file/$old/$new}; done

	# Replace string within files
	for file in $(grep -rl $old --exclude-dir .git .); do sed -i '' "s/$old/$new/g" $file; done
fi

# Set remotes
cd $repo
git remote set-url origin git@github.com:$user/$repo.git
git remote add upstream git@github.com:$user/$repo.git

# Commit changes
git add -A
git commit -m "Replace \"*$old*\" by \"*$new*\" using https://github.com/johanremilien/ForkThatGit"

while true; do
    read -p "Do you want to push this repo [yn]?" yn
    case $yn in
        [Yy]* ) # Push commits
		git push -u -f origin main
		break;;
        [Nn]* ) # Print command
		echo -e "git push -u -f origin main"
		break;;
        * ) echo "Please answer yes or no.";;
    esac
done

$SHELL
