#!/usr/bin/perl -w
# moves files with names containing (********)
# will not move if file exists (-n in mv)
# need to provide directory name as argument
use strict;
use warnings;
use File::Find;

find({ wanted => \&process_file, no_chdir => 1 }, @ARGV);

sub process_file {
    if (-f $_) {
        my $f1=$_;
        if ($f1 =~ /^(.+)(\s\(\S\S\S\S\S\S\S\S\))(\.\S+)/){
          my $f2=$1 . $3;
          `mv -n "$f1" "$f2"`;
          print "$f2\n";
        }
    }
}
