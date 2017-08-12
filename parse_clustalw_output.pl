#!/usr/bin/perl
### August 2017. Takes clustalw output and reports stats

use strict;
use Getopt::Long;


##> Define options
my %config;
GetOptions (\%config,
            'in=s',
#            'out=s',
            'help');

##> Print USAGE if --help
if ($config{help}) {printUsage(1);}

##> Check if no mandatory parameter is missing and set defaults
if (!exists $config{in})         {printUsage();}
#if (!exists $config{out}) {$config{out} = "out";}

### Main program ###

my %seqname; # holds the sequence names as key and total size as value
my $identities; #total number of identities
open (INPUT, $config{in}) or die "cannot open file $config{in}\n";
<INPUT>; #skip the first line
while (my $line = <INPUT>) {
	if (length $line > 1) { #skip blank lines
		if ($line =~ /^(\S+)\s+(\S+)/) { # lines with sequences
			$seqname{$1} += length $2;
		}
		else {
			$identities += ($line =~ tr/\*//);
		}
	}
	
}
close INPUT;

# print output #
my $totalsize;
print "size of each sequence\n";
foreach my $key (keys %seqname) {
	print "$key\t$seqname{$key}\n";
	$totalsize = $seqname{$key};
}
my $percent_id = 100 * ($identities/$totalsize);
print "Number of identities $identities ($percent_id", "%)\n";



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

print STDOUT "USAGE : parse-clustalw_output -in \"clustalw output\"
Options : 
    -in | text		clustalw output file (Mandatory)
    -h | help		You already know it ...\n\n";
    exit;
}
