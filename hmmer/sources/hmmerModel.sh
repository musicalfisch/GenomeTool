#!/bin/bash
"""
for every stockholm file, run hmmbuild. 
"""
module load hmmer/3.1b2
for file in /home/jwass/Research/stockholm/*; do
    hmmbuild $(basename "${file%.*}")".hmm" "$file"
done
