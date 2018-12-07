#!/bin/bash
#convert fasta files so protein sequences are similar

for file in ~/Research/SameLengthfastafiles/*; do
	python ~/Research/Similarfastafiles/ProteinStringChecker.py "$file"
done
