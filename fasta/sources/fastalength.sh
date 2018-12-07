#!/bin/bash
#convert fasta files so protein lengths are all the same

for file in /Users/jadenwass/Desktop/Research/Originalfastafiles/*; do
	python /Users/jadenwass/Desktop/Research/SameLengthfastafiles/ProteinSequenceLength.py "$file"
done
