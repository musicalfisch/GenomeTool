"""
Reads a blast results file, parses it to find corresponding faa files and creates corresponding fasta files from data.
"""

import math
import os.path

save_path =  '/home/jwass/Research/faaFiles/fastafiles'
proteinFound = list()
letter = list()
proteinString = ""
goOn = False
i = 0

with open("blastResults.txt", "r+") as fnFile:
    for text_in_file1 in fnFile:
        words_in_line1 = text_in_file1.split()
        protein = words_in_line1[1].split("|")[-1]
        if(protein in proteinFound):
            completeName = os.path.join(save_path, protein + ".fasta")
            proteinFile = open(completeName, "a")

        else:
            proteinFound.append(protein)
            completeName = os.path.join(save_path, protein + ".fasta")
            proteinFile = open(completeName, "w")
        with open(words_in_line1[-1] + ".faa" , "r+") as faaFile:
            for text_in_file2 in faaFile:
                i += 1
                words_in_line2 = text_in_file2.split()
                if (goOn):
                    if '>' not in words_in_line2[0]:
                        proteinString += text_in_file2
                    else:
                        goOn = False
                        proteinFile.write('>' + words_in_line1[0] + '\n')
                        proteinString = proteinString.replace('\n', '')
                        sizeOfProteinString = len(proteinString)
                        for index in range(0, int(math.ceil(sizeOfProteinString/60.0))):
                            if(index < int(sizeOfProteinString/60.0)):
                                proteinFile.write(proteinString[index*60:index*60+60] + '\n')
                            else:
                                proteinFile.write(proteinString[index * 60:sizeOfProteinString] + '\n')
                        proteinString = ""
                if('>' + words_in_line1[0] in words_in_line2[0]):
                    goOn = True;




        faaFile.close()
        proteinFile.close()




