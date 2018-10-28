	use File::Basename;
	##Initialization
	my @NameHash;
	my $fileName = basename $file .txt;
    my $DIRECTORY = "./genomeDirectory/$fileName";
	
	##Code to establish final name hash
	open(IN,"./references/nameConversionTable.txt");
	while(<IN>)
	{
    	chomp();
    	my @nameArray=split(/\t/, $_);
    	$NameHash{$nameArray[1]} = $nameArray[2];
	}
	close IN;
	
    ##Get Protein Data
    my @proteinData;
    my $firstChar;
    my $name = "";
    my $protein = "";

    open(IN,"$DIRECTORY/$fileName.faa");
    while(<IN>)
    {
        chomp();
        $firstChar = substr $_, 0, 1;
        if (">" eq $firstChar) ##Found Protein Name
        {
            if (!("$name" eq ""))
            {
                $proteinData{$name} = $protein;
                $protein = "";
            }
            my @a = split(/\s+/, $_);
            $name = $a[0];
        }
        else
        {
            $protein = "$protein$_";
        }
    }
    close IN;
    
    ##Combine Data with parse results.
    open($outputFile,">","$DIRECTORY/proteins.txt");
    open(IN,"$_");
    my $firstLine = 1;
    while(<IN>)
    {
    	chomp();
    	if (0 eq $firstLine)
    	{
        	my @a=split(/\t/, $_);
        	my @b=split(/\|/, $NameHash{$a[1]});
        	my $proteinResult = $proteinData{">$a[0]"};
        	print $outputFile "$a[0]\t$b[0]\t$b[1]\t$b[2]\t$b[3]\t$proteinResult\n";
        }
        else
        {
        	print $outputFile "#Query Protein\tPathway\tComplex\tSubcomplex\tProtein\t(AA) Sequence\n";
        	$firstLine = 0;
        }
    }
    close IN;
    close $outputFile;
    