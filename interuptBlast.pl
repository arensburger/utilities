#!/usr/bin/perl

use strict;
use Getopt::Long;

my $fastafilename; #input fasta
my $blastoutput; #partial blast output
my $outputname; #file for program output
my $i;
my $j;

##### read and check the inputs
GetOptions(
	'f:s'   => \$fastafilename,
        'b:s'   => \$blastoutput,
);
unless ($fastafilename and $blastoutput) {
	print "program usage: perl interuptBlast -f <REQUIRED, input fasta file used with blast> -b <REQUIRED, partial blast output>\n";
	exit;
}

# get the last blast reference
my $lastblastline = `tail -n 1 $blastoutput`;
my @data = split(" ", $lastblastline);
my $lastref = $data[0];

#print lines after last hit
open (INPUT, $fastafilename) or die;
my $printline=0; # boolean only print after set to 1
while (my $line = <INPUT>) {
	$j++;
	if ($printline) {
		print $line;
	}
	else {
		$i++;
		if ($line =~ />(\S+)\s/) {
			my $t=$1;
			if ($t eq $lastref) {
				$printline = 1;
			}
		}
	}
}
my $percent = $i/$j;
print STDERR "$percent\n";
