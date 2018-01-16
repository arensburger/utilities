#!/usr/bin/perl

# January 2018 takes as input a file downloaded from NCBI as a features table <send to> <file> <features table> and returns a simple gff file
use strict;
use Getopt::Long;

my $file1; # file with features table information
GetOptions(
	'in:s'  => \$file1,
);
die ("usage: perl featurestable2gff.pl -in <REQUIRED: input file features table>\n") unless ($file1);

open (INPUT, $file1) or die "cannot open file $file1\n";
<INPUT>; # skip first line
my @b1; # bound1
my @b2; # bound2
my @type; # gene, tRNA, etc.
my @ID;

my $i=0; # feature number
while (my $line = <INPUT>) {
	if ($line =~ /^(\d+)\s(\d+)\s(\S+)/) {
		$b1[$i] = $1;
		$b2[$i] = $2;
		$type[$i] = $3;
	}
	elsif ($line =~ /^\s+product\s(.+)/) {
		$ID[$i] = $1;
		chomp $ID[$i];
		$i++;
	}
	elsif ($line =~ /^\s+gene\s(.+)/) {
		$ID[$i] = $1;
		chomp $ID[$i];
		$i++;
	}
}
close INPUT;

#print output
print "##gff-version 3\n";
for (my $j=0; $j<=$i; $j++) {
	if ($b1[$j] < $b2[$j]) {
		print "KM362176.1\tNCBI\t$type[$j]\t$b1[$j]\t$b2[$j]\t.\t+\t.\tID=$ID[$j]\n";
	}
	elsif ($b1[$j] > $b2[$j]) {
		print "KM362176.1\tNCBI\t$type[$j]\t$b2[$j]\t$b1[$j]\t.\t-\t.\tID=$ID[$j]\n";
	}
}
