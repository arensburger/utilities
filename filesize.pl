#!/usr/bin/perl

use strict;

use Getopt::Long;

my $inputfile; 
my $fileformat; # identifies the file format
my $outputname; # output file
my $number_of_lines; 
my $filesize;

GetOptions(
	'in:s'	=> \$inputfile,
	'f:s'   => \$fileformat,
#	'o:s'	=> \$outputname
);
die ("usage: perl filesize.pl -in <REQUIRED: input file> -f <OPTIONAL: input file format: text (default), fasta, fastq>\n") unless ($inputfile);
if ($fileformat) {
	die ("do not recognize file format $fileformat\n") unless (($fileformat eq "text") or ($fileformat eq "fasta") or ($fileformat eq "fastq"));
}

#open (INPUT, $inputfile) or die "cannot open input file $inputfile\n";
#while (my $line = <INPUT>) {
#	if ($line =~ /\S+/) { #line must have at least one non white character
#		$number_of_lines++;
#	}
#}

my $command_output = `wc -l $inputfile`;
my @data = split " ", $command_output;
$number_of_lines = $data[0];

if ($fileformat eq "text") {
	$filesize = $number_of_lines;
}
elsif ($fileformat eq "fasta") {
	$filesize = ($number_of_lines/2);
}
elsif ($fileformat eq "fastq") {
	$filesize = ($number_of_lines/4);
}
else {
	$filesize = $number_of_lines;
}
close (INPUT);

print "$filesize\t$inputfile\n";
