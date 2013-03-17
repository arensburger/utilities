#oct 2010.  Splits a fastq file 
#Jan 2011.  Keep running out of memory, so modifying it to know how long to make it.
#Tue 14 Jun 2011 03:09:06 PM PDT updated so it reports the part names with the original file name

use strict;
use File::Basename;
use Getopt::Long;

#open (INPUT, $ARGV[0]) or die; #fastq file
#my $basename = basename($ARGV[0],  ".fastq");
#my $partitions = $ARGV[1];
my @seq; #holds all the fastq file data in one array
#my $i = 1; #counter that keeps track of the fastq file data (goes from 1 to 4)
my $seqnum = 0; #counter of the sequence number

my $filename; #input file
my $seqtype = "fa"; #type of input file, "fa" = fasta, "fq" = fastq
my $outputname; # the base name for the output, by default the same basename as the input
my $numpartitions; # number of partitions to split this into

##### read and check the inputs
GetOptions(
	'i:s'   => \$filename,
	't:s'	=> \$seqtype,
	'o:s'	=> \$outputname,
	'p:s'	=> \$numpartitions
);
unless ($filename and $numpartitions) {
	die "usage: perl split_file.pl -i <input file name> -p <number of files to split this into> -t <OPTIONAL sequence type: fas, fastq, default fas>, -o <OPTIONAL base output name, default same base name as input>\n";
}
# try to determine the input type
(my $name, my $path, my $suffix) = fileparse($filename,qr"\..[^.]*$");
if (($suffix eq ".fa") or ($suffix eq ".fas") or ($suffix eq ".fasta")) {
	$seqtype = "fa";
}
elsif (($suffix eq ".fq") or ($suffix eq ".fastq")) {
	$seqtype = "fq";
}
else {
	die "Cannot determine file type from the input name: $filename, $suffix";
}

# determine the output name
unless ($outputname) {
	$outputname = basename($filename, $suffix);
}
#test and open the input name
open (INPUT, $filename) or die "Cannot open input file $filename\n";

######## calculate the size of the file
my $lines = 0; #number of lines in the current file
while (my $line = <INPUT>) {
	$lines++;
}
close INPUT;
if ($seqtype eq "fa") {
	$seqnum = $lines / 2;
}
elsif ($seqtype eq "fq") {
	$seqnum = $lines / 4;
}
else {
	die "No sequence type defined\n";
}

#### print the output files
my $chunksize = int(($seqnum + 1)/($numpartitions));
my $linecounter = $chunksize;
my $filenumber = 1;

open (OUTPUT, ">$outputname-part$filenumber$suffix") or die;
open (INPUT, $filename) or die "cannot open input file $filename\n"; #fastq file
while (my $line = <INPUT>) {
#	if ($line =~ /^@\S+/) {

		my $currseq = $line; #current sequence, holds all for fastq lines
		my $linenum; #number of lines long each read is
		if ($seqtype eq "fa") {
			$linenum = 2;
		}
		elsif ($seqtype eq "fq") {
			$linenum = 4;
		}
		else {
			die "unknown seqtype $seqtype\n";
		}
		for (my $i=1; $i < $linenum; $i++) {
			$line = <INPUT>;
			$currseq .= $line;
		}

		
		if (($linecounter == 0) && ($filenumber < $numpartitions)){
			close OUTPUT;
			$filenumber++;
			$linecounter = $chunksize;
			open (OUTPUT, ">$outputname-part$filenumber$suffix") or die "cannot open input file $filename\n";;
  		}
  		print OUTPUT "$currseq";
  		$linecounter--;
#	}
#	else {
#		print "error in fastq expting start of sequence but got\n$line";
#		exit;
#	}
}
