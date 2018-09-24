#!/usr/bin/perl

### compares the headers between two fasta files
### assumes file 1 is the reference so looks for headers of file 1 inside of headers for file 2
use strict;

use strict;
use Getopt::Long;

my $file1; # file 1 in fasta format
my $file2; # file 2 in fasta format
my $num_h1; # number of headers for file 1
my $num_h2; # number of headers for file 2
GetOptions(
	'1:s'  => \$file1,
	'2:s'	=> \$file2
);
die ("usage: perl compare_fasta -1 <REQUIRED: input file in fasta format> -2 <REQUIRED: input file in fasta format\n") unless ($file1 and $file2);

### read the headers
my %f1headers; # holds the header as key and the number of times it matches to headers in file 2 as value
open (INPUT, $file1) or die "cannot open $file1\n";
while (my $line = <INPUT>) {
#	if ($line =~ />(\S+)/) {
	if ($line =~ />( TF\d+)/) {
		$f1headers{$1} = 0;
		$num_h1++;
	}
}
close INPUT;

my $f2headers; # text file f2 headers
open (INPUT, $file2) or die "cannot open $file2\n";
while (my $line = <INPUT>) {
#	if ($line =~ />(\S+)/) {
	if ($line =~ />(TF\d+)/) {
		$f2headers .= $1;
		$num_h2++;
	}
}
close INPUT;

### compare the headers
my $numh1matchh2; # number of headers from h1 that match h2
my $numh1noh2; # number of headers from h1 that do not match h2
my $head_print; # headers to print
foreach my $h (keys %f1headers) {
	if ($f2headers =~ /$h/) {
		$f1headers{$h} += 1;
		$numh1matchh2++;
	}
	else {
		$numh1noh2++;
		$head_print .= "$h\n";
	}
}

### print the results
#my $numh1inh2; # number of h1 headers found in h2
#foreach my $h (keys %f1headers) {
#	if ($f1headers{$h}) {
#		$numh1inh2++;
#	}
#}

print "number of headers in file 1 (h1): $num_h1\n";
print "number of headers in file 2 (h2): $num_h2\n";
print "number of h1 in h2: $numh1matchh2\n";
print "number of h1 not in h2 $numh1noh2\n";
print "headers in h1 not in h2:\n$head_print";
