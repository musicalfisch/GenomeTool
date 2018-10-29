#!/bin/bash
 
#SBATCH -p serial                   # Send this job to the serial partition
#SBATCH -n 1                        # number of cores
#SBATCH -t 0-05:00                  # wall time (D-HH:MM)
##SBATCH -A drzuckerman             # Account to pull cpu hours from (commented out)
#SBATCH -o slurm.%j.out             # STDOUT (%j = JobId)
#SBATCH -e slurm.%j.err             # STDERR (%j = JobId)
#SBATCH --mail-type=END,FAIL        # notifications for job done & fail
#SBATCH --mail-user=qfischer@asu.edu # send-to address

##Modules Required
##module load ncbi-blast/2.5.0

## Author:					Quinn Fischer
## Co-Developer/Advisor:	Huansheng Cao
## Updated:					06/18/18
## Description: 			Program takes an FAA file as input and returns as output information about the probable function of some of its protein chains based upon similarities to known ones.

##Global Variables
##User Settings
FAA_FILE=""
OUTPUT_FILE=""
EVAL="5"
COVERAGE="0.5"
##Other Globals
DIRECTORY="./test5"
BLAST_OUTPUT="$DIRECTORY/blastResults.txt"
PREPARSE_OUTPUT="$DIRECTORY/blastResultsPreParsed.txt"
PARSE_OUTPUT="$DIRECTORY/blastResultsParsed.txt"

##Get Command line args
while getopts ':c:e:h:i:o:' option; do
	case "$option" in
	c)	COVERAGE="$OPTARG" ;;
	e)	EVAL="$OPTARG" ;;
	h)	echo "Program takes input .faa file and runs blast on it."
		echo ""
		echo "Program [options] application [arguments]"
		echo ""
		echo "options:"
		echo "-h,				show help"
		echo "-c,				sets limit on coverage of results, only real number between 0 and 1 allowed"
		echo "-e,				sets limit on e-value of 1*e^-arg, only positive integers allowed"
		echo "-i,				specifies input file path/name"
		echo "-o,				specifies output file path/name"
		exit 0 ;;
	i)	FAA_FILE="$OPTARG" ;;
	o)	OUTPUT_FILE="$OPTARG" ;;
	*)	echo "Invalid Symbol ..." ;;
	esac
done

##Sanitize Inputs (TODO)
echo "DIRECTORY : $DIRECTORY"
echo "BLAST_OUTPUT : $BLAST_OUTPUT"

echo "FAA_FILE : $FAA_FILE"
echo "OUTPUT_FILE : $OUTPUT_FILE"
echo "EVAL : $EVAL"
echo "COVERAGE : $COVERAGE"


##Initialization for Blast Genome Process
if [ -r $FAA_FILE ]; then ##If file exists and is readable
	##Run Blast
	
	blastp -db ./references/database/database -query "$FAA_FILE" -out "$BLAST_OUTPUT" -evalue "1e-$EVAL" -outfmt 7 -num_threads 2
	
	##Parse Blast Results
	#Header
	echo "#Query Protein	Database Protein	Alignment Length	E-Value	Coverage" > $PARSE_OUTPUT
	
	less $BLAST_OUTPUT |
	egrep -v '^#|fig\|' |
 	perl -e '##Adds length data together with parse results.
 	open(IN,"./references/lengthTable.txt");
 	while(<IN>)
 	{ #removes extraneous data
 		chomp;
 		@a=split(/\t/,$_);
 		$H{$a[0]}=$a[1];
 	} 
 	close IN;
 	
 	while(<>)
 	{
 		chomp;
 		@a=split(/\t/,$_);
 		if ($H{$a[1]} > 0)
 		{
 			for (0..3, 6..11)
 			{
 				print $a[$_],"\t";
 			}
 			$covr=sprintf("%.3f",($a[9]-$a[8]+1)/$H{$a[1]});
 			print $covr, "\n";
 		}
 	}
	'| 
	sort -k 2,2 -k 7,7n -k 8,8n |
	uniq > "./temp_coverage.txt"

	perl ./scripts/coverageScript.pl "./temp_coverage.txt" "$COVERAGE"| 
	uniq|
	perl -e 'while(<>)
 	{ # Removes -part of names
 		chomp;
 		@a=split(/\t/,$_);
 		@b=split(/\|/,$a[1]);
 		@c=split(/\-/,$b[3]);
 	
 		print $a[0],"\t";
 		for (0..2)
 		{
 			print $b[$_],"|";
 		}
 		print $c[0],"\t";
 		for (2..9)
 		{
 			print $a[$_],"\t";
 		}
 		print $a[10],"\n";
 	} 
	'|
	sort -k 2,2 -k 1,1n|
	uniq|
	perl -e '#Picks the "best" matched version of the unknown protein for a known protein based on e-value and coverage.
	while(<>)
	{ 
		chomp;
		@a=split;
		push(@{$b{$a[1]}},$_);
	}
	foreach(keys %b)
	{
		@a=@{$b{$_}};
		for($i=0;$i<$#a;$i++)
		{
			@b=split(/\t/,$a[$i]);
			@c=split(/\t/,$a[$i+1]);
			if($b[0] eq $c[0])
			{
				$eB=$b[8]**$b[10];
				$eC=$c[8]**$c[10];
				if(0==$b[8]*$c[8]) #Zero comparison
				{
					if(0==$b[8])
					{
						if(0==$c[8])
						{
							if($b[10] <= $c[10])
							{
								splice(@a,$i,1);
							}else
							{
								splice(@a,$i+1,1);
							}
						}else
						{
							splice(@a,$i+1,1);
						}
					}else
					{
						splice(@a,$i,1);
					}
				}else #Exponential comparison
				{
					if($eB <= $eC)
					{
						splice(@a,$i+1,1);
					}else
					{
						splice(@a,$i,1);
					}
				}
				$i=$i-1;
			}
		}
		foreach(@a)
		{
			print $_."\n";
		}
	}
	'| 
	sort -k 2,2 -k 1,1n|
	uniq > $PREPARSE_OUTPUT

	##

	less $PREPARSE_OUTPUT | perl -e 'open(IN,"./references/nameConversionTable.txt");
	while(<IN>)
	{ #Constructs Hash Table
    	chomp;
    	@a=split(/\t/,$_);
    	$H{$a[0]}=$a[1];
	} 
	while(<>)
	{ #Converts known gene names to new standard via the hash table. Removes unnecessary information
    	chomp;
    	@b=split(/\t/,$_);
    	$newName = $H{$b[1]};
    	if (!("$newName" eq "DELETE"))
    	{
    		print $b[0],"\t";
    		print $newName,"\t";
			print $b[3],"\t";
			print $b[8],"\t";
    		print $b[10],"\n";
    	}
	}
	'|
	uniq >> $PARSE_OUTPUT

	perl ./scripts/coverageScriptSecond.pl "$PARSE_OUTPUT" "$COVERAGE" | 
	uniq > $OUTPUT_FILE

	##	query acc., subject acc., % identity, alignment length, (0-3)
##	mismatches, gap opens, (4-5)
##	q. start 6, q. end 7, s. start 8, s. end 9, evalue 10, bit score 11 (6-11), coverage 12

##	query acc., subject acc., {% identity}, alignment length, (0-3)
##	q. start 4, q. end 5, s. start 6, s. end 7, evalue 8, bit score 9, coverage 10 (4-10)

##	query acc. 0, subject acc. 1, alignment length 2, evalue 3, coverage 4

	##Cleanup
	rm $PREPARSE_OUTPUT
	rm $BLAST_OUTPUT
	rm $PARSE_OUTPUT
	rm './temp_coverage.txt'

	##Run Statistics
	##less $DIRECTORY/blastParseResults.txt |
	##perl ./scripts/statisticTable.pl >$DIRECTORY/genomeStatTable.txt 

	##Code for generating CDS table
	##less $DIRECTORY/blastParseResults.txt |
	##perl -e ./scripts/cdsTable.pl 
fi

