#!/usr/bin/perl
# August 28, this script take paired file result of "clean_pair.pl" and normalizes the data and gets it ready for trinity

use strict;
use File::Temp ();
use Getopt::Long;
use File::Basename;

#return date and time
sub datetime {
	use POSIX qw/strftime/;
	return (strftime('%D %T',localtime));
}

my $pairinput; #paired file from "clean_pair.pl"
my $outputdir;
my $tempfile; #if desired rather than a temporary file the user can specify to keep all temp file, using this name
GetOptions(
	'i:s'   => \$pairinput,
	'o:s'   => \$outputdir,
	't:s'   => \$tempfile 
);
unless ($pairinput) {
	die "usage: perl prep_with_norm.pl -i <INPUT paired FASTQ file> -t <OPTIONAL: input name of temporary file with modified headers>\n";
}
my @suffixes = (".fq", ".fastq");
my $inputbase = fileparse($pairinput, @suffixes);

#create log file
if ($outputdir) {
	my $dir_test = mkdir($outputdir, 0777);
        unless ($dir_test) {
                die "cannot create directory $outputdir\n";
        }
	open (LOG, ">$outputdir/Log.txt") or die ("cannot create $outputdir/Log.txt");
}
else {
	open (LOG, ">Log.txt") or die ("cannot create Log.txt");
	$outputdir = `pwd`;
	chomp $outputdir;
#	$outputdir .= "/";
}
$outputdir .= "/";

#copy data to temporary file
#print LOG datetime, " copying input file to temporary file... ", 
#my $initial_data = File::Temp->new( UNLINK => 1, SUFFIX => '.fastq' ); # temporary file with original data
#`cp $pairinput $initial_data`;
#print LOG " done\n";

#determine if a new temporary file needs to be made or use the one specified by the user
my $modfile; #file that holds the modifed headers
if ($tempfile) {
	$modfile = $tempfile;
}
else {
	$modfile = File::Temp->new( UNLINK => 1, SUFFIX => '.fastq' ); #temp file with modified headers
}

#run the subs
if ($tempfile) {
	print LOG datetime, "keeping all temporary files using $tempfile as name base\n";
}
print LOG datetime, " modifying the headers... ", modheader($pairinput, $modfile), "\n"; #temporary file with modified headers
print LOG datetime, " checking the lengths... ", checklen($modfile), " \n";
print LOG datetime, " normalize and split... ", normalize($modfile, $inputbase), "\n";

exit;

sub modheader {
	my ($filename, $outfilename) = @_;
	open (INPUT, $filename) or die "cannot open $filename\n";
	open (OUTPUT, ">$outfilename") or die "cannot open $outfilename\n";
	while (my $line = <INPUT>) {
		my ($l1) = $line =~ /([^\s]+)/; #matches only the first word
		my $l2 = <INPUT> . <INPUT> . <INPUT>;
		my ($l3) = <INPUT> =~ /([^\s]+)/; #matches only the first word
		my $l4 = <INPUT> . <INPUT> . <INPUT>;

		chomp $l1;
		chomp $l3;
		if (($l1 =~ /\S+\/1$/) and ($l3 =~ /\S+\/2$/) ) {
			my ($n1) = $l1 =~ /(^\S+)\/1$/;
			my ($n2) = $l3 =~ /(^\S+)\/2$/;
			if ($n1 ne $n2) {
				die "names $n1 and $n2 don't match, this may not be a paired file\n";
			}
			print OUTPUT "$l1\n", $l2, "$l3\n", $l4;
		}
		else {

			 if ($l1 ne $l3) {
	                        die "ha $l1 and\n$l3 don't match, this may not be a paired file\n";
        	        }

			if ($l1 =~ /\/1$/) {
				print OUTPUT "$l1\n";
			}
			else {
				print OUTPUT "$l1", "/1\n";
			}
			print OUTPUT $l2;
			if ($l3 =~ /\/2$/) {
				print OUTPUT "$l3\n";
			}
			else {
				print OUTPUT "$l3", "/2\n";
			}
			print OUTPUT $l4;
		}

	}
	close INPUT;
	close OUTPUT;
#	`mv $modfile $filename`;
	return ("done");
}

sub checklen {
	my ($inputfile) = @_;
	my $MINLEN = 26;
	open (INPUT, $inputfile) or die "cannot open $inputfile\n";
	while (my $line = <INPUT>) {
		my $l2 = <INPUT>;
		my $l3 = <INPUT>;
		my $l4 = <INPUT>;
		chomp $l2;
		if (length $l2 < $MINLEN) {
			print "ERROR, read is shorter than expected ($MINLEN)\n";
			print "$line";
			print "$l2\n";
			print "$l3";
			print "$l4";
		}
	}
	close INPUT;
	return "ok";
}

sub normalize {
	use File::Basename;
	my ($filename, $outbase) = @_;
	my $basename = basename ($filename);
	my $dirname = dirname($filename);
	my $localdir = `pwd`;
	`~/khmer/scripts/normalize-by-median.py -k 20 -N 4 -x 2e9 -C 20 $filename`;
	my $keepfile = $basename . ".keep";
	`python ~/khmer/sandbox/strip-and-split-for-assembly.py $keepfile`;
	my $pefile = $keepfile . ".pe";
	my $sefile = $keepfile . ".se";
	` python ~/khmer/sandbox/split-pe.py $pefile`;
	my $pefile1 = $pefile . ".1";
	my $pefile2 = $pefile . ".2";
	
	my $out1name = $outputdir . $outbase . "-pe1.fq";
	my $out2name = $outputdir . $outbase . "-pe2.fq";
	my $out3name = $outputdir . $outbase . "-se.fq";

	
	` cp $pefile1 $out1name`;
	` cp $pefile2 $out2name`;
	` cp $sefile $out3name`;
	
	unless ($tempfile) { #if a temporary file is specified don't erase the temporary steps
		`rm $basename*`;
	}
	return ("done, resuts in files $out1name, $out2name, $out3name");
}
