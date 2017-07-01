#!/usr/bin/perl

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
die ("usage: perl combine-columns.pl -in <REQUIRED: input files separated by commas> -z <OPTIONAL: put zeros where RPKMs are missing>>\n") unless ($filenames);

my @filenames = split (",", $filenames);
for (my $i=0; $i < scalar @filenames; $i++) {
	open (INPUT, $filenames[$i]) or die "cannot open file $filenames[$i]\n";
	while (my $line = <INPUT>) {
		my @data = split (" ", $line);
		$reads{$data[0]}[$i] = $data[1];
	}
	close INPUT;
}

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
