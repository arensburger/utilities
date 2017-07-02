#!/usr/bin/perl

# July 2017 script take a tab delimited text of RPKMs (with first column text) and returns the same
# table but subtracting the first column from the values

use strict;
use Getopt::Long;

##### read and check the inputs
my $inputfile; # name of input file
my $headers; # if set then consider first line to be a header, copy it to output

GetOptions(
	'in:s'  => \$inputfile,
	'h'	=> \$headers
);
die ("usage: perl subtract_rpkm.pl -in <REQUIRED: input file, tab delimited text> -h <OPTIONAL: first line is header>\n") unless ($inputfile);

open (INPUT, $inputfile) or die ("cannot open file $inputfile\n");
if ($headers) {
	my $line = <INPUT>;
	print $line;
}
while (my $line = <INPUT>) {
	if ($line =~ /\S+/) { # only consider non-empty lines
		my @data = split(" ", $line);
		print "$data[0]";
		for (my $i=2; $i < ((scalar @data)-1); $i++) {
			my $new_rpkm = $data[$i] - $data[1];
			if ($new_rpkm < 0) {
				$new_rpkm = 0;
			}
			print "\t$new_rpkm";
		}
		print "\n";
	}
}
