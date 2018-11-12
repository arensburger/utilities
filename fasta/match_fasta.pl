#!/usr/bin/perl
# November 2018 Takes two fasta file and returns files with matching headers
# designed for nucleotide and associate protein in mind
# first sequence ($i1) is the reference for what should be output

use strict;
use Getopt::Long;

### load data
my $i1; # input fasta file1
my $i2;
my $o1; # output fasta file1
my $o2;
GetOptions(
	'i1:s' => \$i1,
	'i2:s' => \$i2,
	'o1:s' => \$o1,
	'o2:s' => \$o2,
);
die ("usage: perl match_fasta.pl -i1 <REQUIRED: fasta formated file>, -i2 <REQUIRED: fasta formated file>, -o1 <REQUIRED: fasta formated file>, -o2 <REQUIRED: fasta formated file>\n") unless (($i1) and ($i2) and ($o1) and ($o2));
my %fasta1 = fasta2hash($i1);
my %fasta2 = fasta2hash($i2);
open (OUTPUT1, ">$o1") or die "Cannot open file $o1\n";
open (OUTPUT2, ">$o2") or die "Cannot open file $o2\n";

### process inputs

## selected section of headers in file 1
my %fasta1_short_header; # same as %fasta1 but with shorted header
my %short2long; # holds the short header as key and long header as value
foreach my $key (keys %fasta1) {
	if ($key =~ /__(XR_\S+?)-/) {
		$fasta1_short_header{$1} = $fasta1{$key};
		$short2long{$1} = $key;
	}
	elsif ($key =~ /__(XM_\S+?)-/) {
		$fasta1_short_header{$1} = $fasta1{$key};
		$short2long{$1} = $key;
	}
	elsif ($key =~ /__(\S+?)_/) {
		$fasta1_short_header{$1} = $fasta1{$key};
		$short2long{$1} = $key;
	}
	elsif ($key =~ /__(\S+)/) {
		$fasta1_short_header{$1} = $fasta1{$key};
		$short2long{$1} = $key;
	}
	else {
		die "$key";
		$short2long{$key} = $key;
	}
}

## find selected sections in the headers of file2
foreach my $h1_header (keys %fasta1_short_header) {
	my @hits = grep (/$h1_header/, keys %fasta2);
	if (scalar @hits > 1) {
		warn "found multiple matches to header $h1_header, using only one of them\n";
	}
	if (scalar @hits > 0) {

		#process the header1 title to format it right
		my $new_header1; # header1 formated for printing
		if($short2long{$h1_header} =~ /^(\S+?__TF\d+)/) {
			$new_header1 = $1;
		}
		elsif ($short2long{$h1_header} =~ /^(\S+?__\S+)_FLYBASE/){
			$new_header1 = $1;
		}
		elsif ($short2long{$h1_header} =~ /^(\S+?__\S+)_/){
			$new_header1 = $1;
		}
		elsif ($short2long{$h1_header} =~ /^(\S+?__\S+)-/){
			$new_header1 = $1;
		}
		elsif ($short2long{$h1_header} =~ /^(\S+?__\S+)/){
			$new_header1 = $1;
		}
		else {
			die "$short2long{$h1_header}\n";
		}

		#process header2
		my $new_header2;
		if ($hits[0] =~ /^(\S+?)\|/) {
			$new_header2 = $1;
		}
		else {
			$new_header2 = $hits[0];
		}


		print OUTPUT1 ">$new_header1\n";
		print OUTPUT1 "$fasta1_short_header{$h1_header}\n";
		print OUTPUT2 ">$new_header2\n";
		print OUTPUT2 "$fasta2{$hits[0]}\n";
	}
	else {
		print "cannot find match to $h1_header\n"
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
