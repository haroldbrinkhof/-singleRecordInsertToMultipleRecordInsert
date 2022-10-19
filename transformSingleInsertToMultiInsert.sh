#!/bin/bash
if [[ $# < 2 ]]; then
      printf "this scripts expects 2 values: the filename to parse and the number of sql inserts to group";
      exit 1;
fi
cat $1 | sed -e 's/;//g' | sed -e 's/^ *commit * *$//gi' | sed -e 's/ *values/ VALUES /gi' | awk -v COMMIT_EVERY=$2 -E toMultilineInsert.awk
