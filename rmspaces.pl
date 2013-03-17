# this script takes a file as input and and output the same file without white spaces
#jan 08.  updated to ignore Fasta title lines

use strict;

my $input=$ARGV[0];
my $line;
my $seq;

open (INPUT, $input) or die "cannot open input file\n";


while ($line=<INPUT>) {
	unless ($line =~ />/) { #add sequences to $seq
		$line =~ s/\s//g;
		$seq = $seq . $line;
	}
	else {
		unless (length $seq == 0) { #go here if line has ">" sequence is present
			print "$seq\n";
			$seq = "";
		}
		print "$line";
	}
}
print "$seq\n";
exit;