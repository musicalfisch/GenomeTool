"""
    In ProteinStringChecker, a fasta file with the sequences the same length is entered as a parameter. It then first goes through each character at each protein sequence of the file and creates a new protein sequence composed of most common character of each spot. Once it has the "predicted true sequence" it then goes back through each protein sequence of the file and compares it with the predicted sequence. It then checks to see how closely the two sequences are. If the sequence is less than 20 percent for the first test we keep it in the new file. If the file has less than 10 protein sequences, we relax the criteria to 25, 30, 35 and then to 50 percent. 
    """

import sys

proteinString = list()
string = ""
charlist = list()
realProteinString = ""
tempName = ""
NumOfEle = 0
difference = 0
filetowrite = sys.argv[1].split("/")[-1]
with open(sys.argv[1], "r+") as fnFile:
    for text_in_file1 in fnFile:
        words_in_line1 = text_in_file1.split()
        if words_in_line1[0][0] == ">":
            if len(string) > 0:
                proteinString.append(string)
                string = ""
        else:
            string += words_in_line1[0]
    proteinString.append(string)
fnFile.close()

for index in range(0,len(proteinString[0])):
    for numofProt in proteinString:
        charlist.append(numofProt[index])
    realProteinString += max(set(charlist), key=charlist.count)
    charlist[:] = []
proteinString[:] = []
proteinFile = open(filetowrite, "w")
with open(sys.argv[1], "r+") as fnFile:
    for text_in_file1 in fnFile:
        words_in_line1 = text_in_file1.split()
        if words_in_line1[0][0] == ">":
            tempName = words_in_line1[0]
            if len(string) > 0:
                if tempName not in proteinString:
                    proteinString.append(tempName)
                    for index in range(0,len(realProteinString)):
                        if realProteinString[index] != string[index]:
                            difference += 1
                    if(float(difference)/len(realProteinString) <= .2):
                        proteinFile.write(tempName + '\n')
                        proteinFile.write(string + '\n')
                        NumOfEle += 1
                string = ""
                difference = 0
        else:
            string += words_in_line1[0]
    fnFile.close()
proteinFile.close()
proteinString[:] = []
if NumOfEle < 10:
    print("Not enough elements testing at 25%")
    NumOfEle = 0
    proteinFile = open(filetowrite, "w")
    with open(sys.argv[1], "r+") as fnFile:
        for text_in_file1 in fnFile:
            words_in_line1 = text_in_file1.split()
            if words_in_line1[0][0] == ">":
                tempName = words_in_line1[0]
                if len(string) > 0:
                    if tempName not in proteinString:
                        proteinString.append(tempName)
                        for index in range(0,len(realProteinString)):
                            if realProteinString[index] != string[index]:
                                difference += 1
                        if(float(difference)/len(realProteinString) <= .25):
                            proteinFile.write(tempName + '\n')
                            proteinFile.write(string + '\n')
                            NumOfEle += 1
                string = ""
                difference = 0
            else:
                string += words_in_line1[0]
        fnFile.close()
    proteinFile.close()
proteinString[:] = []
if NumOfEle < 10:
    print("Not enough elements testing at 30%")
    NumOfEle = 0
    proteinFile = open(filetowrite, "w")
    with open(sys.argv[1], "r+") as fnFile:
        for text_in_file1 in fnFile:
            words_in_line1 = text_in_file1.split()
            if words_in_line1[0][0] == ">":
                tempName = words_in_line1[0]
                if len(string) > 0:
                    if tempName not in proteinString:
                        proteinString.append(tempName)
                        for index in range(0,len(realProteinString)):
                            if realProteinString[index] != string[index]:
                                difference += 1
                        if(float(difference)/len(realProteinString) <= .3):
                            proteinFile.write(tempName + '\n')
                            proteinFile.write(string + '\n')
                            NumOfEle += 1
                string = ""
                difference = 0
            else:
                string += words_in_line1[0]
        fnFile.close()
    proteinFile.close()
proteinString[:] = []
if NumOfEle < 10:
    print("Not enough elements testing at 35%")
    NumOfEle = 0
    proteinFile = open(filetowrite, "w")
    with open(sys.argv[1], "r+") as fnFile:
        for text_in_file1 in fnFile:
            words_in_line1 = text_in_file1.split()
            if words_in_line1[0][0] == ">":
                tempName = words_in_line1[0]
                if len(string) > 0:
                    if tempName not in proteinString:
                        proteinString.append(tempName)
                        for index in range(0,len(realProteinString)):
                            if realProteinString[index] != string[index]:
                                difference += 1
                        if(float(difference)/len(realProteinString) <= .35):
                            proteinFile.write(tempName + '\n')
                            proteinFile.write(string + '\n')
                            NumOfEle += 1
                string = ""
                difference = 0
            else:
                string += words_in_line1[0]
        fnFile.close()
    proteinFile.close()
proteinString[:] = []
if NumOfEle < 5:
    print("Not enough elements testing at 50%") #only 4 fasta files
    NumOfEle = 0
    proteinFile = open(filetowrite, "w")
    with open(sys.argv[1], "r+") as fnFile:
        for text_in_file1 in fnFile:
            words_in_line1 = text_in_file1.split()
            if words_in_line1[0][0] == ">":
                tempName = words_in_line1[0]
                if len(string) > 0:
                    if tempName not in proteinString:
                        proteinString.append(tempName)
                        for index in range(0,len(realProteinString)):
                            if realProteinString[index] != string[index]:
                                difference += 1
                        if(float(difference)/len(realProteinString) <= .5):
                            proteinFile.write(tempName + '\n')
                            proteinFile.write(string + '\n')
                            NumOfEle += 1
                string = ""
                difference = 0
            else:
                string += words_in_line1[0]
        fnFile.close()
    proteinFile.close()
