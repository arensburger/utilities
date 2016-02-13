#!/usr/bin/perl
# Feb 2016 take a fasta file as input and returns the file reformated as desired

use strict;
use Getopt::Long;

my $filename; #name of input file
my $length; #maximum line length for sequences
my $outputname;

##### read and check the inputs
GetOptions(
	'in:s'   => \$filename,
	'l:s'	=> \$length,
);
unless ($filename) {
	die "usage perl format_fasta.pl <-in file name REQUIRED> <-l maximum sequence file length OPTIONAL>";
}

##### work part

#load the input file into a hash
my %f = genometohash("$filename");
foreach my $input (keys %f) {
	print ">$input\n";
	my @sequence = split '', $f{$input};
	my $size = scalar(@sequence);
	print "$sequence[0]"; 
	for (my $i=1; $i<$size; $i++) {
		if ($length) {
			if (($i % $length) == 0) {	# only do this if length has been defined and reached point
							# and return is warranted
				print "\n";
			}
		}
		print "$sequence[$i]";
	}
	print "\n";
}



##### subroutine(s)

#load a genome into a hash
sub genometohash {
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
