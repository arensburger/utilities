#!/usr/bin/perl

# Aug 2015 This script takes as input a fasta file and a fastq file and filters out the fastq by the fasta sequences

use strict;
use Getopt::Long;

##> Define options
my %config;
GetOptions (\%config,
            'f=s',
	    'q=s',
	    'o=s',
            'help');

##> Print USAGE if --help
if ($config{help}) {printUsage(1);}

##> Check if no mandatory parameter is missing and set defaults
if (!exists $config{f})         {printUsage();}
if (!exists $config{q})         {printUsage();}
if (!exists $config{o}) 	{$config{o} = "out.fq";}

open (OUTPUT, ">$config{o}") or die "cannot open output file $config{out}\n";

## Read the fasta file and store the unique sequences
my %fastaseq; # holds the sequences of the fasta files
open (FASTA, "$config{f}") or die "cannot open input fasta file $config{f}\n";
while(my $line = <FASTA>) {
	if ($line =~ /^>/) {
		$line = <FASTA>;
#		chomp $line;
		$fastaseq{$line} += 1;
	}
	else {
		warn ("WARNING: unexpected line in fasta file\n$line"); # checking the interity of the fasta file
	}
}
close FASTA;

## Read the fastq file (4 lines at a time) and output those lines that match %fastaseq
my @fastqfile; # holds the fastq file, one line per element
open (FASTQ, "$config{q}") or die "cannot open input fastq file $config{f}\n";
while (my $l1 = <FASTQ>) {
	my $l2 = <FASTQ>;
	my $l3 = <FASTQ>;
	my $l4 = <FASTQ>;

	# checking the integrity of the fastq file
	unless ($l3 =~ /^\+/) {
		warn("WARNING: fastq element not formated correctly\n","$l1", "$l2", "$l3", "$l4");
	}

	if ($fastaseq{$l2}) {
		print OUTPUT "$l1", "$l2", "$l3", "$l4";
	}	
}
close FASTQ;

close OUTPUT;

###########################################################################
sub printUsage{

print STDOUT "PURPOSE: This script takes as input a fasta file and a fastq file and filters out the fastq by the fasta sequences
USAGE : filter_fq_by_fa.pl -f \"input fasta file\" -q \"input fastq file\" -o \"output file\"
Options : 
    -f 		Input fasta file (Mandatory)
    -q 		Input fastq file (Mandatory)
    -o   	Name of ouput file (default \"out.fq\")
    -h 		help\n";
    exit;
}
