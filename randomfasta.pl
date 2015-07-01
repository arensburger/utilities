#!/usr/bin/perl

# June 2015 samples random sequences from a fasta formated file

use strict;
use File::Temp ();
use Getopt::Long;
use List::Util 'shuffle';

##> Define options
my %config;
GetOptions (\%config,
            'in=s',
            'n=s',
	    'out=s',
            'help');

##> Print USAGE if --help
if ($config{help}) {printUsage(1);}

##> Check if no mandatory parameter is missing and set defaults
if (!exists $config{in})        {printUsage();}
if (!exists $config{n})         {printUsage();}
if (!exists $config{out}) {$config{out} = "out";}


##> Count the number of lines and set up random indexes to print
my %seqstoprint; #holds number of line to print as key
my $wc = `wc -l $config{in}`;	
my @data = split(" ", $wc);
my $fastqseqs = $data[0]/2; # this assumes there is only one line of data
my @seqnum; #array holding sequence numbers
for (my $i=0; $i<=$fastqseqs; $i++) {
	push @seqnum, $i;
}
my @randseqnum = shuffle @seqnum; # randomize array
for (my $i=0; $i<$config{n}; $i++) {
	$seqstoprint{$randseqnum[$i]}=0;
}

##> print data
my $seqnum=-1;
open (INPUT1, $config{in}) or die "cannot open input file $config{in}\n";
my $outname1 = "$config{out}";
open (OUTPUT1, ">$outname1") or die "cannot open output file $outname1\n";
while (my $l1 = <INPUT1>) {
	$seqnum++;
	my $l2 = <INPUT1>;

	##> decide if need print this line or not
	my $printok=0; # boolean for printing this or not
	if (exists $seqstoprint{$seqnum}) {
		$printok=1;
	}
	next unless $printok;

	print OUTPUT1 "$l1";
	print OUTPUT1 "$l2";
	
}
close INPUT1;
close OUTPUT1;

###########################################################################
################################ Functions ################################
###########################################################################


###########################################################################
sub printUsage{

print STDOUT "USAGE : perl randomfasta.pl -in \"fasta file\" -n \"number of sequences to sample\" -o \"output file\"
Options : 
    -in 	fasta file where each sequence is only one line long (Mandatory)
    -n 		number of sequences to sample (Mandatory)
    -o    	Name of ouput file (default \"out\")
    -h 		You already know it ...\n\n";
    exit;
}
