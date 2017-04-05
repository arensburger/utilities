#!/usr/bin/perl
# Takes a list of dictionary files on the command line (if no files provided prints help)
# and outputs to the command line a single dictionary file with the words merged

use strict;
use File::Temp();

my $firefox_dictionary_file = "/home/peter/.mozilla/firefox/l6mcb3z8.default/persdict.dat";
my $libreoffice_dictionary_file = "/home/peter/Dropbox/Libreoffice files/wordbook/standard.dic";
my $backup_libreoffice_dictionary_file = "/home/peter/Dropbox/Libreoffice files/wordbook/standard.dic.old";

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
close (SEQ);

## check the temp_file is not empty and copy temporary file to permanent location
my @wc_command = split " ", `wc -l $temp_file`;
if ($wc_command[0] > 0) {

	# update firefox
	my $copy_name = fix_spaces($firefox_dictionary_file);
	`cp $temp_file $copy_name`; 

	#update libreoffice
	my $copy_name1 = fix_spaces($libreoffice_dictionary_file);
	my $copy_name2 = fix_spaces($backup_libreoffice_dictionary_file);
	`cp $copy_name1 $copy_name2`;
	open (LODIC, ">$libreoffice_dictionary_file") or die "cannot open file $libreoffice_dictionary_file\n";
	print LODIC "OOoUserDict1\n";
	print LODIC "lang: <none>\n";
	print LODIC "type: positive\n";
	print LODIC "---\n";
	foreach my $key (keys %words) {
		print LODIC "$key\n";
	}
	close LODIC;
}
else {
	die "ERROR, combined file was empty\n";
}

# replaces spaces with \<space>
sub fix_spaces {
	my ($text) = @_;
	my $return_text;
	for (my $i=0; $i<length($text); $i++) {
		if (substr($text, $i, 1) eq " ") {
			$return_text .= '\ ';
		}
		else {
			$return_text .= substr($text, $i, 1);
		}
	}
	return($return_text);
}
