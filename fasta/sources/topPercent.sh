#!/bin/bash
#convert fasta files so protein sequences are similar

for file in /Users/jadenwass/Desktop/Research/SameLengthfastafiles/fastaFiles/*; do
	python /Users/jadenwass/Desktop/Research/20%FastaFiles/fastafiles/ProteinStringChecker.py "$file"
done
