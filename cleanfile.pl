# this script takes a file as input and and output the same file without white spaces
# jan 08.  updated to ignore Fasta title lines
# March 2013 updated to do more cleaning

use strict;
use Getopt::Long;

my $filename; #name of input file
my $seqtype; #type of sequence
my $outputname;

##### read and check the inputs
GetOptions(
	'i:s'   => \$filename,
	't:s'	=> \$seqtype,
	'o:s'	=> \$outputname,
);
unless ($filename and $outputname) {
	die "usage perl cleanfile.pl <-i file name> <-o output file, use - for standard out>  <-t OPTIONAL input type, available is fasta, default none>\n";
}
open (INPUT, $filename) or die "cannot open input file $filename\n";
if ($outputname) {
	open (OUTPUT,">$outputname") or die "cannot open output file $outputname\n";
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
	elsif ($line =~ /^--\s$/) { # do not print grep separator
	}
	else {
		$line =~ s/\s//g; #remove white spaces from the current line
		print OUTPUT $line;
	}
	$firstline = 0;
}
exit;
