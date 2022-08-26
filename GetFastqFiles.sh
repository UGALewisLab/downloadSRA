#!/bin/bash

#check for required command line argument

if [[ -z "$1" ]]
then
		echo "################
		ERROR: You must include the path to your accession file in the command line call.
		eg. sh GetFastqFiles.sh Path/To/Your/AccessionFile.txt
		##################"

		exit
	else
chmod 755 curlFastq.sh
fi


#iterates through a directory of directories, each containing a metadata file produced by ffq --ftp. replace /scratch/zlewis/SRAtest/ with the path to your own directory.

while read -r line

do
sleep 10
source ./curlFastq.sh "$line" & done <"$1"
#
