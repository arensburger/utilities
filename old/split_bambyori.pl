#!/usr/bin/perl

# May 2016 Takes a bam file as input and returns two bam files with strands separated

use strict;
use Getopt::Long;
use File::Temp ();

### read and check the paramters
my $filename; #input file
my $prefix = "file";
GetOptions(
    'in:s'     => \$filename,
    'p:s'      => \$prefix
);
 unless ($filename) {
	print "usage: perl split_bambyori.pl -in <REQUIRED: BAM file>, -p <OPTIONAL: prefix for output>\n";
	exit;
}

### convert bam to sam
my $sam_filename = File::Temp->new( UNLINK => 0, SUFFIX => '.sam' );
print STDERR "converting BAM to SAM\n";
`samtools view -h $filename > $sam_filename`;

### create files

# input sam
open (INPUT, "$sam_filename") or die "cannot open temporary sam file\n";

# temporary output ori 1
my $sam_filename2 = File::Temp->new( UNLINK => 0, SUFFIX => '.sam' );
open (OUTPUT1, ">$sam_filename2") or die "cannot create output temporary file 1";

# temporary output ori 2
my $sam_filename3 = File::Temp->new( UNLINK => 0, SUFFIX => '.sam' );
open (OUTPUT2, ">$sam_filename3") or die "cannot create output temporary file 2";

# final ori 1 output
my $bam1_filename = $prefix . "-plus-strand.bam";
#open (OUTPUT3, ">$bam1_filename") or die "cannot create output file $bam1_filename";

# final ori 2 output
my $bam2_filename = $prefix . "-minus-strand.bam";
#open (OUTPUT4, ">$bam2_filename") or die "cannot create output file $bam2_filename";


### scroll through the input file and distribute the lines
print STDERR "spliting the file\n";
while (my $line = <INPUT>) {
	my @data = split(" ", $line);
	if ($data[1] == 0) {
		print OUTPUT1 "$line";
	}
	elsif ($data[1] == 16) {
		print OUTPUT2 "$line";
	}
	
	if ($data[0] =~/^@/) {
		print OUTPUT1 "$line";
		print OUTPUT2 "$line";
	}
}
close OUTPUT1;
close OUTPUT2;

### convert back to sam files
#`cp $sam_filename3 haha`; exit;
`samtools view -bS $sam_filename2 > $bam1_filename`;
`samtools view -bS $sam_filename3 > $bam2_filename`




