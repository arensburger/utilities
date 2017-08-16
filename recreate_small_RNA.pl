#!/usr/bin/perl
### August 2017. Take a small RNA fasta file where the duplicates are identified in the fasta header and creates a new file with unique names for each sequence

use strict;
use Getopt::Long;


##> Define options
my %config;
GetOptions (\%config,
            'in=s',
#            'out=s',
            'help');

##> Print USAGE if --help
if ($config{help}) {printUsage(1);}

##> Check if no mandatory parameter is missing and set defaults
if (!exists $config{in})         {printUsage();}
#if (!exists $config{out}) {$config{out} = "out";}

### Main program ###

my $i=1;
open (INPUT, $config{in}) or die "cannot open file $config{in}\n";
while (my $line = <INPUT>) {
	my $abundance; #number of time this read is repeated
	if ($line =~ />\S+-(\d+)/) {
		$abundance = $1;
		$line = <INPUT>;
		for (my $j=0; $j<$abundance; $j++) {
			print ">$i\n";
			print $line;
			$i++;
		}
	}
	else {
		die "cannot read fasta header\n$line";
	}
	
}
close INPUT;

# print output #



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

print STDOUT "USAGE : perl recreate_small_RNA.pl -in \"input fastq file\"
Options : 
    -in | text		clustalw output file (Mandatory)
    -h | help		You already know it ...\n\n";
    exit;
}
