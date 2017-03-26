#!/usr/bin/perl
# Takes a list of dictionary files on the command line (if no files provided prints help)
# and outputs to the command line a single dictionary file with the words merged

use strict;
use File::Temp();

my $firefox_dictionary_file = "/home/peter/.mozilla/firefox/213va4j0.default/persdict.dat";
my $libreoffice_dictionary_file = "/home/peter/Dropbox/Libreoffice_files/wordbook/standard.dic";

### check the command line inputs
#if (@ARGV == 0) { # check if no arguments have been provided
#	print ("Usage: This script takes as arguments a list of files (separted by spaces) with dictionary words.\nIt prints on the command line a single file with the words merged.\n");
#	exit;
#}

my @FILES; # holds the input file names
push @FILES, ($firefox_dictionary_file, $libreoffice_dictionary_file);

my %words; # hash that holds the final list of words to print

## scroll through each of the files
foreach my $filename (@FILES) {
	open (INPUT, $filename) or die "cannot open file $filename\n";
	while (my $line = <INPUT>) {
		chomp $line;
		unless (($line =~ /OOoUserDict1/) or ($line =~ /lang:\s<none>/) or ($line =~ /type:\spositive/) or ($line =~ /---/)) {
			$words{$line} = 1;
		}
	}
}

## print output to temporary file
my $temp_file = File::Temp->new( UNLINK => 1, SUFFIX => '.txt' ); 
open (SEQ, ">$temp_file") or die "cannot open temporary file $temp_file\n";
foreach my $key (keys %words) {
	print SEQ "$key\n";
}

## check the temp_file is not empty and copy temporary file to permanent location
my @wc_command = split " ", `wc -l $temp_file`;
if ($wc_command[0] > 0) {
	`cp $temp_file $firefox_dictionary_file`;
}
else {
	die "ERROR, combined file was empty\n";
}
