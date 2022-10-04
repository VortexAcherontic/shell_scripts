#!/bin/bash
########################################
# Recursively renames all files in     #
# a directory to lower case            #
# Actual source:                       #
# https://stackoverflow.com/a/26477421 #
########################################
testFILE=
FLAG=1

for FILE in *; do
  testFILE=$(tr '[A-Z]' '[a-z]' <<< "$FILE")

  for FILE2 in *; do
    if [  "$testFILE" = "$FILE2" ]; then
      FLAG=0
    fi
  done

  if [ $FLAG -eq  1 ]; then
    mv -- "$FILE" "$(tr '[A-Z]' '[a-z]' <<< "$FILE")"
  fi

  FLAG=1
done

