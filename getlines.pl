#!/usr/bin/perl
# September 2021 output specific lines from a text files, written for Yves

use strict;
use Getopt::Long;

my $UPDATE=1000000;

my $input_file; # input
my $start_line; # first line to export
my $end_line; # last line to export
my $output_file; # output
GetOptions(
	'in:s' => \$input_file,
	's:s'	=> \$start_line,
	'e:s'	=> \$end_line,
	'o:s'	=> \$output_file,
);
unless (($input_file) and ($start_line) and ($end_line) and ($output_file)) {
	die ("usage: perl getlines -in <REQUIRED: input file name> -s <REQUIRED: start of lines to report> -e <REQUIRED: end of lines to report> -o <REQUIRED: output file name>\n");
}

open (INPUT, $input_file) or die "Cannot open input file $input_file\n";
open (OUTPUT, ">$output_file") or die "Cannot open output file $output_file\n";
my $i=0;
while (my $line = <INPUT>) {
	if (($i >= $start_line) and ($i <= $end_line)) {
		print OUTPUT $line;
	}
	if (($i % $UPDATE) == 0) {
		print "$i...\n";
	}
	$i++;
	if ($i >= $end_line) {
                close OUTPUT;
                exit;
        }

}
close OUTPUT;
