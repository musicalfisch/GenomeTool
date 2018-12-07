#!/bin/bash
#convert fasta files into stockholm format

for file in /Users/jadenwass/Desktop/Research/20%FastaFiles/fastafiles/*; do
    printf "$file"
    python /Users/jadenwass/Desktop/Research/bioscripts.convert-0.4/bioscripts/convert/convalign.py stockholm "$file"

done
