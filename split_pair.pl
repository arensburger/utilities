
#!/usr/bin/perl

# May 9, 2012 takes a fastq file with paired reads, checks that names all match and produces two files with the paired reads
# Thu 10 May 2012 11:00:06 AM PDT modified to remove the /1 or /2 from the end of the file
# July 2012, modified from split_pair.pl to account for input sequences that already have /1 and /2
# May 2013, tightened up the script, made it recognize two types of input

use strict;
use File::Basename;

#check input
die ("usage: perl split_pair.pl <FASTQ file>\n") unless ($ARGV[0]);

my (@suffixes) = (".fastq", ".fq"); #possible suffixes that will be removed otherwise suffix will be kept
#set up names
my $basename = basename($ARGV[0], @suffixes);
my $file1name = $basename . "-pair1.fq";
my $file2name = $basename . "-pair2.fq";
my $linecounter = 1;
#read the file
open (INPUT, $ARGV[0]) or die "cannot open input file $ARGV[0]\n";
open (OUTPUT1, ">$file1name") or die "cannot open output file $file1name\n";
open (OUTPUT2, ">$file2name") or die "cannot open output file $file2name\n";
while (my $line = <INPUT>) {
	my $name; #name of the current pair of sequences
	my $seq1; 
	my $seq2;
	chomp $line; #use this to remove empty lines
	if (($line =~ /^@(\S+)\/1/) or ($line =~ /^@(\S+)\s1:/)) {
		$seq1 = "$line\n" . <INPUT> . <INPUT> . <INPUT>;
	}
	elsif (($line =~ /^@(\S+)\/2/) or  ($line =~ /^@(\S+)\s2:/)) {
		$seq2 = "$line\n" . <INPUT> . <INPUT> . <INPUT>;
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
close OUTPUT1;
close OUTPUT2;
close INPUT;
