#!/usr/bin/perl -w
# Takes the output of BLAT (PSL format) and turns it into a simple bed file

use strict;
#use diagnostics;
use Getopt::Long;

##> Define options
my %config;
GetOptions (\%config,
            'psl=s',
            );

##> Print USAGE if --help
if ($config{help}) {printUsage(1);}

##> Check if no mandatory parameter is missing
if (!exists $config{psl})         {printError ("PSL option is MANDATORY ! \n", 0); printUsage();}

## read the psl file
open (INPUT, $config{psl}) or die printError("Unable to open $config{psl}\n", 1);
# read past the blat header
for (my $i=0; $i<5; $i++) {
  <INPUT>;
}

# parse and report the blat lines
while (my $line = <INPUT>) {
  my @data = split " ", $line;
  print "$data[9]\t$data[11]\t$data[12]\n"
}


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
"USAGE : PSL2b -p \"PSL format file\"

Options :
    -p | psl		Input PSL file (Mandatory)\n";
    exit;
}
