#!/bin/bash

set -eET # (-e) abort | (-E) show errtrace | (-T) show functrace

print_help() {
	echo -e " renameit is a companion script to forkthatgit i.e Fork that Git(Hub repository)
 This script/tool allows to ease the process of renaming the content of any directory.

 usage: renameit [-o=<old name>] [-n=<new name>]"
	exit 0
}

if [ "$1" == "-h" ]; then
  print_help
  exit 0
fi

while getopts o:n: flag
do
    case "${flag}" in
        o) export old=${OPTARG};;
        n) export new=${OPTARG};;
    esac
done

# Request old string if not defined yet
while  [ -z "$old" ]; do
	echo enter the string you want to change \(old\):
	read old
done

# Request new string if not defined yet
while  [ -z "$new" ]; do
	echo enter the string that will replace \"$old\" \(new\):
	read new
done

if [ "$old" != "$new" ]; then
    # Rename director(y|ies)
    for dir in $(find . -name "*$old*" -type d); do mv $dir ${dir/$old/$new}; done

    # Rename file(s)
    for file in $(find . -name "*$old*" -type f); do mv $file ${file/$old/$new}; done

    # Replace string within files
    for file in $(grep -rl $old --exclude-dir .git .); do sed -i '' "s/$old/$new/g" $file; done
fi
