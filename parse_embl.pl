#!/usr/bin/perl
# October 2018 Takes a .embl formated file and returns specied sections
# I tried using the bioperl Bio::SeqIO but it keeps getting thrown off

use strict;
use Getopt::Long;
use Bio::SeqIO::embl;
#use Bio::Tools::GFF;
#use Bio::DB::Fasta;

my $filename; # name of the embl input file
GetOptions(
	'f:s' => \$filename
);
die ("usage: perl parse_embl.pl -f <REQUIRED: embl fromated file> \n") unless ($filename);

open (INPUT, $filename) or die "cannot open file $filename\n";
my $xref;
my $id;
my $sequence;
while (my $line = <INPUT>) {
#	### set everything to zero when starting a new sequence
#	if ($line =~ /^\/\//) {
#		$xref = "";
#		$id = "";
#		$sequence = "";
#	}

	### read the various fields
	if ($line =~ /\/db_xref="(.+)"/) { # record current xref lines
		$xref .= $1;
	}
	if ($line =~ /\/protein_id="(.+)"/) { # record current protein_id
		$id .= $1;
	}
	if ($line =~ /\/translation="(\S+)"/) { # case where protein is on one line
		$sequence = $1;
	}
	elsif ($line =~ /\/translation="(\S+)/) { # case where protein is on two or more lines
		$sequence = $1;
		my $keepreading=1; # boolean 1 while reading sequences
		while ($keepreading) {
			$line = <INPUT>;
			if ($line =~ /FT\s+(\S*)"/) {
				$sequence .= $1;
				$keepreading=0;
			}
			elsif ($line =~ /FT\s+(\S+)/) {
					$sequence .= $1;
			}
			else {
				die "did not expect line\n$line"
			}
		}
#		print "$xref\n$sequence\n";
#		$sequence="";
#		$xref="";
	}

	### when collected enough data report
	if ($sequence) {
		$xref =~ s/ /_/g; # remove spaces
		my $title; # fasta $title
		if ($xref) {
			$title = ">" . $id . "_" . "$xref";
		}
		else {
			$title = ">" . $id;
		}
		print "$title\n";
		print "$sequence\n";
		$sequence="";
		$xref="";
		$id="";
	}
}
