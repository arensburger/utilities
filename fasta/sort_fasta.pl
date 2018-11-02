#!/usr/bin/perl
# November 2018 Take a fasta file as input and sorts it by header

use strict;
use Getopt::Long;

my $input_file; # input fasta file
GetOptions(
	'in:s' => \$input_file,
);
die ("usage: perl sort_fasta.pl -in <REQUIRED: fasta formated file>\n") unless ($input_file);
open (INPUT, $input_file) or die "Cannot open file $input_file\n";

### collect data
my %seq; # holds the headers as key and sequences as values
my $header = <INPUT>; # store the first header
my $sequence; # current sequence
while (my $line = <INPUT>) {
	if ($line =~ /^>/) {
		$seq{$header} = $sequence;
		chomp $line;
		$header = $line;
		$sequence = "";
	}
	else {
		chomp $line;
		$sequence .= $line;
	}
}

### print the results in the order desired
foreach my $head (sort keys %seq) {
	print "$head\n";
	print "$seq{$head}\n"
}
