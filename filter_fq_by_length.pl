#!/usr/bin/perl
# June 2019, filter fq by length

use strict;
use Getopt::Long;

my $inputfilename; # name of the input $filename
my $length;  # minimum sequence length
##### read and check the inputs
GetOptions(
	'in:s'   => \$inputfilename,
	'l:s'	=> \$length,
);
unless ($inputfilename and $length) {
	die "usage perl filter_fq_by_length.pl <-in, input fastq file REQUIRED> <-l minimum length to output REQUIRED>";
}

open (INPUT, $ARGV[0]) or die;
my $i=0;
while (my $line = <INPUT>) {
  if ($line =~ /@(\S+)/) {
    print ">S$i\n";
    $i++;
  }
  else {
    die "Was expecting header but got\n$line";
  }
  $line = <INPUT>;
  print "$line";
  <INPUT>;
  <INPUT>;
}
