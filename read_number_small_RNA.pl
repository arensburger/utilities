#!/usr/bin/perl
# June 2017 takes the output file of a small RNA library and reports the number of reads

use strict;
use Getopt::Long;

### read and check the inputs
my $inputfile; 

GetOptions(
	'in:s'   => \$inputfile
);
unless ($inputfile) {
	die ("usage: perl read_number_small_RNA -in <input file REQUIRED>");
}

my $sum;
open (INPUT, $inputfile) or die "cannot open file $inputfile\n";
while (my $line = <INPUT>) {
	if ($line =~ />\d+-(\d+)/) {
		$sum += $1;
	}
}
print "$sum\t$inputfile\n";
