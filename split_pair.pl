#!/usr/bin/perl

# May 9, 2012 takes a fastq file with paired reads, checks that names all match and produces two files with the paired reads
# Thu 10 May 2012 11:00:06 AM PDT modified to remove the /1 or /2 from the end of the file
# July 2012, modified from split_pair.pl to account for input sequences that already have /1 and /2
# May 2013, tightened up the script, made it recognize two types of input

use strict;
use File::Basename;
use Getopt::Long;

##### read and check the inputs
my $filename; #name of input file
my $seqtype = "fq"; #file type, default is fastq
my $outputname; #base name of the output
GetOptions(
	'i:s'   => \$filename,
	't:s'	=> \$seqtype,
	'o:s'	=> \$outputname
);
#check inputs
die ("usage: perl split_pair.pl -i <REQUIRED: input file file> -t <OPTIONAL: sequence type fq or fa (default fq)> -o <OPTIONAL: output name it will be followed by -pair1 or -pair2\n") unless ($filename);
unless (($seqtype eq "fq") or ($seqtype eq "fa")) {
	die "Sequence type (-t) can only be fq or fa\n";
}

#set up names
my (@suffixes) = (".fastq", ".fq", ".fasta", ".fa", ".fas"); #possible suffixes that will be removed otherwise suffix will be kept
unless ($outputname) {
	$outputname = basename($filename, @suffixes);
}
my $file1name = $outputname . "-pair1";
my $file2name = $outputname . "-pair2";

#initalize line counter
my $linecounter = 1;

#read the file
open (INPUT, $filename) or die "cannot open input file $filename\n";
open (OUTPUT1, ">$file1name") or die "cannot open output file $file1name\n";
open (OUTPUT2, ">$file2name") or die "cannot open output file $file2name\n";
while (my $line = <INPUT>) {
	my $name; #name of the current pair of sequences
	my $seq1; 
	my $seq2;
	chomp $line; #use this to remove empty lines

	#run this part if it's a fastq formated file
	if ($seqtype eq "fq") {
		if (($line =~ /^@(\S+)\/1/) or ($line =~ /^@(\S+)\s1:/)) {
			$seq1 = "$line\n" . <INPUT> . <INPUT> . <INPUT>;
		}
		elsif (($line =~ /^@(\S+)\/2/) or  ($line =~ /^@(\S+)\s2:/)) {
			$seq2 = "$line\n" . <INPUT> . <INPUT> . <INPUT>;
		}
		elsif ($line =~ /^@(\S+)/) {
			$seq1 = "$line\n" . <INPUT> . <INPUT> . <INPUT>;
			$linecounter += 4;
			$seq2 = <INPUT> . <INPUT> . <INPUT> . <INPUT>;
		}
		else {
			if (length $line == 0) {
				warn "empty line found in the file at line $linecounter\n";
			}
			else {
				die "unexpected line, make sure the format of the header is known to the script\n$line";
			}
		}

		print OUTPUT1 "$seq1";
		print OUTPUT2 "$seq2";
	
		$linecounter += 4;
	}
	elsif ($seqtype eq "fa") {
		if (($line =~ /^>(\S+)\/1/) or ($line =~ /^>(\S+)\s1:/)) {
                        $seq1 = "$line\n" . <INPUT>;
                }
		elsif (($line =~ /^>(\S+)\/2/) or  ($line =~ /^>(\S+)\s2:/)) {
                        $seq2 = "$line\n" . <INPUT>;
                }
		 elsif ($line =~ /^>(\S+)/) {
                        $seq1 = "$line\n" . <INPUT>;
                        $linecounter += 4;
                        $seq2 = <INPUT> . <INPUT>;
                }

		else {
			 if (length $line == 0) {
                                warn "empty line found in the file at line $linecounter\n";
                        }
                        else {
                                die "unexpected line, make sure the format of the header is known to the script\n$line";
                        }
		}
		print OUTPUT1 "$seq1";
		print OUTPUT2 "$seq2";

		$linecounter += 2;
	}
}
close OUTPUT1;
close OUTPUT2;
close INPUT;
