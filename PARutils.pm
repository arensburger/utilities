### Commonly used subroutines, Peter Arensburger

#load a genome into a hash
sub genometohash {
	use strict;
	(my $filename) = @_;
	my %genome; #hash with the genome
	my $seq="";
	my $title;
	open (INPUT100, $filename) or die "cannot open input file $filename in sub genometohash\n";
	my $line = <INPUT100>;
	my $title;
	my $seq = "";

	# dealing with the first line
	if ($line =~ />(.+)/) {
		chomp $1;
		$title = $1;
	}
	else {
		die "ERROR, fasta file $filename does not start with a title line\n";
	}
	## dealing with the remaining lines 
	while (my $line = <INPUT100>) {
		if ($line =~ />(.+)/)  {
			chomp $1;
			my $new_title = $1;
			if (exists $genome{$new_title}) {
				print STDERR "error in sub genometohash, two contigs have the name $new_title, ignoring one copy\n";
			}
			else {
				$genome{$title} = $seq;
				$title = $new_title;
			}
			$seq = "";
		}
		else {
			$line =~ s/\s//g;
			$seq .= $line;
		}
	}
	$genome{$title} = $seq;
	close INPUT100;
	return (%genome);
}

#reverse complement
sub rc {
    my ($sequence) = @_;
    $sequence = reverse $sequence;
    $sequence =~ tr/ACGTRYMKSWacgtrymksw/TGCAYRKMWStgcayrkmws/;
    return ($sequence);
}

1;