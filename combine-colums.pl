#!/usr/bin/perl

use strict;

my %reads;

for (my $i=0; $i < scalar @ARGV; $i++) {
	open (INPUT, $ARGV[$i]) or die "cannot open file $ARGV[$i]\n";
	while (my $line = <INPUT>) {
		my @data = split (" ", $line);
		$reads{$data[0]}[$i] = $data[1];
	}
	close INPUT;
}

for my $name (keys %reads) {
	print "$name";
#	for my $i (0 .. $#{ $reads{$name} } ) {
	for (my $i=0; $i < scalar @ARGV; $i++) {
		if (exists $reads{$name}[$i]) { 
			print "\t$reads{$name}[$i]";
		}
		else {
			print "\t0";
		}
	}
	print "\n";
}
