# July 2022 Take a fasta file as input and creates an individual directory and files inside each direrctory
use strict;
use Getopt::Long;
use Cwd;

my $filename; #name of input file

##### read and check the inputs
GetOptions(
	'in:s'   => \$filename,
);
unless ($filename) {
	die "usage perl create_directories.pl <-in file name REQUIRED>\n";
}

my %input = genometohash($filename);
my %names; # holds all the sequence names, used to check that they are unique

### make a new top directory to hold all the individual ones
my $topdirname =  getcwd . "/TEs"; # create top director in current directory
unless (mkdir $topdirname) {
	die "ERROR, cannot create directory $topdirname\n";
}

foreach my $ftitle (keys %input) {
	if ($ftitle =~ /^(\S+)#/) {
		my $seqname = $1; # name of the sequence

		#check that the name is not duplicated
		if (exists $names{$seqname}) {
			die "ERROR, the name $seqname is duplicated\n";
		}
		$names{$seqname}=0;

		#create new directory
		my $dirname = $topdirname . "/". $seqname;
		unless (mkdir $dirname) {
			die "ERROR, cannot create directory $dirname\n";
		}

		#create fasta file
		my $fastname = $dirname . "/" . $seqname . ".fa";
		open (OUTPUT, ">$fastname") or die "ERROR, cannot create fasta file $fastname";
		print OUTPUT ">$seqname\n";
		print OUTPUT $input{$ftitle};
		close OUTPUT;
	}
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
