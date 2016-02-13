#!/usr/bin/perl

# Jan 2014 this script compares two fasta files (such as alignments) using blat 
# and outputs data using this 

use strict;
use File::Temp ();
use Getopt::Long;

# Variable declation
my $SIM_THRESHOLD = 90; #percent identity
my $LEN_THRESHOLD = 90; #length identity
my $blat_path = "/rhome/parensburger/bin"; # path to BLAT program
my $blat_output = File::Temp->new( UNLINK => 1, SUFFIX => '.blat' ); # temporary file with blat ouput
my $file1; #fasta file name
my $file2; #fasta file name
my $outputname; #prefix of output files
my %identical_f1; #holds the names of the sequences in f1 that have identities in f2
my %identical_f2; #holds the names of the sequences in f2 that have identities in f1
my $output_blat_results = 0;
my $existing_blat_file; #name of existing blat file, if available

#####read and check the inputs
GetOptions(
        'f1:s'   => \$file1,
        'f2:s'   => \$file2,
        'o:s'    => \$outputname,
	's:s'    => \$SIM_THRESHOLD,
	'l:s'	 => \$LEN_THRESHOLD,
	'b:s'	 => \$output_blat_results,
	'e:s'	 => \$existing_blat_file,
);
unless ($file1 and $file2 and $outputname) {
        die ("usage: perl cmpalig.pl -f1 <FASTA file1> -f2 <FASTA file2> -o <prefix for output files> -s <OPTIONAL: percent sequence similarity, default $SIM_THRESHOLD> -l <OPTIONAL: percent length identity, default $LEN_THRESHOLD>, -b <OPTIONAL: output blat raw data file, set to 0 for no, 1 for yes, default $output_blat_results>, -e <OPTIONAL: you can provide your own blat output file to analyze (but -f1, -f2, and -o arguments are still required)>\n");
}

##### run blat
if ($existing_blat_file) { 
	$blat_output = $existing_blat_file;
}
else {
	unless(`$blat_path/blat $file1 $file2 -minIdentity=$SIM_THRESHOLD $blat_output`){
	        die "Cannot find blat program in path provided ($blat_path)\n";
	}
}

# ouput the blat results if requested
if ($output_blat_results) {
       	my $blat_file_name = $outputname . "-blat.txt";
       	`cp $blat_output $blat_file_name`;
}
open (INPUT, $blat_output) or die "cannot open blat ouput at $blat_output\n";
<INPUT>;
<INPUT>;
<INPUT>;
<INPUT>;
<INPUT>;
while (my $line = <INPUT>) {
	my @data = split("\t", $line);
	my $matches = $data[0];
	my $name_f1 = $data[9];
	my $length_f1 = $data[10];
	my $name_f2 = $data[13];
	my $length_f2 = $data[14];
	my $minlen = ($length_f1, $length_f2)[$length_f1 > $length_f2]; #smallest of the two lengths
#	my $propid = $matches/$min; #proportion of identity compared to the shortest length

	my $length_similarity = 100 - ((abs($length_f1 - $length_f2)/$minlen) * 100);
	if ($length_similarity >= $LEN_THRESHOLD) { #length threshold
		if ((100*($matches/$minlen)) >= $SIM_THRESHOLD) { #similarity threshold
			$identical_f1{$name_f1} = $name_f2;
			$identical_f2{$name_f2} = $name_f1;
		}
	}	
}	

##### read the orginal input files and prepare outputs
my $same_file1_seq = $outputname . "-same1.fa";
my $same_file2_seq = $outputname . "-same2.fa";
my $diff_file1_seq = $outputname . "-diff1.fa";
my $diff_file2_seq = $outputname . "-diff2.fa";
open (OUTPUT1, ">$same_file1_seq") or die "cannot open file $same_file1_seq";
open (OUTPUT2, ">$diff_file1_seq") or die "cannot open file $diff_file1_seq";
open (OUTPUT3, ">$same_file2_seq") or die "cannot open file $same_file2_seq";
open (OUTPUT4, ">$diff_file2_seq") or die "cannot open file $diff_file2_seq";

my %seq1 = fastatohash($file1);
foreach my $sequence_name(keys %seq1) {
	if($sequence_name =~ />(\S+)/) {
		my $short_seq_name = $1;
		if (exists $identical_f1{$short_seq_name}) {
			print OUTPUT1 ">$short_seq_name\n";
			print OUTPUT1 "$seq1{$sequence_name}\n";
		}	
		else {
			print OUTPUT2 ">$short_seq_name\n";
			print OUTPUT2 "$seq1{$sequence_name}\n";
		}
	}
	else {
		die "Error reading fasta file $file1, $sequence_name\n";
	}
}

my %seq2 = fastatohash($file2);
foreach my $sequence_name(keys %seq2) {
        if($sequence_name =~ />(\S+)/) {
                my $short_seq_name = $1;
                if (exists $identical_f2{$short_seq_name}) {
                        print OUTPUT3 ">$short_seq_name\n";
                        print OUTPUT3 "$seq2{$sequence_name}\n";
                }
                else {
                        print OUTPUT4 ">$short_seq_name\n";
                        print OUTPUT4 "$seq2{$sequence_name}\n";
                }
        }
        else {
                die "Error reading fasta file $file2\n";
        }
}

# ouput the blat results if requested
#if ($output_blat_results) {
#	my $blat_file_name = $outputname . "-blat.txt";
#	`cp $blat_output $blat_file_name`;
#}

# finish
close OUTPUT1;
close OUTPUT2;
close OUTPUT3;
close OUTPUT4;



###### subroutine

#load a sequence into a hash from FASTA
sub fastatohash {
	use strict;
	(my $filename) = @_;
	my %genome; #hash with the genome
	my $seq;
	my $title;
	open (INPUT, $filename) or die "cannot open input file $filename in sub genometohash\n";
	while (my $line = <INPUT>) {
		if (($line =~ />(\S+)/) && (length $seq > 1)) {
			if (exists $genome{$title}) {
				print STDERR "error in sub genometohash, two contigs have the name $title, ignoring one copy\n";
#				print $line; exit;
			}
			else {
				$genome{$title} = $seq;
			}
			chomp $line;
			$title = $line;
			$seq = "";
		}
		elsif ($line =~ />(\S+)/) { #will only be true for the first line
			chomp $line;
			$title = $line;
		}
		else {
			$line =~ s/\s//g;
			$seq .= $line;
		}
	} 
	$genome{$title} = $seq;

	return (%genome);
}

