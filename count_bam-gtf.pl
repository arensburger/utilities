#!/usr/bin/perl

# August 2013.  This script takes as input a .bam file and a gtf.  Reports the number of overlaps
# makes use of bedtools (must be installed)
# Sept 2016. Updated so a size of a bam file can be added and rpkm is calculated
# January 2018 Make sure bedtools is installed.  Also, the gff file cannot have spaces in the ID, replace spaces with "-"

use strict;
use File::Temp();
use Getopt::Long;

##### read and check the inputs
my $bam_filename; #name of input file
my $gtf_filename; #name of gtf
my $outputname; #name of the output
my $librarysize; # size of the bam file to use 
my $strand; #if set as option then only count reads in the opposite direction to gff description
my $logtransform; # if set then log transform (base 2) the output
my $report_rpkm; # if set output RPKM values
my $report_tpm; #if set output RPKM
my $report_count; # if set reports the raw count per transcript

GetOptions(
	'b:s'   => \$bam_filename,
	'g:s'	=> \$gtf_filename,
	'o:s'	=> \$outputname,
	't:s'	=> \$librarysize,
	's'     => \$strand,
	'l'	=> \$logtransform,
	'c'	=> \$report_count,
	'r'	=> \$report_rpkm,
	'p'	=> \$report_tpm
);
die ("usage: perl count_bam-gtf.pl -b <REQUIRED: input bam file> -g <REQUIRED: GTF formated file > -o <OPTIONAL: output name> [REQUIRED: need to select one or more of the following ouputs -c (raw count per GTF feature) -r (RPKM) -p (TPM) ] -t <OPTIONAL: number of reads that should be in bam file, used for RPKM and TPM calculation> -s <OPTIONAL: only count reads that are in the opposite direction to gff annoation> -l <OPTIONAL: report reads as log transformed + 1\n") unless ($bam_filename and $gtf_filename);

unless ($report_count or $report_rpkm or $report_tpm) {
	die ("Need to select at least one type of output -c, -p, and/or -t");
}
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
	elsif ($line =~ /\stRNA\s+(\d+)\s+(\d+).+ID=(\S+)/) {
                my $b1 = $1;
                my $b2 = $2;
                my $id = $3;
                $transcriptlen{$id} = $b2 - $b1;
                print OUTPUT $line;
        }
	elsif ($line =~ /\smRNA\s+(\d+)\s+(\d+).+ID=(\S+);/) {
                my $b1 = $1;
                my $b2 = $2;
                my $id = $3;
                $transcriptlen{$id} = $b2 - $b1;
                print OUTPUT $line;
        }
	elsif ($line =~ /\sNCBI\s\S+\s+(\d+)\s+(\d+).+ID=(\S+)/) {
                my $b1 = $1;
                my $b2 = $2;
                my $id = $3;
                $transcriptlen{$id} = $b2 - $b1;
                print OUTPUT $line;
        }
	elsif ($line =~ /\smRNA\s+(\d+)\s+(\d+).+ID=(\S+);/) {
		my $b1 = $1;
                my $b2 = $2;
                my $id = $3;
                $transcriptlen{$id} = $b2 - $b1;
                print OUTPUT $line;
        }
	elsif ($line =~ /\sgene\s+(\d+)\s+(\d+).+ID=(\S+);/) {
                my $b1 = $1;
                my $b2 = $2;
                my $id = $3;
                $transcriptlen{$id} = $b2 - $b1;
                print OUTPUT $line;
        }
	elsif ($line =~ /^\#/) {
	}
	else {
		die "cannot read gff line\n$line";
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
#`cp $gtf_short_filename temp.gtf`;
#print "intersectBed -abam $bam_filename -b $gtf_short_filename -bed -wb > $intersect_file\n"; exit;

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
	if ($line =~ /^\S+\s\S+\s\S+\s(\S+)\s.+ID=(\S+);/) { # update as necessary for gff file
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
        if ($line =~ /ID=(\S+);/) { # update as necessary for gff file
		$transcript_count{$1} = 0;
	}
        else {
                die "cannot read no_intersect line\n$line";
        }
	$num_no_intersections++;
}

#output the data
#if ($outputname) {
	
	#Caluclate TPM (per http://www.rna-seqblog.com/rpkm-fpkm-and-tpm-clearly-explained/ )
	my $totalRPK;
	my %RPK;
	my %TPM;
	foreach my $transcript (keys %transcript_count) {
		$RPK{$transcript} = $transcript_count{$transcript}/$transcriptlen{$transcript};		
		$totalRPK +=  $RPK{$transcript};
	}
	my $permillion = $totalRPK/(10 ** 6);
	foreach my $transcript (keys %RPK) {
		$TPM{$transcript} = $RPK{$transcript}/$permillion;
	}


	# Calculate RPKM and output data
	foreach my $transcript (keys %transcript_count) {
		my $rpkm = "NA";
		my $tpm = "NA";
		if ($librarysize) {
			$rpkm = ((10 ** 9) * $transcript_count{$transcript})/($transcriptlen{$transcript} * $librarysize);
			$tpm = $TPM{$transcript};
			if ($logtransform) {
				my $log_rpkm = log2($rpkm + 1); #add 1 to avoid problems with zeros
				$rpkm = $log_rpkm;
				my $log_tpm = log2($tpm + 1);
				$tpm = $log_tpm;
			}
		}

		my $report_data; # merging of data to report
		if ($report_count) {
			$report_data .= "\t$transcript_count{$transcript}";
		}
		if($report_rpkm) {
			$report_data .= "\t$rpkm";
		}
		if ($report_tpm) {
			$report_data .= "\t$tpm";
		}

		if ($outputname) {
			print FINAL_OUTPUT "$transcript", "$report_data\n";
		}
		else {
			print "$transcript", "$report_data\n";
		}
	}
#}

my $num_transcripts = keys (%transcript_count);
my $num_reads = keys (%uniquereads);

print STDERR "A total of $num_intersections intersections were found for $num_transcripts transcripts and $num_reads reads;  $num_no_intersections elements had no intersections\n";
if ($logtransform) {
	print STDERR "\ndata are log base2 + 1 transformed\n";
}
print STDERR "\norder of reporting (if multiple outputs selected) 1) count, 2) rpkm, 3) tpm\n";
if ($strand) {
	print STDERR "\nonly reads in opposite direction to gff/gtf feature are counted\n";
}
close OUTPUT;

sub log2 {
	my $n = shift;
	return log($n)/log(2);
}
