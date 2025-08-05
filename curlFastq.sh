#!/bin/bash

#the SRR accession will be stored in variable $1, passed from GetFastqFiles.sh
#cd into accession directory
cd ../FastqFiles/${1}

#this command extracts the url tag from the .json file, then extract the url, then passes that to xargs, which then passes each url to curl iteratively (-n 1)
grep -Eo '"url": "[^"]*"' ./${1}.json | grep -o '"[^"]*"$' | xargs -n 1 curl  -sS -C - -O

res=$?
if test "$res" != "0"; then
  echo "${1}, exit code ${res}: running grep/curl call again"
  grep -Eo '"url": "[^"]*"' ./${1}.json | grep -o '"[^"]*"$' | xargs -n 1 curl  -sS -C - -O

  res=$?
  if test "$res" != "0"; then
    echo "${1}, exit code ${res}: running grep/curl call again"
    grep -Eo '"url": "[^"]*"' ./${1}.json | grep -o '"[^"]*"$' | xargs -n 1 curl  -sS -C - -O
  fi


fi

echo "${1}, exit code ${?}"
#grep -Eo '"url": "[^"]*"' ./${1}.json | grep -o '"[^"]*"$' | xargs -n 1 curl  -sS -C - -O

exit
