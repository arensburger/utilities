# Sept 2022 conver blast to bed

use strict;
use Getopt::Long;

my $inputfile;

##### read and check the inputs
GetOptions(
	'in:s'   => \$inputfile,
);
unless ($inputfile) {
	die "usage perl blast2bed.pl <-in input BLAST file in tabular format REQUIRED>\n";
}
open (INPUT, $inputfile) or die "Error cannot open input file: $!\n";
while (my $line = <INPUT>) {
	my @data = split " ", $line;

	if ($data[6] <= $data[7] ) {
		print "$data[0]\t$data[6]\t$data[7]\t$data[1]\t0\t+\n";
	}
	else {
		print "$data[0]\t$data[7]\t$data[6]\t$data[1]\t0\t-\n";
	}
}
close INPUT;
