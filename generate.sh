#!/bin/bash

PARAMS=""
while (( "$#" )); do
	case "$1" in
	-h|--help)
		echo "  Options:
	-n|--name
		Project Name
	-f|--file
		File Name
	-v|--verbose
		Print the generated file when finished
"
		exit  1
		shift
		;;
	-n|--name)
		projectName="$2"
		projectNameSet="yes"
		shift
		;;
	-f|--file)
		outfile="$2"
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

echo writing to project $outfile to $outfile

ignorefiles="package-lock.json report.html ThirdPartyNotices.txt THANKS.md oss-licenses.json"

ignorefolders="package-lock.json"

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
	find $1 -maxdepth 0 -path ./node_modules -prune -o -type d  \( \
	! -iname "*.min*" \
	! -iname ".min.js" \
	! -path "." \
	! -path "*.git" \
	! -path "*.vs*" \
	! -path "*img*" \
	! -path "*inc*" \
	! -path "*dev*" \
	! -path "*node_modules*" \
	! -path "./node_modules/*" \
	! -path "./node_modules" \
	\) -print0 | 
	while IFS= read -r -d '' line; do 
		# echo $1
		# echo ./${line:2}
		find ./${line:2} -maxdepth 1 -path ./node_modules -prune -o -type f \( \
		! -iname "*.min*" \
		! -iname ".min.js" \
		! -path "./1*" \
		\) -print0 | 
		while IFS= read -r -d '' file; do 
			#echo $(basename $file)
			if ! contains $(basename "$file") "$ignorefiles"; then
				echo "	<File name=\"${file:2}\" />" >> $outfile
			fi
		done
		find ./${line:2} -maxdepth 1 -mindepth 1 -path ./node_modules -prune -o -type d \( \
	! -iname "*.min*" \
	! -iname "*.min.js" \
	! -path "." \
	! -path "*.git" \
	! -path "*.vs*" \
	! -path "*img*" \
	! -path "*inc*" \
	! -path "*dev*" \
	! -path "*node_modules*" \
	! -path "./node_modules/*" \
	! -path "./node_modules" \
	\) -print0 | 
		while IFS= read -r -d '' folder; do 
			#echo $folder
			#echo ${folder##*/}
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
