#!/usr/bin/perl

# August 2013.  This script takes as input a .bam file and a gtf.  Reports the number of overlaps
# makes use of bedtools (must be installed)

use strict;
use File::Temp();
use Getopt::Long;

##### read and check the inputs
my $bam_filename; #name of input file
my $gtf_filename; #name of gtf
my $outputname; #name of the output
GetOptions(
	'b:s'   => \$bam_filename,
	'g:s'	=> \$gtf_filename,
	'o:s'	=> \$outputname
);
die ("usage: perl count_bam-gtf.pl -b <REQUIRED: input bam file> -g <REQUIRED: GTF formated file > -o <OPTIONAL: output name>\n") unless ($bam_filename and $gtf_filename);
if ($outputname) {
	open (FINAL_OUTPUT, ">$outputname") or die ("cannot open output file $outputname");
}

# make a temporary file with only those GTF lines that are of interest
my $gtf_short_filename = File::Temp->new( UNLINK => 1, SUFFIX => '.gtf' );
open (INPUT, "$gtf_filename") or die "cannot open gtf file $gtf_filename\n";
open (OUTPUT, ">$gtf_short_filename") or die "cannot create temporary file $gtf_short_filename\n";
while (my $line = <INPUT>) {
	if ($line =~ /three_prime_utr/) {
		print OUTPUT $line;
	}
	elsif ($line =~ /five_prime_utr/) {
		print OUTPUT $line;
	}
	elsif ($line =~ /\sexon\s/) {
		print OUTPUT $line;
	}
}
close INPUT;
close OUTPUT;

# create a file with the intersection
my $intersect_file = File::Temp->new( UNLINK => 1, SUFFIX => '.bed' );
`intersectBed -abam $bam_filename -b $gtf_short_filename -bed -wb > $intersect_file`;

# summarize the intersection data
my %uniquereads; #names of unique reads
my %transcript_count; #transcript name as key and counts of reads intersecting as value
my $num_intersections; #number of intersections
open (INPUT, $intersect_file) or die "ERROR, could not open temporary file $intersect_file";
while (my $line = <INPUT>) {
	if ($line =~ /^\S+\s\S+\s\S+\s(\S+)\s.+transcript_id\s\"(\S+)\"/) {
		my $readname = $1;
		my $transcript = $2;
		$transcript_count{$transcript} += 1;
		$uniquereads{$readname} = 1;
	}
	else {
		die "cannot read intersect line\n$line";
	}
	$num_intersections++;
}

#output the data
if ($outputname) {
	foreach my $transcript (keys %transcript_count) {
		print FINAL_OUTPUT "$transcript\t$transcript_count{$transcript}\n";
	}
}
else {
	foreach my $transcript (keys %transcript_count) {
                print "$transcript\t$transcript_count{$transcript}\n";
        }
}
my $num_transcripts = keys (%transcript_count);
my $num_reads = keys (%uniquereads);

print STDERR "A total of $num_intersections intersections were found for $num_transcripts transcripts and $num_reads reads\n";
close OUTPUT;
