#!/usr/bin/perl
# converts a repeat masker output file to a bed file

use strict;
use File::Temp ();
use Getopt::Long;

my $MIN_FRACTION = 0; # minimum fraction of length of RM hit to length of original;

my %config;
GetOptions(\%config,
	'rmout=s',
	'consensi=s',
	'out=s',
);

##> Check if no mandatory parameter is missing and set defaults
if (!exists $config{rmout})         {printUsage();}
if (!exists $config{out}) {$config{out} = "out";}

#### Main program ###

## Read the repeat masker file ##
open (RM, "$config{rmout}") or die "cannot open file $config{rmout}\n";
open (OUT, ">$config{out}") or die "cannot open output file $config{out}\n";
<RM>;
<RM>;
<RM>;
while (my $line = <RM>) {
	my @data = split (" ", $line);
	my $scaffold = $data[4]; 
	my $b1 = $data[5]; 
	my $b2 = $data[6];
	my $ori = $data[8];
	my $name = $data[9];
	if ($ori eq "C") {
		$ori = "-";
	}
	my $ele = $data[10];
	my $sf;
	my $fam;	
	if ($ele =~ /(\S+)\/(\S+)/) {
		$sf = $1;
		$fam = $2
	}
	else {
		$sf = $ele;
		$fam = "unknown"
	}

	if (($sf eq "Low_complexity") or ($sf eq "Simple_repeat") or ($sf eq "Satellite")){
		$fam = $name; 
	}
	my $name2 = "$name" . "#" . "$sf" . "#" . "$fam";
	print OUT "$scaffold\t$b1\t$b2\t$name2\t0\t$ori\n";
}
close RM;
close OUT;

sub printUsage{

print STDOUT "DESCRIPTION: This program takes the .out file of a RepeatMakser run and converts it into a gff3 file\n";
print STDOUT "USAGE : rm2gff3.pl -r \"RepeatMasker .out file\" -c \"fasta file of potential element\" -o \"output file\"
Options : 
    -r | rmout		RepeatMasker .out file (Mandatory)
    -c | consensi	Output of RepeatModeler or other suggested elements (Mandatory)
    -o | out   		Name of ouput file (default \"out\")\n";
    exit;
}

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
exit;
