#!/usr/bin/perl
#August 2012.  Takes a SAM formated file as input, returns returns number of reads per transcript, but counting only one read per transcript if it maps to multiple locations on the same read
# see the README file associated with this called ./utilities/README_countsamhits

use strict;
use File::Temp ();
use Getopt::Long;

#read the input file
my $filename; #inputfilename
my $output_option; #type of output
my $output = "&STDOUT"; #file name of output

GetOptions(
    'i:s'     => \$filename,
    'p:s'     => \$output_option,
    'o:s'     => \$output
);
 unless ($filename) {
	print "usage: perl counthits.pl -i <REQUIRED: SAM file, output of bowtie2> -p <OPTIONAL: n=Nadia\'s output c=Crystal\'s output j=Jim\'s output> -o <OPTIONAL: output file name\n";
	exit;
}

#convert from sam to bam if necessary
#check first to see if the file already .bam if not convert
my $bam_filename; #name of the bam file
if (substr($filename, -4, 4) eq ".bam") {
	print STDERR "file appears to already be .bam format\n";
	$bam_filename = $filename;
}
else {
	print STDERR "converting input file...\n";
	$bam_filename = File::Temp->new( UNLINK => 0, SUFFIX => '.bam' );
	`samtools view -bS $filename > $bam_filename`;
}

#get only one member of each proper pair
my $pair_filename = File::Temp->new( UNLINK => 1, SUFFIX => '.bam' );
`samtools view $bam_filename -b -f 0X0042 > $pair_filename`; #holds one member of all the proper pairs (pairs in one transcript)
my $unpair_filename = File::Temp->new( UNLINK => 1, SUFFIX => '.bam' );
#`samtools view $bam_filename -b -F 0x0002 > $unpair_filename`; #holds all the non-proper pairs
`samtools view $bam_filename -b -f 0x0008 > $unpair_filename`; #holds all the reads that don't have mapped pairs

print STDERR "counting...\n";
#count
my %paircounts = docounts("$pair_filename");
my %unpaircounts = docounts("$unpair_filename");

# get a list of all transcript names
my @transnames = keys %paircounts; #holds all the transcripts names, combined from paired and unpaired
foreach my $name (keys %unpaircounts) {
	unless (exists $paircounts{$name}) { #only add if the name is unique to unpaircounts
		push @transnames, $name;
	}
}

#print output
open (OUTPUT, ">$output") or die "cannot write output file $output\n";

foreach my $name (@transnames) {
	#Crystal's count count numbers
	my $pair_count = 2 * ($paircounts{$name}[0] + $paircounts{$name}[1]);
        my $unpair_count = $unpaircounts{$name}[0] + $unpaircounts{$name}[1];

	print OUTPUT "$name";

	if ($output_option eq "c") {
		print OUTPUT "\t$pair_count";
	}
	if ($output_option eq "n") {
		unless (ord($paircounts{$name}[0]) == 0) {
			print OUTPUT "\t$paircounts{$name}[0]";
		}
		else {
			print OUTPUT "\t0";
		}
		unless (ord($paircounts{$name}[1]) == 0) {
                        print OUTPUT "\t$paircounts{$name}[1]";
 	        }
                else {
                        print OUTPUT "\t0";
		}
	}

	if ($output_option eq "c") {
		print OUTPUT "\t$unpair_count";
	}

	if ($output_option eq "n") {
		unless (ord($unpaircounts{$name}[0]) == 0) {
			print OUTPUT "\t$unpaircounts{$name}[0]";
		}
		else {
			print OUTPUT "\t0";
		}
                unless (ord($unpaircounts{$name}[1]) == 0) {
			print OUTPUT "\t$unpaircounts{$name}[1]"
                }
                else {
                        print OUTPUT "\t0";
                }

	}

	if ($output_option eq "j") {
		my $sum = $pair_count + $unpair_count;
		print OUTPUT "\t$sum";
	}

	print OUTPUT "\n";
}
close OUPUT;



#counts the number of hits in the .bam file, but couting only one hit per transcript per read
sub docounts {
	my $filename = shift;
	my %transhits; #holds the transcript name as key and [0] number of non-duplicated hits [1] number of duplicated hits

	#convert bam to sam
	my $samfilename = File::Temp->new( UNLINK => 1, SUFFIX => '.sam' );
	`samtools view $filename > $samfilename`;

	#count the sorted sam file
	open (INPUT, $samfilename) or die "cannot open sorted sam file $samfilename\n";
	my $current_read = "";
	my @readlines; #holds all the lines for the current read
	while (my $line = <INPUT>) {
		#isolate lines of the current read
		if ($line =~ /^(\S+)\s\S+\s(\S+)\s/) {
			my $readname = $1;
			my $transcriptname = $2;

			#do simple count of hits
			unless ($transcriptname eq "*") {
				$transhits{$transcriptname}[2] += 1;
			}

			if ($readname eq $current_read) { #still reading the current read lines
				push @readlines, $line;
			}
			else { #got to a new read, need to process the old lines

				#process the @readlines with all the current lines of read
				my %transcript; #names of transcript as key and number of hits as value
				foreach my $rline (@readlines) {
					if ($rline =~ /^\S+\s\S+\s(\S+)\s/) {
						$transcript{$1} += 1;
					}
#					else {
#						die "error reading sam file\n$rline";
#					}
				}
				foreach my $qline (keys %transcript) {

					unless ($qline eq "*") {
						$transhits{$qline}[0] += 1;
						$transhits{$qline}[1] += $transcript{$qline} - 1;

					}
				}


				#reset things for next read
				@readlines = "";
				push @readlines, $line;
				$current_read = $readname;
			}
		}
		else {
			warn "cannot read line\n$line";
		}
	}

	return(%transhits);
}
