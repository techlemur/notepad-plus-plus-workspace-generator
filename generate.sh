#!/bin/bash

defaultignorefiles="package-lock.json report.html ThirdPartyNotices.txt THANKS.md oss-licenses.json"

defaultignorefolders=".git .vs node_modules"

ignorefiles=''
ignorefolders=''
sortflags=''

PARAMS=""
while (( "$#" )); do
    case "$1" in
    -h|--help)
        echo "  Options:
    -h|--help
        Show this message
    -a|--all
        Disable default ignore settings and add everything
    -d|--defaults
        Add defaults to custom ignore rules
    -f|--file
        File Name
    -i|--ignore
        Specify file names to ignore
    -if|--ignoreFolders|--ignorefolders
        Specify folder names to ignore
    -n|--name
        Project Name
    -s|--sort
        Sort flags (must be wrapped in quotes.  ex: '-f -n')
    -v|--verbose
        Print the generated file when finished
"
        exit  1
        shift
        ;;
    -a|--all)
        addall=true
        shift
        ;;
    -d|--defaults)
        adddefaults=true
        shift
        ;;
    -f|--file)
        outfile="$2"
        shift
        ;;
    -i|--ignore)
        ignorefiles="$2"
        shift
        ;;
    -if|--ignoreFolders|--ignorefolders)
        ignorefolders="$2"
        shift
        ;;
    -n|--name)
        projectName="$2"
        projectNameSet="yes"
        shift
        ;;
    -s|--sort)
        sortflags="$2"
        sortflagsSet="yes"
        shift
        ;;
    -v|--verbose)
        VERBOSE=true
        shift
        ;;
    -*|--*=) # unsupported flags
        echo "Error: Unsupported flag $1" >&2
        exit  1
        ;;
    *) # preserve positional arguments
        PARAMS="$PARAMS $1"
        shift
        ;;
    esac
done
# set positional arguments in their proper place
eval set -- "$PARAMS"

if [ -z $outfile ]
then
    outfile=".npworkspace"
fi

if [ -z $projectNameSet ]
then
    projectName="$(basename $PWD)"
fi


if [ -z $addall ] # Don't set ignore lists if -a flag was given
then
    
    if [ $adddefaults ]
    then
        ignorefiles=$ignorefiles" "$defaultignorefiles
        ignorefolders=$ignorefolders" "$defaultignorefolders
        if [ -z "$sortflags" ]
        then
            sortflags=" -f "
        fi
    fi
    
    if [ -z "$ignorefiles" ]
    then
        ignorefiles=$defaultignorefiles
    fi

    if [ -z "$ignorefolders" ]
    then
        ignorefolders=$defaultignorefolders
    fi
fi

echo writing to project $outfile to $outfile

IGNOREFOLDERS=''

for TMP in $ignorefolders; do
    IGNOREFOLDERS=$IGNOREFOLDERS"! -iname '$TMP' "
done

contains() {
    for item in $2
    do
        # echo $item
        if [ "$1" == "$item" ]; then
            return 0;
        fi
    done
    return 1;
}

recfind(){
    eval "find $1 -maxdepth 0 -path ./node_modules -prune -o -type d  \( $IGNOREFOLDERS \) -print0 | sort -z $sortflags"  | 
    while IFS= read -r -d '' line; do 
        # echo $1
        # echo ./${line:2}
        find ./${line:2} -maxdepth 1 -path ./node_modules -prune -o -type f \( \
        ! -iname "*.min*" \
        ! -iname ".min.js" \
        ! -path "./1*" \
        \) -print0 | sort -z $sortflags | 
        while IFS= read -r -d '' file; do 
            #echo $(basename $file)
            if ! contains $(basename "$file") "$ignorefiles"; then
                echo "	<File name=\"${file:2}\" />" >> $outfile
            fi
        done
        eval " find ./${line:2} -maxdepth 1 -mindepth 1 -path ./node_modules -prune -o -type d \( $IGNOREFOLDERS \) -print0 | sort -z $sortflags" |  
        while IFS= read -r -d '' folder; do 
            echo "<Folder name=\"${folder##*/}\">" >> $outfile
            recfind $folder
            echo "</Folder>"  >> $outfile
        done
    done
}

echo "<NotepadPlus>" > $outfile
echo "<Project name=\"$projectName\">" >> $outfile
recfind ./
echo "</Project>" >> $outfile
echo "</NotepadPlus>" >> $outfile

chmod 777 $outfile

if [ $VERBOSE ];then	cat $outfile; fi