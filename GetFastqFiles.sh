#!/bin/bash

#check for required command line argument

if [ -z "$1" ] then 
	do
		echo "Include the path to your accession file in the command line call. eg. sh GetFastqFiles.sh Path/To/Your/AccessionFile.txt"
		exit
		
	else
		
#iterates through a directory of directories, each containing a metadata file produced by ffq --ftp. replace /scratch/zlewis/SRAtest/ with the path to your own directory. 
chmod 755 curlFastq.sh

while read -r line 

do
sleep 10 
source ./download_scriptTwo.sh $line & done <$1
#
