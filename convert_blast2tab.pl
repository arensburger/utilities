#!/usr/bin/perl

use strict;
use Bio::SearchIO;
my $searchin = new Bio::SearchIO( -tempfile => 1,
				  -format => 'blast',
				  -file   => $ARGV[0]);


while( my $result = $searchin->next_result ) {
	my $query_name = $result->query_name;
	while (my $hit = $result->next_hit) {
		my $hit_name = $hit->name;
		my $hsp = $hit->next_hsp;
		my $hit_description = $hit->description;
		my $hit_name = $hit->name;
		my $percentid = $hsp->percent_identity;
		my $length = $hsp->length('total');
		my $mismatches = $length  - $hsp->num_conserved;
		my $gaps = $hsp->gaps;
		my $query_start = $hsp->start('query');
		my $query_end = $hsp->end('query');
		my $subject_start = $hsp->start('hit');
		my $subject_end = $hsp->end('hit');
		my $evalue = $hsp->evalue;
		my $score = $hsp->score;

		print "$query_name\t$hit_name\t$percentid\t$length\t$mismatches\t$gaps\t$query_start\t$query_end\t$subject_start\t$subject_end\t$evalue\t$score\n";
	}

}
