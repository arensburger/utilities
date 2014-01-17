#! /usr/bin/perl
# Mon 07 May 2012 02:47:29 PM PDT find the longest ORF, requires EMBOSS' "getorf" to be installed
# returns the same fasta file but only sequences that pass the ORF length test
# Fri 11 May 2012 11:41:41 AM PDT added outcagegories

use strict;
require File::Temp;
use Getopt::Long;

#get inputs and check them
my $inputfile; #input fasta
my $minorfsize=150; #mininum size of ORF in nucleotides
my $methstart="no"; #boolean if 1 require that ORF start with Meth.
my $out_category=0; #what to output, 0=lines from original file that passed ORF test, 1=aa sequence of longest ORF
GetOptions(
	'i:s'   => \$inputfile,
	'l:s'	=> \$minorfsize,
	'm:s'	=> \$methstart,
	'o:s'	=> \$out_category
);
die "usage perl longest_orf.pl -i <fasta file> -l <OPTIONAL minimum orf size in nucleotides, default $minorfsize>, -m <OPTIONAL start with methonine, default $methstart>, -o <OPTIONAL out category: 0 (default) line from original fasta file, 1 amino acid sequence of longest ORF\n" unless ($inputfile);

#initialize hash to report input data if necessary
my %inputseq;

# find all the ORFs, put the results into a temporary file
#determine the value of the "find" parameter for "getorf"
my $findvalue = 0;
if ($methstart eq "yes") {
	$findvalue = 1;
}
#my $orf_filename = File::Temp->new( UNLINK => 1, SUFFIX => '.fas' ); #temp file
my $orf_filename = "temp.txt";
`getorf $inputfile -outseq $orf_filename -minsize $minorfsize -find $findvalue`;

#initialize the output hash and record current input sequence
my %orflen; #sequence name as key, length as value
my %orfseq; #sequence name as key, sequence as value
my $name; #current sequence name;
open (INPUT, $inputfile) or die;
while (my $line = <INPUT>) {
	if ($line =~ /^>(\S+)/) {
		$orflen{$1} = 0;
		$name = $1;
	}
	else {
		chomp $line;
		$inputseq{$name} .= $line;
	} 
}
close INPUT,

#populate the hash with determined lengths
open (INPUT, $orf_filename) or die;
my $seqname; #name of current sequence
my $seq; #current sequence
#get name of the first line
my $line = <INPUT>;
if ($line =~ />(\S+)_\d+\s/) {
	$seqname = $1; #name of current sequence	
}
else {
	die "errror reading file\n$line";
}

while ($line = <INPUT>) {
	if ($line =~ />(\S+)_\d+\s/) {
		my $new_seqname = $1; #name of next sequence
		my $length = length $seq;
		if ($length > $orflen{$seqname}) {
			$orflen{$seqname} = $length; #holds the lengths
			$orfseq{$seqname} = $seq; #holds the sequence
		}
		$seqname = $new_seqname;
		$seq = "";
	}
	else {
		chomp $line;
		$seq .= $line;
	}
}
close INPUT;

#output file
open (INPUT, $inputfile) or die;
while (my $line = <INPUT>) {
	if ($line =~ /^>(\S+)\s/) {
		my $name = $1;
		if ($orflen{$name} > 0) {
			print "$line";
			$line = <INPUT>;
			if ($out_category == 0) {
				print "$inputseq{$name}\n";
			}
			elsif ($out_category == 1) {
				print "$orfseq{$name}\n";
			}
			else {
				die "don't know out_category $out_category";
			}
		}
		else {
			<INPUT>;
		}
	}	
	else {
#		die "I died here:\n$line";
	}
}
