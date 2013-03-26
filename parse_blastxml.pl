#! /usr/bin/perl
# Mon 07 May 2012 02:04:14 PM PDT parses output of blast xml

use strict;
use Bio::SearchIO;
my $searchin = new Bio::SearchIO( -tempfile => 1,
				  -format => 'blastxml',
				  -file   => $ARGV[0]);
while( my $result = $searchin->next_result ) {
#	my $query_name = $result->query_description;
	my $query_name = $result->query_name;
	while (my $hit = $result->next_hit) {
		my $hit_name = $hit->name;
		my $hsp = $hit->next_hsp;
		my $evalue = $hsp->evalue;
		my $description = $hit->description;

		print "$query_name\t$hit_name\t$evalue\t$description\n";
	}

}
