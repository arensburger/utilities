#!/usr/bin/perl

# August 2017 takes ouput of NCBI progam ORFfinder and returns gff formated file

#use strict
open (INPUT, $ARGV[0]) or die;
my $i=0;
while (my $line = <INPUT>) {
	if ($line =~ /TnAV052917:(\d+):(\d+)\s/) {
		my $b1 = $1;
		my $b2 = $2;
		if ($b2 > $b1) {
			print "TnAV052917\tRefSeq\tgene\t$b1\t$b2\t.\t+\t.\tID=ORF$i;$ha\n";
		}
		elsif ($b1 > $b2) {
			print "TnAV052917\tRefSeq\tgene\t$b2\t$b1\t.\t-\t.\tID=ORF$i;\n";
		}
		$i++;
	}
}
