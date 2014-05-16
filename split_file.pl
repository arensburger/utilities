#oct 2010.  Splits a fastq file 
#Jan 2011.  Keep running out of memory, so modifying it to know how long to make it.
#Tue 14 Jun 2011 03:09:06 PM PDT updated so it reports the part names with the original file name
#April 2013.  Revesied this to work with fasta and fastq files.  The reason it's not as simple as it could be is because I don't want to load the whole file into memory.  So need to do a lot work around that.

use strict;
use File::Basename;
use Getopt::Long;

my @seq; #holds all the fastq file data in one array
my $filename; #input file
my $seqtype = "fa"; #type of input file, "fa" = fasta, "fq" = fastq
my $outputname; # the base name for the output, by default the same basename as the input
my $numpartitions; # number of partitions to split this into

##### read and check the inputs
GetOptions(
	'in:s'   => \$filename,
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

####### test and open the input name
open (INPUT, $filename) or die "Cannot open input file $filename\n";
# calculate the size of the file
my $seqnum = 0; #counter of the number of sequences in this file
my $i = 0; #holds the total number of lines
while (my $line = <INPUT>) {
	if (($seqtype eq "fa") and ($line =~ /^>/)) {
		$seqnum++;
	}
	else {
		$i++;
	}
}
if ($seqtype eq "fq") {
	$seqnum = $i/4;
}
close INPUT;

#### print the output files
my $chunksize = int(($seqnum + 1)/($numpartitions));
my $linecounter = $chunksize;
my $filenumber = 1;

open (OUTPUT, ">$outputname-part$filenumber$suffix") or die;
open (INPUT, $filename) or die "cannot open input file $filename\n"; #fastq file
my $title = <INPUT>; #first line holds title
my $sequence; #holds all but the first line
my $after_first_line = 0; # boolean true after the first line
my $i = 1; #counter used for fq files
while (my $line = <INPUT>) {
	if ($seqtype eq "fa") {
		if (($line =~ /^>/) and ($after_first_line) ) {		
			print OUTPUT "$title", "$sequence", "\n";
			$title = $line;
			
			$linecounter--;
			$sequence = "";
		}
		else {
			chomp $line;	
			$sequence .= $line;
		}
	}
	elsif ($seqtype eq "fq") {
		if ($i == 4) {
			print OUTPUT "$title", "$sequence";
			$title = $line;
			$linecounter--;
			$sequence = "";
			$i = 0;
		} 
		else {
			$sequence .= $line;
		}
		$i++;
	}


	if (($linecounter == 0) && ($filenumber < $numpartitions)){
		close OUTPUT;
		$filenumber++;
		$linecounter = $chunksize;
		open (OUTPUT, ">$outputname-part$filenumber$suffix") or die "cannot open input file $filename\n";;
	}
	$after_first_line = 1;
}

#print the last line
print OUTPUT "$title", "$sequence";
if ($seqtype eq "fa") {
	print OUTPUT "\n";
}
close OUTPUT;
