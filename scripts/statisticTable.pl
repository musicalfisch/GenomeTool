	#!/usr/bin/perl

	## Author:					Quinn Fischer
    ## Co-Developer/Advisor:	Huansheng Cao
    ## Updated:					10/29/18
    ## Description: 			Script in progress.

	
	use File::Basename;
	##Variable Declaration
	my $fileName = basename $_ .txt;
	
	my $DIRECTORY = "./genomeDirectory/$fileName";
	my $MetricCoverage = 0;
	my @MetricProtein;
	my @MetricComplete;
	my @MetricComplexTotal;

	my @proteinCounting;
	my @proteinId;

	my @MetricComplex;

	my @Complex;
	my @ComplexCount;
	my @ComplexCountStandard;

	my @NameHash;
	##Code to establish final name hash
	open(IN,"./references/nameConversionTable.txt");
	while(<IN>)
	{
    	chomp();
    	my @nameArray=split(/\t/, $_);
    	$NameHash{$nameArray[1]} = $nameArray[2];
	}
	close IN;
	
	##Code Body
	
	##Initializes Metrics
	open(IN,"./references/nameCategories/names1.txt");
	while(<IN>)
	{
		chomp();
		$MetricProtein{$_} = 0;
		$MetricComplete{$_} = 0;
    	$MetricComplexTotal{$_} = 0;
	}
	close IN;
	
	open(IN,"./references/nameCategories/names4.txt");
	while(<IN>)
	{
    	chomp();
    	$proteinCounting{$_} = 0;
    	$proteinId{$_}[0] = 0;
	}
	close IN;

	##establishes individual complex hash
	open(IN,"./references/nameCategories/names3.txt");
	while(<IN>)
	{
		chomp();
    	##Code for MetricComplex
    	$MetricComplex{$_} = 0;
    
    	##Code for other Metrics
		my @nameArray=split(/\|/, $_);
		my $proteinPrefix = substr( $nameArray[2], 0, 3 );
		my $proteinNumber = length( $nameArray[2] ) - 3;
		my $proteinNames = substr( $nameArray[2], 3, $proteinNumber );
		
		my $complexLetter = substr( $proteinNames, 0, 1 );
		my $resultString = "$proteinPrefix$complexLetter|";
		my $countString = "0";
	
		for (my $i=1; $i < $proteinNumber; $i++) 
		{
			$complexLetter = substr( $proteinNames, $i, 1 );
   			$resultString = "$resultString$proteinPrefix$complexLetter|";
			$countString = "$countString|0";
		}
		$Complex{$_} = $resultString;
		$ComplexCount{$_} = $countString;
		$ComplexCountStandard{$_} = $countString;
	}
	close IN;

	##process parsed genome file
	my $ONE = "1";
	open(IN,"$_");
	while(<IN>)
	{
		chomp();
		my @inputArray=split(/\t/, $_);
		my @pathwayArray=split(/\|/, $inputArray[1]);

		my $key = "$pathwayArray[0]|$pathwayArray[1]|$pathwayArray[2]";
		my $proteinString = $Complex{$key};
		if (!("" eq $proteinString))
		{
			my $countString = $ComplexCount{$key};
			my @proteinStringArray=split(/\|/, $proteinString);
			my @countStringArray=split(/\|/, $countString);
			
			my $newCountString = "";
			for($i=0;$i<=$#proteinStringArray;$i++)
			{
				##If protein is in complex note its occurence once. Else, keep it as is.
				if ($proteinStringArray[$i] eq $pathwayArray[3])
				{
					$newCountString = "$newCountString$ONE|";
				}
				else
				{
					$newCountString = "$newCountString$countStringArray[$i]|";
				}
			}
			$ComplexCount{$key} = $newCountString;

			$MetricProtein{$pathwayArray[0]} = $MetricProtein{$pathwayArray[0]} + 1;
			$MetricCoverage = $MetricCoverage + $inputArray[3];
			$MetricComplex{$key} = 1;
			
        	$proteinId{$inputArray[1]}[$proteinCounting{$inputArray[1]}] = $inputArray[0];
        	$proteinCounting{$inputArray[1]} = $proteinCounting{$inputArray[1]} + 1;
		}
	}
	close IN;
	
	##file read, now tallying Metric Two: Total number of complete units.
	open(IN,"./references/nameCategories/names3.txt");
	while(<IN>)
	{
		chomp();
		my $countString = $ComplexCount{$_};
		my @countStringArray = split(/\|/, $countString);
		
		my $value = 0;
		##Check to see if complex is complete
		if (0 le $#countStringArray)
		{
			$value = 1;
			for($i=0;$i<=$#countStringArray;$i++)
			{
				if (!($countStringArray[$i] eq 1))
				{
					$value = 0;
				}
			}	
		}
		##Adjust Metrics
		my @inputArray = split(/\|/, $_);
		$MetricComplexTotal{$inputArray[0]} = $MetricComplexTotal{$inputArray[0]} + $MetricComplex{$_};
		$MetricComplete{$inputArray[0]} = $MetricComplete{$inputArray[0]} + $value;
	}
	close IN;
	
	##Stats collected. Starting the printing presses.
	
    ##Handles printing & output of protein pathway information.
    open($outputFile,">","$DIRECTORY/pathways.txt");
    print $outputFile "#Pathway\tComplex\tSubcomplex\tProtein\tNumber of Matches\tProtein Matches\n";
    open(IN,"./references/nameCategories/names4.txt");
    while (<IN>)
    {
        chomp();
        my $count = $proteinCounting{$_};
        @nameArray=split(/\|/, $NameHash{$_});
        print $outputFile "$nameArray[0]\t$nameArray[1]\t$nameArray[2]\t$nameArray[3]\t$count\t";
        if ($count eq "0")
        {
        	print $outputFile "NONE";
        }
        else
        {
        	print $outputFile "$proteinId{$_}[0]";
        	for (my $i=1; $i < $count; $i++) 
			{
				print $outputFile ", $proteinId{$_}[$i]";
			}
        }
        print $outputFile "\n";
    }
    close IN;    
    close $outputFile;

	##Main Output of metrics to stat table
	open(IN,"./nameCategories/names1.txt");
	while(<IN>)
	{
		chomp();
		print $fileName, "\t",  $_, "\t", $MetricProtein{$_}, "\t", $MetricComplete{$_}, "\t", $MetricComplexTotal{$_}, "\n";
	}