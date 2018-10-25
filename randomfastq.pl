#!/usr/bin/perl
#Takes two fastq file (one in each direction), shuffles the sequences and returns files with the sequences randomized
use strict;

use strict;
#require File::Temp;
use File::Temp ();
#use File::Basename;
use Getopt::Long;
#use File::Path;
use List::Util 'shuffle';

##> Define options
my %config;
GetOptions (\%config,
            '1=s',
            '2=s',
	    'out=s',
	    'r=s',
            'help');

##> Print USAGE if --help
if ($config{help}) {printUsage(1);}

##> Check if no mandatory parameter is missing and set defaults
if (!exists $config{1})         {printUsage();}
if (!exists $config{2})         {printUsage();}
if (!exists $config{out}) {$config{out} = "out";}

my %seqstoprint; #holds number of line to print as key
if ($config{r}) {
	my $wc = `wc -l $config{1}`;
	my @data = split(" ", $wc);
	my $fastqseqs = $data[0]/8; # number of sequences in pairs the fastq file
	my @seqnum; #array holding sequence numbers
	for (my $i=0; $i<=$fastqseqs; $i++) {
		push @seqnum, $i;
	}
	my @randseqnum = shuffle @seqnum; # randomize array
	for (my $i=0; $i<$config{r}; $i++) {
		$seqstoprint{$randseqnum[$i]}=0;
	}
}

###### produce data
my $seqnum=-1;
open (INPUT1, $config{1}) or die "cannot open input file $config{1}\n";
open (INPUT2, $config{2}) or die "cannot open input file $config{2}\n";
my $outname1 = "$config{out}" . "-1.fq";
my $outname2 = "$config{out}" . "-2.fq";
open (OUTPUT1, ">$outname1") or die "cannot open output file $outname1\n";
open (OUTPUT2, ">$outname2") or die "cannot open output file $outname2\n";
while (my $l1 = <INPUT1>) {

	$seqnum++;
	my @data = split(" ", $l1);
	$l1 = $data[0];
	my $l2 = <INPUT1> . <INPUT1> . <INPUT1>;
	my $l3 =  <INPUT2>;
	my @data = split(" ", $l3);
	$l3 = $data[0];
	my $l4 = <INPUT2> . <INPUT2> . <INPUT2>;

	my $printok=0; # boolean for printing this or not
	my $skip=0; # if randomize this be used to skip lines not in the array
	if ($config{r}) {
		unless (exists $seqstoprint{$seqnum}) {
			$skip=1;
		}
	}
	next if $skip;

	# test if the pair is intact
	if ($l1 eq $l3) {
		$printok=1;
	}
	else {
		die "sequences are not the same\n$l1\n$l3\n";
	}

	if ($printok) {
		print OUTPUT1 "$l1", "\n";
		print OUTPUT1 "$l2";
		print OUTPUT2 "$l3", "\n";
		print OUTPUT2 "$l4";
	}
}
close INPUT1;
close INPUT2;
close OUTPUT1;
close OUTPUT2;

###########################################################################
################################ Functions ################################
###########################################################################


###########################################################################
sub printUsage{

print STDOUT "USAGE : perl randomfastq.pl -1 \"fastq file pair 1\" -2 \"fastq file pair 2\" -r \"number of random sequence pairs to pick out\" -o \"output file\"
Options :
    -1 		fastq file in one direction (Mandatory)
    -2 		fastq file in other direction (Mandatory)
    -r 		Number of random sequences to output
    -o    	Name of ouput file (default \"out\")
    -h 		You already know it ...\n\n";
    exit;
}
