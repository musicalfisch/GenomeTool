# Take a fasta file as an argument and compare each entry to ensure all entries have
# the same protein string length. The program goes through each protein sequence in the file
# and keeps track of the most common sequence length and then goes back through and throws out
# all the sequence lengths that do not match. 

import sys
import math

proteinLen = list()
validProteinStrings = list()
proteinLength = 0
proteinString = ""
realLength = 0
tempName = ""
filetowrite = sys.argv[1].split("/")[-1]
with open(sys.argv[1], "r+") as fnFile:
    for text_in_file1 in fnFile:
        words_in_line1 = text_in_file1.split()
        if words_in_line1[0][0] == '>':
            if proteinLength != 0:
                proteinLen.append(proteinLength)
                proteinLength = 0
        else:
            proteinLength += len(text_in_file1)-1
    if proteinLength != 0:
        proteinLen.append(proteinLength)
        proteinLength = 0
    fnFile.close()
realLength = (max(set(proteinLen), key=proteinLen.count))
proteinFile = open(filetowrite, "w")
with open(sys.argv[1], "r+") as fnFile:
    for text_in_file1 in fnFile:
        words_in_line1 = text_in_file1.split()
        if words_in_line1[0][0] == '>':
            if proteinLength == 0:
                tempName = words_in_line1[0]
            else:
                if  proteinLength == realLength:
                    proteinFile.write(tempName + '\n')
                    proteinFile.write(proteinString)
                    tempName = words_in_line1[0]
            proteinLength = 0
            proteinString = ""

        else:
            proteinString += text_in_file1
            proteinLength += len(text_in_file1) -1

    if  proteinLength == realLength:
        proteinFile.write(tempName + '\n')
        proteinFile.write(proteinString)

    fnFile.close()
proteinFile.close()

