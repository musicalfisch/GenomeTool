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
module load ncbi-blast/2.5.0

## Author:  Quinn Fischer
## Updated: 06/18/18
## Description: Program takes an FAA file as input and returns as output information about the probable function of some of its protein chains based upon similarities to known ones.

##Get Command line arguments
FAA_FILE=$1;

##makes genome directory if it does not exist
if [ ! -d ./genomeDirectory ]; then
    mkdir ./genomeDirectory
fi

##Initialization for Blast Genome Process
if [ -r $FAA_FILE ]; then ##If file exists and is readable
	
	##Create new directory for file 
	NAME=$(basename $FAA_FILE .faa);
	DIRECTORY=./genomeDirectory/$NAME;
	
	##If directory exists, override it.
	if [ -d $DIRECTORY ]; then
		rm $DIRECTORY -r
	fi

	mkdir $DIRECTORY
	
	##Copy Faa File into Directory
	cp $FAA_FILE $DIRECTORY/
	
	##Run Blast
	blastp -db ./references/database/database -query $FAA_FILE -out $DIRECTORY/blastResults.txt -evalue 1e-3 -outfmt 7 -num_threads 2
	
	
	##Parse Blast Results
	#Header
	echo "#Query Protein    Database Protein   Coverage    Alignment Length  Query Start Query End   Sequence Start  Sequences End   E-Value Bit Score   GCA" > $DIRECTORY/blastParseResults.txt
	
	less "$DIRECTORY/blastResults.txt" |
	egrep -v '^#|fig\|' |
 	awk '$11 < 1e-5' |
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
	awk '$11 > 0.6'|
	sort -k 2,2 -k 7,7n -k 8,8n |
	uniq|
	perl -e 'while(<>)
	{ #removes similar matches with less than desirable coverage.
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
			$len1=$b[5]-$b[4];
			$len2=$c[5]-$c[4];
			$len3=$b[5]-$c[4];
			if($len3>0 and ($len3/$len1>0.5 or $len3/$len2>0.5))
			{
				if($b[-3]<$c[-3])
				{
					splice(@a,$i+1,1);
				}else
				{
					splice(@a,$i,1);
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
	uniq > $DIRECTORY/blastPreParseResults.txt

	##

	perl -e 'open(IN,"./references/nameConversionTable.txt");
	while(<IN>)
	{ #Constructs Hash Table
    	chomp;
    	@a=split(/\t/,$_);
    	$H{$a[0]}=$a[1];
	} 
	while(<>)
	{ #Converts known gene names to new standard via the hash table.
    	chomp;
    	@b=split(/\t/,$_);
    	$newName = $H{$b[1]};
    	if (!("$newName" eq "DELETE"))
    	{
    		print $b[0],"\t";
    		print $newName,"\t";
    		for (2..9)
    		{
        		print $b[$_],"\t";
    		}
    		print $b[10],"\n";
    	}
	}
	'|
	uniq >> $DIRECTORY/blastParseResults.txt
	rm $DIRECTORY/blastPreParseResults.txt


	##Run Statistics
	less $DIRECTORY/blastParseResults.txt |
	perl ./scripts/statisticTable.pl >$DIRECTORY/genomeStatTable.txt 

	##Code for generating CDS table
	less $DIRECTORY/blastParseResults.txt |
	perl -e ./scripts/cdsTable.pl 
fi

