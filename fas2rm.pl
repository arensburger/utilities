#!/usr/bin/perl
##### Takes a fasta file as input and returns a repeatmasker formated file to STOUT

use strict;
use Getopt::Long;

my $inputfile; 
my $class="none"; # name of TE class to add to RM name

##### read and check the inputs
GetOptions(
	'in:s'   => \$inputfile,
	'c:s'	=> \$class
);

unless ($inputfile) {
	die "purpose: convert fasta to repeatmasker\n\t-in <REQUIRED fasta formate file>\n\t-l <OPTIONAL TE family name added to output>\n";
}

 #>M_CR1-Ele_1#LINE/CR1

##### main program
my %sequence = genometohash($inputfile);
foreach my $title (keys %sequence) {
	
	### set the family
	my $family; 
	if($title =~ /^\S+_(\S+)-/) {
		$family = $1;
	}
	else {
		$family = "none";
	} 

	### print output
	if(($class) or ($family)) {
		print ">$title#$class/$family\n"
	}
	else {
		print ">$title\n";
	}
	print "$sequence{$title}\n";
}

#### Subroutine #####

### load a genome into a hash
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
