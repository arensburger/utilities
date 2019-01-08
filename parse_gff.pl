#! /usr/bin/perl
# Jan 2019 Take as gff file as input and processes it

use strict;
use Getopt::Long;

my $INPUTGFF; #filename of input gff3
my $number;

### set and test inputs
GetOptions(
	'in:s'     => \$INPUTGFF,
	'n:s'			 => \$number
 );
unless (defined $INPUTGFF) {
		die "usage: perl parse_gff -in <REQUIRED: GFF file input>\n";
}
open (INPUT, $INPUTGFF) or die "cannot open file $INPUTGFF";

### Run through the file line by line
while (my $line = <INPUT>) {
	unless ($line =~ /^#/) { # exclude comment lines
		if ($line =~ /(\d+)\s$/) {
			my $value = $1;
			if ($value == $number) {
				print "$line";
			}
		}
	}
}
close (INPUT);
