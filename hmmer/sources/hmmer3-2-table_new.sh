# Yanbin Yin
# 08/18/2011
# take hmmer3 output and generate the tabular output
cat $1 | perl -e 'while(<>){if(/^\/\//){$x=join("",@a);($q)=($x=~/^Query:\s+(\S+)/m);while($x=~/^>> (\S+.*?\n\n)/msg){$a=$&;@c=split(/\n/,$a);$c[0]=~s/>> //;for($i=3;$i<=$#c;$i++){@d=split(/\s+/,$c[$i]);print $q."\t".$c[0]."\t$d[3]\t$d[6]\t$d[7]\t$d[8]\t$d[10]\t$d[11]\n" if $d[6]<1;}}@a=();}else{push(@a,$_);}}'
