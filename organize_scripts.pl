#!/usr/bin/perl
#looks though the files specified by a given path and return wiki formated description
# March 2021 added default $path and expanded range of scripts beyond just .pl to .R and .sh

use strict;
require File::Temp;
use File::Temp ();
use Getopt::Long;
use File::Find;

#set and test inputs
my @scriptnames; # name of scripts with full path
my $path = "/home/peter/utilities";
GetOptions(
	'p:s'     => \$path,
 );
#unless (defined $path) {
#		die "usage: perl organize_scripts.pl -p <file path REQUIRED>\n";
#}

# read the directory and get all the files
find(\&find_scripts, $path); # puts all the names into the @scriptnames array

# open each script and extract the relevant information
foreach my $script (@scriptnames) {
  open (INPUT, $script) or die "cannot open file $script\n";
  my $readingheader=1; # boolean become 0 once the header has been read
  my $header; #text of the $header
  while ((my $line = <INPUT>) and ($readingheader)) {
    if (($line =~ /^#/) or (length ($line) == 1))  {
      unless ((length ($line) == 1) or ($line =~ /^#!/)){
        chomp $line;
        $header .= $line;
      }
    }
    else {
      $readingheader = 0;
    }
  }
  print "* **", $script, "** ", $header, "\n";
}

sub find_scripts {
  if ($_ =~ /.pl$/) {
    push @scriptnames, "$File::Find::name";
  }
	if ($_ =~ /.R$/) {
    push @scriptnames, "$File::Find::name";
  }
	if ($_ =~ /.sh$/) {
    push @scriptnames, "$File::Find::name";
  }
}
