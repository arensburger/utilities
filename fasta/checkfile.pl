# This script checks a fasta file for duplicate headers

use strict;
use Getopt::Long;

my $filename; #name of input file
my $renamedup=0; #rename duplicates
my $frequency=0; #report frequency of nucleotide
my $outputname;

##### read and check the inputs
GetOptions(
	'in:s'   => \$filename,
	'r:s'	=> \$renamedup,
	'f:s'	=> \$frequency,
#	'o:s'	=> \$outputname,
#	'n:s'	=> \$n,
);
unless ($filename) {
	die "usage perl checkfile.pl <-in file name REQUIRED> <-r rename duplicates, default 0 (no) OPTIONAL> <-f report frequency, default 0 (no) OPTIONAL>\n";
}
open (INPUT, $filename) or die "cannot open input file $filename\n";

#go through the the file
my %names; # hash or unique names
my %bases; # bases as key and frequency as value
while (my $line=<INPUT>) {
	if ($line =~ />(\S+)/) { #only looking at names up to first white space
		$names{$1} += 1;
	} 
	elsif ($frequency) {
		chomp $line;
		my @text=split("", $line);
		foreach my $base (@text) {
			$bases{$base}+=1;
		}
	}
}
close INPUT;

# report results
unless ($renamedup) { # don't report result if user want to rename
	foreach my $current_name (keys %names) {
		if ($names{$current_name} > 1) {
			print "The title $current_name is duplicated\n";
		}
	}
}

# rename the duplicates
if ($renamedup) {
	# load the names into a array, keep a hash with all the new unique names
	my @newnames; # all the names as they will appear in the new file
	my %usednames; # all the names that have already been used

	open (INPUT, $filename) or die "cannot open input file $filename\n";
	while (my $line=<INPUT>) {
		if ($line =~ /^(>\S+)/) { #only looking at names up to first white space
			my $cname = $1; #current name
			if (exists $usednames{$cname}) { # go here if duplicate name
				#add an index until find a unique name
				my $i=1; #index
				while (exists $usednames{$cname . "_$i"}) {
					$i++;
				}

				$usednames{$cname . "_$i"} = 1;
				push @newnames, $cname. "_$i";

			}
			else {				 # go here if unique name
				$usednames{$cname} = 1;
				push @newnames, $cname;
			}
		} 
	}
	close INPUT;

	# print results
	my $i=0;

	open (INPUT, $filename) or die "cannot open input file $filename\n";
	while (my $line=<INPUT>) {
		if ($line =~ /^(>\S+)/) {
			print $newnames[$i], "\n";
			$i++;
		}
		else {
			print $line;
		}
	}
	close INPUT;
}

if ($frequency) { #if user want frequency report
	foreach my $category (keys %bases) {
		print "$category\t$bases{$category}\n";
	}
}
