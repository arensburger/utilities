#!/usr/bin/perl
### August 2014. Takes a genome file, a gtf file and extracts the appropriate sequences into a fasta file

use strict;
use diagnostics;
use warnings;
use Getopt::Long;
use agutils;
#use File::Temp ();
use File::Temp qw(tempdir);

##> Define options
my %config;
GetOptions (\%config,
            'fasta=s',
	    'gtf=s',
	    'listgenes=s',
            'out=s',
            'help');

##> Print USAGE if --help
if ($config{help}) {printUsage(1);}

##> Check if no mandatory parameter is missing and set defaults
if (!exists $config{fasta})         {printUsage();}
if (!exists $config{gtf})         {printUsage();}
if (!exists $config{out}) {$config{out} = "out";}

### Main program ###

## load the list of genes if provided
my %genelist; # holds the name of the genes as key;
if (exists $config{listgenes}) {
	open (LISTGENE, $config{listgenes}) or die "Cannot open list of genes file in $config{listgenes}\n";
	while (my $line = <LISTGENE>) {
		chomp $line;
		if ($line =~ />(\S+)/) {
			$genelist{$1} = 0;
		}
		else {
			$genelist{$line} = 0;
		}
	}
	close LISTGENE;
}

## read the gtf file and identify the relevant lines write these in a temporary file ##
my $gtf_output = File::Temp->new( UNLINK => 1, SUFFIX => '.gtf' ); # temporary file with parsed gtf file
open (OUTPUTGTF, ">$gtf_output") or die "cannot create temporary file $gtf_output to output gtf into\n"; # temporary GTF
open (GTF, $config{gtf}) or die "Cannot open gtf file $config{gtf}\n"; # original GTF
while (my $line = <GTF>) {
	my @data = split(" ", $line);
	if ((exists $data[2]) and ($data[2] eq "gene")) {
		if (%genelist) { # check if the hash containing gene list is not empty
			chop($data[9]); # remove the last two and the first character
			chop($data[9]);
			my $genename = substr $data[9], 1;
			if (exists $genelist{$genename}) {
				print OUTPUTGTF $line;
			}
		}
		else {
			print OUTPUTGTF $line;
		}
	}
}
close GTF;
close OUTPUTGTF;

## get the fasta file out using bedtools
my $cmdres = `bedtools getfasta -fi $config{fasta} -bed $gtf_output  -fo $config{out}`;
print "done\n";

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

print STDOUT "USAGE : parse-gtf -f \"genome reads in fasta format\" -g \"gtf file\" -l \"list of genes\" -o \"output file\"
Options : 
    -f | fasta		Genome input fasta file (Mandatory)
    -g | gtf	 	Name of gtf file to use (Mandatory)
    -l | listgenes	list of genes to output (Optional)
    -o | out   		Name of ouput file (default \"out\")
    -h | help		You already know it ...\n\n";
    exit;
}
