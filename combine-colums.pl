#!/usr/bin/perl

# January 2018 upated to report mutliple data points
# July 2017 updated to allow options

use strict;
use Getopt::Long;
use File::Basename;

my %reads;
my $filenames; # separated by commas
my $zeros; # add zeros in places where RPKM values are missing
my $column_number = 0; # column number to report starting with 1, if 0 then report all columns

GetOptions(
	'in:s'  => \$filenames,
	'z'	=> \$zeros,
	'c:i'	=> \$column_number,
);
die ("usage: perl combine-columns.pl -in <REQUIRED: input files separated by commas> -z <OPTIONAL: put zeros where values are missing> -c <OPTIONAL: column number to report starting with 1, default all columns are reported\n") unless ($filenames);

# read the data and put results into %reads
my @filenames = split (",", $filenames); # the comma is for csv files as input
for (my $i=0; $i < scalar @filenames; $i++) { # loop through the file names
	open (INPUT, $filenames[$i]) or die "cannot open file $filenames[$i]\n";
	while (my $line = <INPUT>) { #loop through each line of the file
		my @data = split (",", $line);
		my $first_element = shift @data;

		#decide if only one colum or all need to be stored
		my $data2string; # holds the data to report
		if ($column_number) {
			$data2string = "\t$data[$column_number - 2]";
			chomp $data2string;
		}
		else {
			$data2string = join "\t", @data;
		}

		#store the data
		$reads{$first_element}[$i] = $data2string;
	}
	close INPUT;
}

# report results

# print header
print "first column";
for (my $i=0; $i < @filenames; $i++) {
	my $colname = basename($filenames[$i]);
	print "\t$colname";
}
print "\n";

# print data
for my $name (keys %reads) {
	print "$name";
	for (my $i=0; $i < scalar @filenames; $i++) {
		if (exists $reads{$name}[$i]) {
			print "$reads{$name}[$i]";
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
