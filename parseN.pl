#!/usr/bin/perl
### Take a fasta file with N's as input and returns a fasta file with non-N seqgments divided as files

use strict;
use Getopt::Long;

my $file1;
GetOptions(
	'in:s'  => \$file1,
);
die ("usage: perl parseN.pl -in <REQUIRED: input file in fasta format> \n") unless ($file1);
my %genome = genometohash($file1);

foreach my $scaffold (keys %genome) {
	my @p; #array that hold the position of N start and stops
	$p[0] = 0; #setting first position
	while ($genome{$scaffold} =~ /([N]{30,})/g) { #identifies all the N positions
		push @p,  @-[0]; # position of start of Ns
		push @p, @+[0]; # position of end of Ns
	}
	push @p, length $genome{$scaffold}; #last position of this scaffold

	# determine the position that NOT strings N's and report them
	for (my $i=0; $i<scalar @p; $i=$i+2) {
		my $l = $p[$i+1] - $p[$i]; #length of the segment
		my $t = $genome{$scaffold};
		if ($l > 30) { # only go here if length is not too small
				my $s = substr($genome{$scaffold}, $p[$i], $l);
				my $numN = $s =~ tr/N/N/;
				my $ratioN = $numN/(length $s);
				if ($ratioN < 0.25) { # only print if the ratio of N to non-N is not too high
					my $name = $scaffold . "_" . $i;
					print ">$name\n";
					print "$s\n";
				}
		}
	}
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
