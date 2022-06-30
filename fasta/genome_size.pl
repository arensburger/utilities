#! /usr/bin/perl
# March 2021 takes a genome file in fasta format and returns a table of
# how big each contig is
# June 2022 added one more line at the end with the total size
use strict;
use Getopt::Long;

my $genomefile; # genome fasta file
my $totalsize; # total size of the genome

### set and test inputs
GetOptions(
	'in:s'     => \$genomefile
 );
unless (defined $genomefile) {
		die "usage: perl genome_size -in <REQUIRED: FASTA formated genome file input>\n";
}
open (INPUT, $genomefile) or die "cannot open file $genomefile";

### load the genome and return the results
my %genome = genometohash($genomefile);
foreach my $contig (keys %genome) {
	my $size = length($genome{$contig});
	print "$contig\t$size\n";
	$totalsize += $size;
}

### print total size
print "\nTotal genome size: $totalsize\n";

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
