#! /usr/bin/perl
# Wed 16 Nov 2011 09:02:23 AM PST Takes either .gff3 or .gtf file as input and coverts it to an sqlite database for use with gbrowse

use strict;
require File::Temp;
use File::Temp ();
use Getopt::Long;

my $INPUTGFF3; #filename of input gff3
my $INPUTGTF; #filename of input gtf
my $SQLITEDATABASE; # name of the sqlite database
my $GENOMEFILE = "/home3/Genomes/aedes_aegypti_46_1a/aedes_aegypti_46_1a.fas"; 

#set and test inputs
GetOptions(
	'i:s'     => \$INPUTGFF3,
	't:s'     => \$INPUTGTF,
	's:s'     => \$SQLITEDATABASE,
	'g:s'     => \$GENOMEFILE
 );
unless ((defined $INPUTGFF3 or defined $INPUTGTF) &&
	(defined $SQLITEDATABASE) &&
	(defined $GENOMEFILE)) {
		die "usage: perl gff2sqlite (-i <GFF3 file input> or -t <GTF file input>) -s <SQLITE database name> -g <Genome file>\n";
}

# create a temporary file to store the modified gff3
my $temp_filename_gff3 = File::Temp->new( UNLINK => 1, SUFFIX => '.gff3' );
open (OUTPUT, ">$temp_filename_gff3") or die;

if (defined $INPUTGFF3) { #go here if the input is a gff3 file
	# apply any updates necessary to the gff3 file
	open (INPUT, $INPUTGFF3) or die "cannot open file $INPUTGFF3\n";
	while (my $line = <INPUT>) {
		if ($line =~ /^(.+)ID=(\w+\d+);(.*)$/) {
			print OUTPUT "$1", "Name=$2;", "ID=$2;", "$3\n";
		}
		elsif ($line =~ /^(.+)ID=(\w+\d+-\S\S);(.*)$/) {
			print OUTPUT "$1", "Name=$2;", "ID=$2;", "$3\n";
		}
		else {
			print OUTPUT "$line";
		}
	}
	close INPUT;
	close OUTPUT;
}
elsif (defined $INPUTGTF) { #go here if the input is a gtf file
	open (INPUT, $INPUTGTF) or die "cannot open file $INPUTGTF\n";
	print OUTPUT "##gff-version 3\n";

	my %seengene; #holds the name of the gene that have been printed already
	#convert gtf to gff3
	while (my $line = <INPUT>) {
		if ($line =~ /^(\S+)\s+(\S+)\s+transcript\s(\d+)\s(\d+)\s+(\d+)\s+(\S)\s+\S\s+gene_id\s+\"(\S+)\";\s+transcript_id\s+\"(\S+)\";\s+FPKM\s+\"(\S+)\";\s+frac\s+\"(\S+)\";\s+conf_lo\s+\"(\S+)\";\s+conf_hi\s+\"(\S+)\";\s+cov\s+\"(\S+)\";\s+full_read_support\s+\"(\S+)\";/) {
			my $contig = $1;
			my $program = $2;
			my $b1 = $3;
			my $b2 = $4;
			my $perc = $5;
			my $ori = $6;
			my $gene_id = $7;
			my $transcript_id = $8;
			my $FPKM = $9;
			my $frac = $10;
			my $conf_lo = $11;	
			my $conf_hi = $12;
			my $cov = $13;
			my $full_read_support = $14;

			unless ($ori eq "-") {
				$ori = "+";
			}	
			
			unless (exists $seengene{$gene_id}) {
				print OUTPUT "$contig\t$program\tgene\t$b1\t$b2\t.\t$ori\t.\tID=$gene_id;Name=$gene_id\n";
			}
			$seengene{$gene_id} = 1;
			print OUTPUT "$contig\t$program\ttranscript\t$b1\t$b2\t.\t$ori\t.\tID=$transcript_id;Name=$transcript_id;Parent=$gene_id;FPKM=$FPKM;frac=$frac;conf_lo=$conf_lo;conf_hi=$conf_hi;cov=$cov;full_read_support=$full_read_support\n"; 	
		}
		elsif ($line =~ /^(\S+)\s+(\S+)\s+exon\s(\d+)\s(\d+)\s+(\d+)\s+(\S)\s+\S\s+gene_id\s+\"(\S+)\";\s+transcript_id\s+\"(\S+)\";\s+exon_number\s+\"(\d+)\";\s+FPKM\s+\"(\S+)\";\s+frac\s+\"(\S+)\";\s+conf_lo\s+\"(\S+)\";\s+conf_hi\s+\"(\S+)\";\s+cov\s+\"(\S+)\";/) {
			my $contig = $1;
			my $program = $2;
			my $b1 = $3;
			my $b2 = $4;
			my $perc = $5;
			my $ori = $6;

			my $gene_id = $7;
			my $transcript_id = $8;
			my $exon_number = $9;
			my $FPKM = $10;
			my $frac = $11;
			my $conf_lo = $12;	
			my $conf_hi = $13;
			my $cov = $14;
			unless ($ori eq "-") {
				$ori = "+";
			}
			print OUTPUT "$contig\t$program\texon\t$b1\t$b2\t.\t$ori\t.\tID=exon:$transcript_id:$exon_number;Parent=$gene_id;Exon_number=$exon_number;FPKM=$FPKM;frac=$frac;conf_lo=$conf_lo;conf_hi=$conf_hi;cov=$cov\n"; 	
		}
		else {
			my @data = split " ", $line;
			my $contig = $data[0];
                        my $program =  $data[1];
                        my $b1 =  $data[3];
                        my $b2 =  $data[4];
                        my $ori =  $data[6];

                        my $gene_id =  strip_quotes($data[9]);
                        my $transcript_id =  strip_quotes($data[11]);
                        my $exon_number =  strip_quotes($data[13]);

			print OUTPUT "$contig\t$program\tgene\t$b1\t$b2\t.\t$ori\t.\tID=$gene_id;Transcript_id=$transcript_id;Exon_number=$exon_number\n";
print "$contig\t$program\tgene\t$b1\t$b2\t.\t$ori\t.\tID=$gene_id;Transcript_id=$transcript_id;Exon_number=$exon_number\n";
		}
#		else {
#			die "died at line:\n$line";
#		}
	}
	close INPUT;
	close OUTPUT;
#`cp $temp_filename_gff3 haha.txt`;
}
else {
	die; #should never get here if the input testing works right
}

# create sqlite database
`bp_seqfeature_load -a DBI::SQLite -c -f -d $SQLITEDATABASE $GENOMEFILE $temp_filename_gff3`;
#close OUTPUT;

sub strip_quotes {
	my $text = shift;
	my $text2 = substr $text, 1, -2;
	return($text2);
}
