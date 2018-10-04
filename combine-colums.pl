#!/usr/bin/perl
# takes text files as input assuming the element of each line is refrence, and returns a file with data combined
# January 2018 upated to report mutliple data points
# July 2017 updated to allow options

use strict;
use Getopt::Long;

my %reads;
my $filenames; # separated by commas
my $zeros; # add zeros in places where RPKM values are missing
GetOptions(
	'in:s'  => \$filenames,
	'z'	=> \$zeros,
);
die ("usage: perl combine-columns.pl -in <REQUIRED: input files separated by commas> -z <OPTIONAL: put zeros where values are missing>>\n") unless ($filenames);

# read the data and put results into %reads
my @filenames = split (",", $filenames);
for (my $i=0; $i < scalar @filenames; $i++) { # loop through the file names
	open (INPUT, $filenames[$i]) or die "cannot open file $filenames[$i]\n";
	while (my $line = <INPUT>) { #loop through each line of the file
		my @data = split (" ", $line);
		my $first_element = shift @data;
		my $data2string = join "\t", @data;
		$reads{$first_element}[$i] = $data2string;
	}
	close INPUT;
}

# report results
for my $name (keys %reads) {
	print "$name";
	for (my $i=0; $i < scalar @filenames; $i++) {
		if (exists $reads{$name}[$i]) {
			print "\t$reads{$name}[$i]";
		}
		else {
			if ($zeros) {
				print "\t0";
			}
			else {
				print "\t";
			}
		}
	}
	print "\n";
}
