#!/usr/bin/perl

use strict;

open (INPUT, $ARGV[0]) or die; #read the bed output

my %re; # reads to extract
while (my $line = <INPUT>) {
	if ($line =~ /^\S+\s\d+\t\d+\s(\S+)/) {
		$re{$1} = 1;
	}
	else {
		die "cannot read sam line\n$line";
	}
}
close INPUT;

# scroll and extract relevant reads
my %printed; # holds a record of printed sequence
open (INPUT, $ARGV[1]);
while (my $l1 = <INPUT>) {
	my $l2 = <INPUT>;
	my $l3 = <INPUT>;
	my $l4 = <INPUT>;
	if ($l1 =~ /^@(\S+)/) {
		my $name = $1;
		if (exists $re{$name}) {
			unless (exists $printed{$l1}) {
				print "$l1";
				print "$l2";
				print "$l3";
				print "$l4";
				$printed{$l1} = 1
			}
		}
		else {
		#	print "$l1\n";
		}	
	}
	else {
		die "cannot read fq header\n$l1";
	}
}

