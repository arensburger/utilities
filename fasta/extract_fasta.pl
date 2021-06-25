#!/usr/bin/perl
# June 2021 Take a fasta file as key and file with headers to extract
# returns fasta file sequences with the right header

use strict;
use Getopt::Long;

### load data and verify inputs
my $fastafilename; # input fasta file
my $headerfilename;
GetOptions(
	'f:s' => \$fastafilename,
	'h:s' => \$headerfilename
);
unless ($fastafilename and $headerfilename) {
	die ("usage: perl extract_fasta.pl -f <REQUIRED: fasta formated file>, -h <REQUIRED: headers of sequences to extract>");
}

### load genome
my %f = fasta2hash($fastafilename);

### go through header and print the right ones
open (INPUT, $headerfilename) or die "cannot open file $headerfilename\n";
while (my $line = <INPUT>) {
	chomp $line;
	if (exists $f{$line}) {
		print ">$line\n";
		print "$f{$line}\n";
	}
}


sub fasta2hash {
	use strict;
	(my $filename) = @_;
	my %genome; #hash with the genome
	my $seq="";
	my $title;
	open (INPUT, $filename) or die "cannot open input file $filename in sub genometohash\n";
	while (my $line = <INPUT>) {
		if (($line =~ />(\S+)/) && (length $seq > 1)) {
			if (exists $genome{$title}) {
				warn "warning in sub genometohash, two contigs have the name $title, ignoring one copy\n";
			}
			else {
				$genome{$title} = $seq;
			}
			#chomp $line;
			my @data = split(" ", $line);
			$title = $data[0];
			$title = substr $title, 1;
			$seq = "";
		}
		elsif ($line =~ />(\S+)/) { #will only be true for the first line
			#chomp $line;
			my @data = split(" ", $line);
			$title = $data[0];
			$title = substr $title, 1;
      $seq = "";
		}
		else {
			$line =~ s/\s//g;
			$seq .= $line;
		}
	}
	$genome{$title} = $seq;

	return (%genome);
}
