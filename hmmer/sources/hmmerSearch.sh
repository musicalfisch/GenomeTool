#!/bin/bash
"""
run hmmsearch on all hmmer models for every faa file.
"""
module load hmmer/3.1b2
for file in /home/jwass/Research/preciseHmmrModels/*; do
    for faaFile in /home/jwass/Research/GenomeProject/data/faa/*; do
        hmmsearch  "$file" "$faaFile" > $(basename "${faaFile%.*}")"_"$(basename "${file%.*}")".txt"
    done 
done

