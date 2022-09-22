#!/usr/bin/perl
# June 2019, filter fq by length

use strict;
use Getopt::Long;

my $inputfilename; # name of the input $filename
my $length;  # minimum sequence length
##### read and check the inputs
GetOptions(
	'in:s'   => \$inputfilename,
	'l:s'	=> \$length,
);
unless ($inputfilename and $length) {
	die "usage perl filter_fq_by_length.pl <-in, input fastq file REQUIRED> <-l minimum length to output REQUIRED>";
}

open (INPUT, $inputfilename) or die "cannot open file $inputfilename\n";
while (my $l1 = <INPUT>) {
	my $l2 = <INPUT>;
	my $l3 = <INPUT>;
	my $l4 = <INPUT>;

	my $sequence = $l2;
	chomp $sequence;
	if ((length $sequence) >= $length) {
		print "$l1";
		print "$l2";
		print "$l3";
		print "$l4";
	}
}
