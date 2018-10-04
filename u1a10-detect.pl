#!/usr/bin/perl
# Takes a SAM file and report location of U1A10 overlaps
# updated Oct 2013 to accept broader range of sam input, still needs lots of work

use strict;

my %topu1; #holds the location of U1 on top strand as key, name of sequence as value
my %botu1; #holds the location of U1 on bottom strand as key, name of sequence as value

#read the file, store the locations
open (INPUT, $ARGV[0]) or die "cannot open file $ARGV[0]\n";
while (my $line = <INPUT>) {
	if ($line =~ /^(\S+)\s(\d+)\s(\S+)\s(\d+)\s\d+\s\S+\s\S+\s\S+\s\S+\s(\S+)/) {
		my $name = $1;
		my $ori = $2;
		my $contig = $3;
		my $loc = $4;
		my $seq = $5;

		if (($ori == 0) or ($ori == 256)) {
			if (substr($seq, 0, 1) eq "T") {
				$topu1{$loc} .= "$name,";
			}
		}
		elsif (($ori == 16) or ($ori == 272)) {
			if (substr($seq, -1, 1) eq "A") {
				$botu1{$loc + (length $seq) - 1} .= "$name,";
			}
		}
		else {
			die "expecting only 0 or 16 for column 2 of the file, but found:\n$line";
		}
	}
	elsif ($line =~ /^@/) {
	}
	else {
		die "cannot read line\n$line";
	}
}
close INPUT;

#find matches between top and bottom strand
foreach my $location (keys %topu1) {
	my $location2 = $location + 9;
print "$location\n";
	if (exists $botu1{$location2}) {
		chop $topu1{$location};
		chop $botu1{$location2};
		print "$location\t$location2\t$topu1{$location}\t$botu1{$location2}\n";
	}
}
