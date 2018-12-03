#!/usr/bin/perl
# December 2018 changes the names of a fasta file

use strict;
use Getopt::Long;

### load data
my $i; # input fasta file1
my $suffix; #text to put ahead of new title
GetOptions(
	'in:s' => \$i,
	's:s' => \$suffix,
);
die ("usage: perl rename_fasta.pl -in <REQUIRED: fasta formated file> -s <OPTIONAL: suffix, text to put as new title followed by number\n") unless ($i);
unless ($suffix) {
	$suffix = "seq";
}

open (INPUT, $i) or die ("Cannot open file $i\n");
my $i=0;
while (my $line = <INPUT>) {
	if ($line =~ />(.+)\s$/) {
		print ">$suffix", "$i", " ", "$1", "\n";
		$i++;
	}
	else {
		print "$line";
	}
}
