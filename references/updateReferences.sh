#!/bin/bash
 
#SBATCH -p serial                   # Send this job to the serial partition
#SBATCH -n 1                        # number of cores
#SBATCH -t 0-1:00                  # wall time (D-HH:MM)
##SBATCH -A drzuckerman             # Account to pull cpu hours from (commented out)
#SBATCH -o slurm.%j.out             # STDOUT (%j = JobId)
#SBATCH -e slurm.%j.err             # STDERR (%j = JobId)
#SBATCH --mail-type=END,FAIL        # notifications for job done & fail
#SBATCH --mail-user=qfischer@asu.edu # send-to address
module load ncbi-blast/2.5.0

## Author:  Quinn Fischer
## Updated: 05/15/18
## Description: Program builds either faa database with Fig pathways and/or without.
##=================================

##Flags
##Tells program to make lists in GenomesProject/references/sources/
makeDatabaseWithFig=0; ##0 - without fig pathways, 1 - with fig pathways
##

if [ $makeDatabaseWithFig == 1 ]; then
    
    if [ -d ./database ]; then
        rm -r ./database
    fi
    mkdir ./database
    cp ./databaseSource.faa ./database/databaseSource.faa
    makeblastdb -dbtype prot -in ./database/databaseSource.faa -out ./database/database
    > ./database/madeWithFig.flag
fi

if [ $makeDatabaseWithFig == 0 ]; then

if [ -d ./database ]; then
    rm -r ./database
fi
mkdir ./database

perl -e '
##Build fig-less faa file
my $firstChar;
my $name = "";
my $protein = "";
open(IN,"./databaseSource.faa");
while(<IN>)
    {
        chomp();
        $firstChar = substr $_, 0, 1;
        if (">" eq $firstChar) ##Found Protein Name
        {
            if (!("$name" eq ""))
            {
                my $check = substr $name, 1, 3;
                if (!("$check" eq "fig"))
                {
                    print $name, "\n";
                    print $protein, "\n";
                }
                $protein = "";
            }
            $name = $_;
        }
        else
        {
            $protein = "$protein$_";
        }
    }
    close IN;
' > ./database/databaseSource.faa

    makeblastdb -dbtype prot -in ./database/databaseSource.faa -out ./database/database
    > ./database/madeWithoutFig.flag
fi

