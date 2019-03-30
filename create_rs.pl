#!/usr/bin/perl

# March 2019 Takes an input file with file name and associated library name and outputs custom rs.sh file

use strict;
use Getopt::Long;

my %entries; # hash with reference in key and go terms in values
my $filename; # separated by commas
GetOptions(
	'in:s'  => \$filename,
);
die ("usage: perl create_rs.pl -in <REQUIRED: input file with filename followd by library name>\n") unless ($filename);

# read the data and put results into %reads
open (INPUT, $filename) or die "cannot open file $filename\n";
while (my $line = <INPUT>) { #loop through each line of the file
	my @data = split " ", $line;
	print "gunzip $data[0]", ".gz", "\n";
	print "perl clean_single.pl -1 $data[0] -d $data[1] -o $data[1]\n";
	print "gzip $data[1]/$data[1]-unpaired.fq\n"
}
close INPUT;
