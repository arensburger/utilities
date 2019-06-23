#!/usr/bin/perl
use strict;
use warnings;

my %scaffold; # scaffold as key and number of reads mapping to it as value
my %length;
my %orientation;
my $numreads; # total number of reads
my $mappedreads;
my %read; # sequence of the read, frequency as value

open BAM,"samtools view $ARGV[0] |";

# read the data
while(<BAM>){
  next if(/^(\@)/);  ## skipping the header lines (if you used -h in the samools command)
  s/\n//;  s/\r//;  ## removing new line
  my @sam = split(/\t+/);  ## splitting SAM line into array

  unless ($sam[1] == 4) { # exclude the reads that did not map
    $orientation{$sam[1]} += 1;
    $scaffold{$sam[2]} += 1;
    $length{length $sam[9]} += 1;
    $read{$sam[9]} += 1;
    $mappedreads++;
  }
  $numreads++;
}

#print the results
print "total number of reads $numreads\n";
my $percent = $mappedreads/$numreads;
print "mapped reads $mappedreads ($percent)\n";
print "Orientation:\n";
foreach my $key (sort {$a <=> $b} keys %orientation) {
   print "$key\t$orientation{$key}\n";
}
print "Length:\n";
foreach my $key (sort {$a <=> $b} keys %length) {
   print "$key\t$length{$key}\n";
}
print "Most abundant reads:\n";
my @data;
foreach my $r (sort {$read{$b} <=> $read{$a}} keys %read) {
  my $percent = $read{$r}/$mappedreads;
  push @data, "$r\t$read{$r}\t($percent)";
}
for (my $i=0; $i<10; $i++) {

  print "$data[$i]\n";
}
