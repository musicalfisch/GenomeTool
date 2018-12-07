#!/bin/bash

# for every hmmSearch file, parse and make a table. 

for file in /home/jwass/Research/hmmSearchResults/*; do
    ./hmmer3-2-table_new.sh  "$file" > $(basename "${file%.*}")".txt"
done
