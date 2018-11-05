#!/usr/bin/perl
# Nov 2018 finds a particular pattern in a file an returns
# all instances, reporting duplicates only once

use strict;
use Getopt::Long;

my $filename; #name of input file

##### read and check the inputs
GetOptions(
	'in:s'   => \$filename,
);
unless ($filename) {
	die "usage perl find_unique_pattern.pl <-in file name REQUIRED>\n";
}
open (INPUT, $filename) or die "cannot open input file $filename\n";

my %pat; # holds a unique copy of the pattern
while (my $line = <INPUT>){
	if ($line =~ /(pfam\d+)/) {
		$pat{$1}=0;
	}
}
foreach my $key (keys %pat){
	print "$key\n";
}
