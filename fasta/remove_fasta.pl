#!/usr/bin/perl
# This script take a fasta file and a list of headers and returns fasta without sequences with headers

use strict;
use Getopt::Long;

my $filename; #name of input fasta file
my $header_file; # name of file with headers

### read and check the inputs
GetOptions(
	'in:s'   => \$filename,
	'h:s'	=> \$header_file
);
unless ($filename) {
	die "usage perl remove_fasta.pl <-in fasta file name REQUIRED> <-h file with headers to remove REQUIRED>\n";
}

### read the list of headers to remove_fasta
open (INPUT, $header_file) or die "cannot open header file $header_file\n";
my @headers_to_remove;
while (my $line = <INPUT>) {
	chomp $line;
	if ($line =~ /\S/) { # makes sure that blank lines don't get processed
		push @headers_to_remove, $line;
	}
}

### read the fasta file
open (INPUT, $filename) or die "cannot open fasta input file $filename\n";

#go through the the file
my %seq; # hash of input file, header as key and sequence as value
my $header; # current header
my $text; # current sequence
my @found; # array that is blank if the current sequence should be kept, and not empty if it should be removed
while (my $line=<INPUT>) {
	if ($line =~ /^>/) {
		@found = grep {$line =~ /$_/} @headers_to_remove;
		unless (scalar @found) {
			print $line;
		}
	}
	else {
		unless (scalar @found) {
			print "$line";
		}
	}
}
close INPUT;
