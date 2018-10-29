	#!/usr/bin/perl

    ## Author:					Quinn Fischer
    ## Co-Developer/Advisor:	Huansheng Cao
    ## Updated:					10/29/18
    ## Description: 			Script takes an semiparsed blast results file and coverage value as input, and returns blast results meeting the coverage criteria.

    if(1 == $#ARGV)
    {
        $COVERAGE = $ARGV[1];
        $FILE = $ARGV[0];
        
        open(IN,"$FILE");
        while(<IN>)
        { 
            chomp;
            @splitInput=split(/\t/,$_);
            if ($splitInput[4] >= $COVERAGE)
            {
                for (0..3)
                {
                    print $splitInput[$_],"\t";
                }
                print $splitInput[4],"\n";
            }
        }
        close IN;

    }

    

	