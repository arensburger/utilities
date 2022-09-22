#!/bin/perl

# Nov 2020 Takes a folder with pdf files as input and creates a new folder
# with pdfs compressed with ghostrcript, non pdf files just copied over
# sub directories are ignored

use strict;
use Getopt::Long;
use File::Basename;

my $directory;
my $output_directory_name;

GetOptions(
    'd:s'     => \$directory,
    'o:s'     => \$output_directory_name
);

### check the inputs and format properly
unless ($directory) {
	die "usage: perl compress_pdf_folder.pl -d <REQUIRED: name of directory with pdfs> -o <OPTIONAL: name of ouptut directory, default same name as input put with -small at the end>\n";
}

## get the diretory name to the right format and create it
unless ($directory =~ /\/$/) { # ensure directory ends in a /
  $directory .= "/";
}

## get the output name to the right format
unless ($output_directory_name) {
  my $d2 = $directory;
  chop ($d2);
  $output_directory_name = $d2 . "-small/";
}
$output_directory_name = fixname($output_directory_name);
unless(mkdir $output_directory_name) { die "Unable to create $output_directory_name\n"; }

### creates list of pdf and non pdf files
my $r1 = `find '$directory' -type f`; # list all files recursively
my $r2 = $r1 =~ s/ /\\ /rg; #replace space with \
my $r3 = $r2 =~ s/\(/\\(/rg; #replace ( with \(
my $r4 = $r3 =~ s/\)/\\)/rg; #replace ) with \)
my @r5 = split "\n", $r4; # put into array
my @pdfiles = grep (/.pdf/i, @r5); # array with all the pdf file names;
my @nonpdfiles = grep (!/.pdf/i, @r5); # array with all the pdf file names;

### copy over the non pdf $files
foreach my $f (@nonpdfiles) {
#print "$f $output_directory_name\n"; exit;
  `cp $f $output_directory_name`;
}

### copy of the pdf files compressing them
foreach my $f (@pdfiles) {
  my $filename;
  if ($f =~ /\S+\/(\S+?)$/) {
    $filename = $1;
  }
  else {
    die "error reading file name $f\n";
  }

  my $complete_filename = fixname("$output_directory_name/$filename");
  `gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen -dNOPAUSE -dQUIET -dBATCH -sOutputFile=$complete_filename $f`;
}

# fixes the file names
sub fixname {
  my ($name) = @_;
  my $n2 = $name =~ s/\(/\\(/rg; #replace ( with \(
  my $n3 = $n2 =~ s/\)/\\)/rg; #replace ( with \)
  my $n4 = $n3 =~ s/ /\\ /rg; #replace <space> with \<space>
  return ($n4);
}
