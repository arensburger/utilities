#!/usr/bin/perl

# August 2013.  This script takes as input a .bam file and a gtf.  Reports the number of overlaps
# makes use of bedtools (must be installed)
# Sept 2016. Updated so a size of a bam file can be added and rpkm is calculated

use strict;
use File::Temp();
use Getopt::Long;

##### read and check the inputs
my $bam_filename; #name of input file
my $gtf_filename; #name of gtf
my $outputname; #name of the output
my $librarysize; # size of the bam file to use 
my $strand; #if set as option then only count reads in the opposite direction to gff description

GetOptions(
	'b:s'   => \$bam_filename,
	'g:s'	=> \$gtf_filename,
	'o:s'	=> \$outputname,
	't:s'	=> \$librarysize,
	's'     => \$strand
);
die ("usage: perl count_bam-gtf.pl -b <REQUIRED: input bam file> -g <REQUIRED: GTF formated file > -o <OPTIONAL: output name> -t <OPTIONAL: number of reads that should be in bam file, used for RPKM calculation> -s <OPTIONAL: only count reads that are in the opposite direction to gff annoation>\n") unless ($bam_filename and $gtf_filename);
if ($outputname) {
	open (FINAL_OUTPUT, ">$outputname") or die ("cannot open output file $outputname");
}

# make a temporary file with only those GTF lines that are of interest
my %transcriptlen; # name of the transcript as key and length as value
my $gtf_short_filename = File::Temp->new( UNLINK => 1, SUFFIX => '.gtf' );
open (INPUT, "$gtf_filename") or die "cannot open gtf file $gtf_filename\n";
open (OUTPUT, ">$gtf_short_filename") or die "cannot create temporary file $gtf_short_filename\n";
while (my $line = <INPUT>) {
#	if ($line =~ /three_prime_utr/) {
#		print OUTPUT $line;
#	}
#	elsif ($line =~ /five_prime_utr/) {
#		print OUTPUT $line;
#	}
#	elsif ($line =~ /\sexon\s/) {
#		print OUTPUT $line;
#	}

# update as necessary for gff file
	if ($line =~ /\sCDS\s+(\d+)\s+(\d+).+ID=(\S+)/) {
		my $b1 = $1;
		my $b2 = $2;
		my $id = $3;
		$transcriptlen{$id} = $b2 - $b1;
		print OUTPUT $line;
	}
}
close INPUT;
close OUTPUT;

# create a file with the intersection
my $intersect_file = File::Temp->new( UNLINK => 1, SUFFIX => '.bed' );
my $no_intersect_file = File::Temp->new( UNLINK => 1, SUFFIX => '.txt' );

#print "$bam_filename\n";
#print "$gtf_short_filename\n";
#print "$intersect_file\n";
if ($strand) {
	`intersectBed -abam $bam_filename -b $gtf_short_filename -bed -wb -S > $intersect_file`;
	`intersectBed -a $gtf_short_filename -b $bam_filename -S -v > $no_intersect_file`;
}
else {
	`intersectBed -abam $bam_filename -b $gtf_short_filename -bed -wb > $intersect_file`;
	`intersectBed -a $gtf_short_filename -b $bam_filename -v > $no_intersect_file`;
}

#`cp $intersect_file temp.bed`;
#`cp $no_intersect_file no_temp.bed`;

# summarize the intersection data
my %uniquereads; #names of unique reads
my %transcript_count; #transcript name as key and counts of reads intersecting as value
my $num_intersections; #number of intersections
my $num_no_intersections = 0; #number of gff elements with no intersections

open (INPUT, $intersect_file) or die "ERROR, could not open temporary file $intersect_file";
while (my $line = <INPUT>) {
#	if ($line =~ /^\S+\s\S+\s\S+\s(\S+)\s.+transcript_id\s\"(\S+)\"/) {
	if ($line =~ /^\S+\s\S+\s\S+\s(\S+)\s.+ID=(\S+)/) { # update as necessary for gff file
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
close INPUT;

#add in data from gtf entries with no intersections
open (INPUT, $no_intersect_file) or die "ERROR, could not open temporary file $no_intersect_file";
while (my $line = <INPUT>) {
        if ($line =~ /ID=(\S+)/) { # update as necessary for gff file
		$transcript_count{$1} = 0;
	}
        else {
                die "cannot read no_intersect line\n$line";
        }
	$num_no_intersections++;
}

#output the data
if ($outputname) {
	foreach my $transcript (keys %transcript_count) {
		my $rpkm = "NA";
		if ($librarysize) {
			$rpkm = ((10 ** 9) * $transcript_count{$transcript})/($transcriptlen{$transcript} * $librarysize);
		}
		if ($outputname) {
			print FINAL_OUTPUT "$transcript\t$rpkm\n";
		}
		else {
			print "$transcript\t$transcript_count{$transcript}\t$rpkm\n";
		}
	}
}

my $num_transcripts = keys (%transcript_count);
my $num_reads = keys (%uniquereads);

print STDERR "A total of $num_intersections intersections were found for $num_transcripts transcripts and $num_reads reads;  $num_no_intersections elements had no intersections\n";
close OUTPUT;
