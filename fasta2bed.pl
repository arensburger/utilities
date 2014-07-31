#!/usr/bin/perl -w

# July 2014 takes a fasta file and turns it into a simple bed file

use strict;
use diagnostics;
#use warnings;
use Getopt::Long;
use agutils;
#use Term::ANSIColor;
#use Data::Dumper;


#> Setting Parameters
##> Define outputs colors
#print STDOUT color 'blue';
#print STDERR color 'red';

##> Define options
my %config;
GetOptions (\%config,
            'fasta=s',
            'out=s',
            'verbose',
            'debug',
            'help');

##> Print USAGE if --help
if ($config{help}) {printUsage(1);}

##> Check if no mandatory parameter is missing 
if (!exists $config{fasta})         {printError ("fasta option is MANDATORY ! \n", 0); printUsage();}
if (!exists $config{out}) {$config{out} = "out";}

## open output file
open(BED, ">$config{out}.bed") or die printError("Unable to open $config{out}.bed\n", 1);
## read the fasta file
my %fasta = genometohash($config{fasta});
foreach my $seq (keys %fasta) {
	my $seqlen = length $fasta{$seq};
	print BED "$seq\t1\t$seqlen\tBUSCO\n";
}
close BED;
exit;


###########################################################################
################################ Functions ################################
###########################################################################
sub printError{
    my $string = shift;
    my $exit = shift;
    
    print STDERR $string;
    exit if $exit;
}

###########################################################################
sub printUsage{

    print STDOUT
"USAGE : fasta2bed -f \"fasta format file\" -o \"base name of bed file\"
    
Options : 
    -f | fasta		Input fasta file (Mandatory)
    -o | out   		Basename of bed ouput file (default \"out\")
    -v | verbose	MORE text dude !!!!
    -h | help		You already know it ...\n\n";
    exit;
}
