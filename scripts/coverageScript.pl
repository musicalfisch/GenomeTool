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
            @a=split;
            push(@{$b{$a[1]}},$_);
        }
        close IN;

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
                if($len3>0 and ($len3/$len1>$COVERAGE or $len3/$len2>$COVERAGE))
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
    }

    

	