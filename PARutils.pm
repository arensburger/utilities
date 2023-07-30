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

#read fasta file and return the first element title and sequence
sub fasta_first_seq {
	use strict;
	(my $filename) = @_;
	my $seq;
	my $title;

	open (INPUT100, $filename) or die "cannot open input file $filename, $!\n";
	my $line = <INPUT100>;

	# dealing with the first line
	if ($line =~ />(.+)/) {
		chomp $1;
		$title = $1;
	}
	else {
		return (-1, "");
	}

	# read the file through the first sequence
	my $first_seq = 1; # boolean set to 1 until hit the next sequence starting with a greater than sign
	while (($line = <INPUT100>) and ($first_seq)) {
		if ($line =~ />/) {
			$first_seq = 0;
		}
		else {
			chomp $line;
			$seq .= $line;
		}
	}

	# return the sequences
	return ($title, $seq);
}

#reverse complement
sub rc {
    my ($sequence) = @_;
    $sequence = reverse $sequence;
    $sequence =~ tr/ACGTRYMKSWacgtrymksw/TGCAYRKMWStgcayrkmws/;
    return ($sequence);
}

# make a consensus sequence based on an alignment file
# provide two thresholds 1) $CONSENSUS_GAP_THRESHOLD --> what percent of a position is NOT gaps to make it part of the conensus
#	2) $CONSENSUS_CALL_THRESHOLD --> of those nucleotides that are not gaps, what percent threshold to call it a base (otherwise it's an N)
sub makeconsensus {
	use strict;
	my ($alignment_file_name,  $CONSENSUS_GAP_THRESHOLD, $CONSENSUS_CALL_THRESHOLD) = @_;
	my (%seq) = genometohash($alignment_file_name);
	my $alignment_length = length($seq{(keys %seq)[0]});
	my $consensus_sequence; # final consensus sequence;

	# go through each position of the alignment and decide if needs to be removed
	for (my $i=0; $i<$alignment_length; $i++) { # go through positions of the alignment
		my $A=0; # number of A nucleotides at current position
		my $C=0;
		my $G=0;
		my $T=0;
		my $N=0;
		my $gap=0;
#		my $num_sequences; # number of sequences to count at particular position
	 	foreach my $name (keys %seq) { # go through each element of the mafft alignment
	 		if (substr($seq{$name},$i,1) =~ /A/i) {
	 			$A++;
	 		}
			elsif (substr($seq{$name},$i,1) =~ /C/i) {
	 			$C++;
	 		}
			elsif (substr($seq{$name},$i,1) =~ /G/i) {
	 			$G++;
	 		}
			elsif (substr($seq{$name},$i,1) =~ /T/i) {
	 			$T++;
	 		}
			elsif (substr($seq{$name},$i,1) =~ /N/i) {
	 			$N++;
	 		}
			elsif (substr($seq{$name},$i,1) =~ /-/) {
	 			$gap++;
	 		}
			else {
				my $nuc = substr($seq{$name},$i,1);
				warn "WARNING: unecognize nucleotide $nuc in alignment, treating it as gap\n";
				$gap++;
			}
		}

		# decide if this position should be added to the consensus because there are not too many gap
		if ((($A+$C+$G+$T+$N)/(($A+$C+$G+$T+$N)+$gap)) >= ($CONSENSUS_GAP_THRESHOLD / 100)) {

			# decide what nucleotide to add
			if (($A/($A+$C+$G+$T+$N)) >= ($CONSENSUS_CALL_THRESHOLD/100)) {
				$consensus_sequence .= "A";
			}
			elsif (($C/($A+$C+$G+$T+$N)) >= ($CONSENSUS_CALL_THRESHOLD/100)) {
				$consensus_sequence .= "C";
			}
			elsif (($G/($A+$C+$G+$T+$N)) >= ($CONSENSUS_CALL_THRESHOLD/100)) {
				$consensus_sequence .= "G";
			}
			elsif (($T/($A+$C+$G+$T+$N)) >= ($CONSENSUS_CALL_THRESHOLD/100)) {
				$consensus_sequence .= "T";
			}
			else {
				$consensus_sequence .= "N";
			}
		}
	}
	return ($consensus_sequence);
}

1;
