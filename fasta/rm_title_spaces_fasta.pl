#!/usr/bin/perl
# Oct 2018 Take a fasta file and replaces spaces in the title with "_"

use strict;

open (INPUT, $ARGV[0]) or die "cannot open input file\n";

while (my $line = <INPUT>) {
  if ($line =~ />/) {
    (my $title = $line) =~ s/ /_/g;
    print "$title"
  }
  else {
    print "$line"
  }
}
