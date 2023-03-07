#!/bin/bash

# propagte-commons-files-toApps.sh v1.0.0
#
# Changes:
# - v1.0.0: Initial development



# $1: git commit comment
# $2: file source
# $n: destination folders (or take it from Used in: comment)

#prepare source file
source=$2
#if [ ! "${source:0:1}" == "/" ]; then
#    source="$PWD/$source"
#fi

#prepare destinations
destinations=()
cnt=0
for arg in "$@"; do
    cnt=$((cnt+1))
    if [ $cnt -lt 3 ]; then
        continue
    fi

    destinations+=($arg)
done

#print running params
echo "";
echo "git comment: $1"
echo "pwd: $PWD"
echo "source: $source"
echo "destinations: (${#destinations[@]}) ${destinations[@]}"
echo ""


#check minimun params data are received
if [ -z "$1" ]; then
    echo -e "\n\n\nError: git comment param not received.\n\n\n" >&2
    exit 1
fi

if [ -z "$source" ]; then
    echo -e "\n\n\nError: source file param not received.\n\n\n" >&2
    exit 1
fi

if [ ! -f "$source" ]; then
    echo -e "\n\n\nError: source file not exits.\n\n\n" >&2
    exit 1
fi

if [ ${#destinations[@]} -eq 0 ]; then
    echo -e "\n\n\nError: destinations params not received.\n\n\n" >&2
    exit 1
fi

for dest in "${destinations[@]}"; do
    #check dest exists
    if [ ! -d "$dest" ]; then
        echo "folder $dest not exists. Continue with next one"
        continue
    fi

    #copy source to dest
    cp -v $source $dest

    #if dest have repo try to update it
    if [ -d "$dest/.git" ]; then
        cd $dest
        filename=$(basename "$source")
        git add $filename
        git commit -m "$1"
        git push
        cd $PWD
    fi
    echo ""
    echo ""
done

exit 0