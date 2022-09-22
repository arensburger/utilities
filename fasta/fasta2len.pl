# Sept 2022 converts fasta to file with lengths, useful for bedtools genomecove

use strict;
use Getopt::Long;

my $inputfile;

##### read and check the inputs
GetOptions(
	'in:s'   => \$inputfile,
);
unless ($inputfile) {
	die "usage perl fasta2len.pl <-in input BLAST file in tabular format REQUIRED>\n";
}
my (%fasta) = genometohash($inputfile);
foreach my $name (keys %fasta) {
	my $len = length $fasta{$name};
	print "$name\t$len\n";
}

#load a genome into a hash
sub genometohash {
	use strict;
	(my $filename) = @_;
	my %genome; #hash with the genome
	my $seq="";
	my $title;
	open (INPUT, $filename) or die "cannot open input file $filename in sub genometohash\n";
	while (my $line = <INPUT>) {
		if (($line =~ />(\S+)/) && (length $seq > 1)) {
			if (exists $genome{$title}) {
				print STDERR "error in sub genometohash, two contigs have the name $title, ignoring one copy\n";
#				exit;
			}
			else {
				$genome{$title} = $seq;
			}
			#chomp $line;
			my @data = split(" ", $line);
			$title = $data[0];
			$title = substr $title, 1;
			$seq = "";
		}
		elsif ($line =~ />(\S+)/) { #will only be true for the first line
			#chomp $line;
			my @data = split(" ", $line);
			$title = $data[0];
		$title = substr $title, 1;
                        $seq = "";
		}
		else {
			$line =~ s/\s//g;
			$seq .= $line;
		}
	}
	$genome{$title} = $seq;

	return (%genome);
}
