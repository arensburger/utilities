#!/usr/bin/perl

use strict;

open(INPUT, $ARGV[0]) or die;

while (my $line = <INPUT>) {
	if ($line =~ /^(\S+)\s+(\d+)\s+(\S+)\s+(\d+)\s+(\d+)/) {
		my $name = $1;
		my $ori = $2;
		my $scaf = $3;
		my $b1 = $4;
		my $b2 = $4+$5;
		my $skip = 0; # boolean set to 1 if skip this
		if ($ori == 0) {
			$ori = "+";
		}
		elsif ($ori == 16) {
			$ori = "-";
		}
#		else {
#			die "do not know orientation code $ori\n";
#		}
		
		unless ($skip) {
			print "$scaf\t$b1\t$b2\t$name\t0\t$ori\n";
		}
	}
	else {
		warn "cannot read line\n$line";
	}
}
