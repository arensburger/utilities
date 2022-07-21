# July 2022. Splits a fasta file into a given number of segments

use strict;
use Getopt::Long;
use Cwd;

my $filename; #name of input file
my $number_of_segments;

##### read and check the inputs
GetOptions(
	'in:s'   => \$filename,
	's:s'		=> \$number_of_segments
);
unless ($filename and $number_of_segments) {
	die "usage perl split_fast.pl <-in file name REQUIRED> <-s number of segments REQUIRED>\n";
}

my %genome = genometohash($filename);
### calculate the number of base pairs per segment
my %genome_size; # squence name as key and size as value
my $total_size;
foreach my $name (keys %genome) {
	$genome_size{$name} = length $genome{$name};
	$total_size += length $genome{$name};
}
my $segment_size = int($total_size/($number_of_segments-1));

### create segments
## create the first segment file name
my @data = split /\./, $filename;
my $dir = getcwd;
my $i=1;
my $segment_filename = $dir . "/" . $data[0] . "-s" . $i . ".fa";
open (OUTPUT, ">$segment_filename") or die "cannot create file $segment_filename\n";
my $current_size = 0; # current_size of the segment in bp
foreach my $name (keys %genome) {
	if ((length $genome{$name})+$current_size <= $segment_size) { # add more lines to current segement
		print OUTPUT ">$name\n";
		print OUTPUT"$genome{$name}\n";
	}
	else { # curent segment is full, close it and start a new one
		close OUTPUT;
		$current_size = 0;
		$i++;
		$segment_filename = $dir . "/" . $data[0] . "-s" . $i . ".fa";
		open (OUTPUT, ">$segment_filename") or die "cannot create file $segment_filename\n";
		print OUTPUT ">$name\n";
		print OUTPUT "$genome{$name}\n";
	}
	$current_size += length $genome{$name};
}
close OUTPUT;

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
