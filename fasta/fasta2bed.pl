#!/usr/bin/perl -w
# July 2014 takes a fasta file and turns it into a simple bed file

use strict;
use diagnostics;
#use warnings;
use Getopt::Long;
#use agutils;
#use Term::ANSIColor;
#use Data::Dumper;


#> Setting Parameters
##> Define outputs colors
#print STDOUT color 'blue';
#print STDERR color 'red';

##> Define options
my %config;
GetOptions (\%config,
            'fasta=s',
            'out=s',
            'verbose',
            'debug',
            'help');

##> Print USAGE if --help
if ($config{help}) {printUsage(1);}

##> Check if no mandatory parameter is missing
if (!exists $config{fasta})         {printError ("fasta option is MANDATORY ! \n", 0); printUsage();}
if (!exists $config{out}) {$config{out} = "out";}

## open output file
open(BED, ">$config{out}.bed") or die printError("Unable to open $config{out}.bed\n", 1);
## read the fasta file
my %fasta = genometohash($config{fasta});
foreach my $seq (keys %fasta) {
	my $seqlen = length $fasta{$seq};
	print BED "$seq\t1\t$seqlen\n";
}
close BED;
exit;


###########################################################################
################################ Functions ################################
###########################################################################
sub printError{
    my $string = shift;
    my $exit = shift;

    print STDERR $string;
    exit if $exit;
}

###########################################################################
sub printUsage{

    print STDOUT
"USAGE : fasta2bed -f \"fasta format file\" -o \"base name of bed file\"

Options :
    -f | fasta		Input fasta file (Mandatory)
    -o | out   		Basename of bed ouput file (default \"out\")
    -v | verbose	MORE text dude !!!!
    -h | help		You already know it ...\n\n";
    exit;
}

#load a genome into a hash
sub genometohash {
	use strict;
	(my $filename) = @_;
	my %genome; #hash with the genome
	my $seq="";
	my $title;
	open (INPUT, $filename) or die "cannot open input file $filename in sub genometohash\n";
	while (my $line = <INPUT>) {
		if (($line =~ />(\S+)/) && (length $seq > 1)) {
			if (exists $genome{$title}) {
				print STDERR "error in sub genometohash, two contigs have the name $title, ignoring one copy\n";
#				exit;
			}
			else {
				$genome{$title} = $seq;
			}
			#chomp $line;
			my @data = split(" ", $line);
			$title = $data[0];
			$title = substr $title, 1;
			$seq = "";
		}
		elsif ($line =~ />(\S+)/) { #will only be true for the first line
			#chomp $line;
			my @data = split(" ", $line);
			$title = $data[0];
		$title = substr $title, 1;
                        $seq = "";
		}
		else {
			$line =~ s/\s//g;
			$seq .= $line;
		}
	}
	$genome{$title} = $seq;

	return (%genome);
}
