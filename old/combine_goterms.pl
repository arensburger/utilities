#!/usr/bin/perl

# March 2019 Take go terms exported by biomart and collapses multiple lines with the same
# reference to a single line

use strict;
use Getopt::Long;

my %entries; # hash with reference in key and go terms in values
my $filename; # separated by commas
GetOptions(
	'in:s'  => \$filename,
);
die ("usage: perl combine-goterms.pl -in <REQUIRED: input files .csv>\n") unless ($filename);

# read the data and put results into %reads
open (INPUT, $filename) or die "cannot open file $filename\n";
while (my $line = <INPUT>) { #loop through each line of the file
	chomp $line;
	my @data = split (",", $line);
	my $first_element = shift @data;
	$first_element =~ s/^\s+|\s+$//g; # remove all white spaces
	my $second_element = $data[0];
	$second_element =~ s/^\s+|\s+$//g; # remove all white spaces

	# add element to hash, checking it does not yet exist
	if(exists $entries{$first_element}) {
		unless ($entries{$first_element} =~ /\Q$second_element/) {
			$entries{$first_element} .= " - $second_element";
		}
	}
	else {
		$entries{$first_element} = $second_element;
	}
}
close INPUT;

#print results
foreach my $key (keys %entries) {
	print "$key*$entries{$key}\n"
}
