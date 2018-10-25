#!/usr/bin/perl
# Oct 2018 convert fastq to fasta format

use strict;

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
