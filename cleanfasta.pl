#!/usr/bin/perl
# Feb 2020, Takes a fasta file and reformats it according to the rules set. Improvement on cleanfile.pl

use strict;
use Getopt::Long;

my $filename; #name of input file
my $length=0; #maximum length of output lines, 0 indicates that the length should not be changed
my $n=0; #boolean, 0 keep N's, 1 remove N's
my $fix_header=0; #boolean, fix sequence header if set to 1
my %headers; #holds the text of all the headers, uses to warn if there are duplicates

##### read and check the inputs
GetOptions(
	'in:s'   => \$filename,
	'l:s'	=> \$length,
	'n:s'	=> \$n,
	'h:s' => \$fix_header,
);
unless ($filename) {
	die "usage perl cleanfasta.pl <-in file name> <-l OPTIONAL maximum line length in characters, default no maximum> <-n OPTIONAL remove N characters, default no> <-h OPTIONAL fix headers, provide any non-zero value>\n";
}

#### load the sequences one at a time and process them
open (INPUT, $filename) or die "cannot open input file $filename\n";
my $header_line = <INPUT>;
unless ($header_line =~ /^>/) {
	die "first line does not start with a >, aborting.\n";
}
my $sequence; # holds the character sequence
while (my $line = <INPUT>) {
	if ($line =~ /^>/) {
		my $new_header_line = $line;
		output_header("$header_line");
		output_sequence($sequence);
#		print "$sequence\n";
		$header_line = $new_header_line;
		$sequence = "";
	}
	else {
		$line =~ s/\s//g;
		$line =~ s/\0//g;
		if ($n) {
			$line =~ s/N//ig; #remove N's
		}
		$sequence .= $line;
	}
}
output_header("$header_line");
output_sequence($sequence);


##### subroutines
sub output_header {
	my($head) = @_;
	if ($fix_header) {
		my @data = split " ", $head;
		print "$data[0]\n";
		check_header($data[0]); # checks if it's a duplicate
	}
	else {
		print "$head";
		check_header($head); # checks if it's a duplicate
	}
}

sub output_sequence {
	my($seq) = @_;
	if ($length) { #if a maximum line length has been specified limit the output per line
		my @line_array = ( $seq =~ m/.{1,$length}/g);
		for (my $i=0; $i < scalar @line_array; $i++) {
			print "$line_array[$i]\n";
		}
	}
	else {
		print "$seq\n";
	}
}

sub check_header {
	my($h) = @_;
	if (exists $headers{$h}) {
		warn "header $h is duplicated\n";
	}
	$headers{$h} = 0;
}
