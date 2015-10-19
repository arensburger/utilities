# This script checks a fasta file for duplicate headers

use strict;
use Getopt::Long;

my $filename; #name of input file
my $outputname;

##### read and check the inputs
GetOptions(
	'in:s'   => \$filename,
#	't:s'	=> \$seqtype,
#	'l:s'	=> \$length,
#	'o:s'	=> \$outputname,
#	'n:s'	=> \$n,
);
unless ($filename) {
	die "usage perl checkfile.pl <-i file name>\n";
}
open (INPUT, $filename) or die "cannot open input file $filename\n";

#go through the the file
my %names;
while (my $line=<INPUT>) {
	if ($line =~ />(\S+)/) { #only looking at names up to first white space
		$names{$1} += 1;
	} 
}

# report results
foreach my $current_name (keys %names) {
	if ($names{$current_name} > 1) {
		print "The title $current_name is duplicated\n";
	}
}
exit;
