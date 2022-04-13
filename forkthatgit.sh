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
    	r) export repo_url=${OPTARG};;
        u) export user=${OPTARG};;
        o) export old=${OPTARG};;
        n) export new=${OPTARG};;
    esac
done

# Request github's url repo if not defined yet
while  [ -z "$repo_url" ]; do
	echo enter a valid url:
	read repo_url
done

# Request github's username if not defined yet
while  [ -z "$user" ]; do
	echo enter a valid username:
	read user
done

# Clone & Rename repo
old_repo_name=$(basename "$repo_url" .git)
repo_name=${old_repo_name/$old/$new}
git clone $repo_url $repo_name
cd=$_

if [[ -n "$old" && -n "$new" ]]; then
	$(dirname "$0")/renameit.sh -o $old -n $new
fi

# Set remotes
cd $repo_name

git remote set-url origin git@github.com:$user/$repo_name.git
git remote add upstream $repo_url

# Update Readme
readme=$(find . -maxdepth 1 -iname "readme*" | head -n 1)
if [ -n "$readme" ]; then
	readme=README.md
fi
echo -e "\n(Fork of [$old_repo_name](${repo_url/git@github.com:/https://github.com/}) with [ForkThatGit](https://github.com/johanremilien/ForkThatGit))" >> $readme

# Commit changes
git add -A
git commit -m "Replace \"*$old*\" by \"*$new*\" using https://github.com/johanremilien/ForkThatGit"

while true; do
    read -p "Do you want to push this repo [yn]?" yn
    case $yn in
        [Yy]* ) # Push commits
		if ! [ command -v gh &> /dev/null ]; then
			if [ command -v brew &> /dev/null ]; then
				echo "Create the repository in GitHub and run 'git push -u -f origin main' in "$repo_name""
				break
			else
				brew install gh
			fi
		fi
		gh repo create $repo_name --private
		git push -uf origin main
		break;;
        [Nn]* ) # Print command
		echo -e "gh repo create $repo_name --private\ngit push -u -f origin main"
		break;;
        * ) echo "Please answer yes or no.";;
    esac
done

$SHELL
