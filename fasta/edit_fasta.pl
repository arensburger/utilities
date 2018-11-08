#!/usr/bin/perl
# November 2018 Take a fasta file returns the same file with specified edits

use strict;
use Getopt::Long;

my $input_file; # input fasta file
GetOptions(
	'in:s' => \$input_file,
);
die ("usage: perl edit_fasta.pl -in <REQUIRED: fasta formated file>\n") unless ($input_file);
open (INPUT, $input_file) or die "Cannot open file $input_file\n";

### collect data
my %seq; # holds the headers as key and sequences as values
my $header = <INPUT>; # store the first header
chomp $header;
my $sequence; # current sequence
while (my $line = <INPUT>) {
	if ($line =~ /^(>\S+?_)_*(.+)/) {
		print "$1", "_", "$2", "\n";
	}
	else {
		print "$line"
	}
}
