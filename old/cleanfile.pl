# this script takes a file as input and and output the same file without white spaces
# jan 08.  updated to ignore Fasta title lines
# March 2013 updated to do more cleaning

use strict;
use Getopt::Long;

my $filename; #name of input file
my $seqtype; #type of sequence
my $outputname;
my $length=0; #maximum length of output lines, 0 indicates that the length should not be changed
my $n=0; #boolean, 0 keep N's, 1 remove N's

##### read and check the inputs
GetOptions(
	'in:s'   => \$filename,
	't:s'	=> \$seqtype,
	'l:s'	=> \$length,
	'o:s'	=> \$outputname,
	'n:s'	=> \$n,
);
unless ($filename and $outputname) {
	die "usage perl cleanfile.pl <-in file name> <-o output file, use - for standard out>  <-t OPTIONAL input type, available is \"fasta\", \"keepreturn\", default none> <-l OPTIONAL maximum line length in characters, default no maximum> <-n OPTIONAL\n remove N characters, default no";
}
open (INPUT, $filename) or die "cannot open input file $filename\n";
if ($outputname) {
	open (OUTPUT,">$outputname") or die "cannot open output file $outputname\n";
}
if ($seqtype) {
	unless (($seqtype eq "fasta") or ($seqtype eq "keepreturn")) {
		die "sequence type $seqtype is unknown";
	}
}

#go through the the file
my $firstline=1; # boolean, set to 0 after first line
while (my $line=<INPUT>) {
	if (($line =~ /^>/) and ($seqtype eq "fasta")) {
		if ($firstline) {
			print OUTPUT "$line";
		}
		else {
			print OUTPUT "\n$line";
		}
	}
#	elsif ($line =~ /^--\s$/) { # do not print grep separator
#	}
	else {
		$line =~ s/\s//g; #remove white spaces from the current line
		$line =~ s/\0//g; #remove null characters
		if ($n) {
			$line =~ s/N//ig; #remove N's
		}
		if ($length) { #if a maximum line length has been specified limit the output per line
			my @line_array = ( $line =~ m/.{1,$length}/g);
			for (my $i=0; $i < scalar @line_array; $i++) {
				print OUTPUT "$line_array[$i]\n";
			}
		}
		else { #no maximum output line
			print OUTPUT $line;
		}
		if (($seqtype eq "keepreturn") and ((length $line) > 0)) {
			print OUTPUT "\n";
		}
	}
	$firstline = 0;
}
exit;
