#reverse complement
sub rc {
    my ($sequence) = @_;
    $sequence = reverse $sequence;
    $sequence =~ tr/ACGTRYMKSWacgtrymksw/TGCAYRKMWStgcayrkmws/;
    return ($sequence);
}

#converts a fasta file to a phylip format, takes in a hash and returns a string
sub ftophy {
	my (%seq) = @_;
	my $TITLELEN = 16; #number of characters in each title
	my $return_string; #holds the returned string
	
	my $ntax = keys ( %seq ); #number of taxa
	my @titles = keys %seq; #put all titles into an array so I can pick one and get the length of the element
	my $nchar = length ($seq{$titles[1]});
	
	$return_string = " $ntax\t$nchar\n";
	
	foreach my $title (keys %seq) {
		my $print_title = substr($title, 0, $TITLELEN);
		$print_title =~ s/\.//g; #remove periods
		#need to have same same spacing so calculating blanks
		my $blanks; #holds the blank space
		for(my $i=(length $print_title); $i<=$TITLELEN; $i++) {
			$blanks .= " ";
		}
		$return_string .= "$print_title" . "$blanks" . "$seq{$title}\n";
	}

	return ($return_string);
}

#find the TIRs of a sequence
sub findtirs {
	my ($seq) = @_;

	my $MISSMATCH = 2; #total allowable mismatches
	my $endfound = 0; #boolean 0 until the end of the TIR is found
	my $pos = 0; #current position in the sequence
	my $lastgoodbase = 0; #position of the last match of bases
	my $miss = 0; #number of non-matching sequences
	while ($pos <= (0.5 * (length $seq)) && ($endfound == 0)) {
	  my $leftbase = substr($seq, $pos, 1); #base on the left end
	  my $rightbase = substr($seq, -$pos -1, 1);
	  
	  #update the current base
	  if ($leftbase eq (rc $rightbase)) {
	    $lastgoodbase = $pos;
	  }
	  else {
	    $miss++;
	  }

	  #take stock if we need to stop
	  if ($miss > $MISSMATCH) {
	    $endfound = 1;
	  }

#	print "$leftbase, $rightbase, $miss, $lastgoodbase\n";
	  $pos++;
	}
	my $tir1 = substr($seq, 0, $lastgoodbase + 1);
	my $tir2 = substr($seq, -$lastgoodbase - 1, $lastgoodbase + 1);

	my @tirs;
	$tirs[0] = $tir1;
	$tirs[1] = $tir2;
	return(@tirs);
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

#Collection of subs subroutines used for extracting hAT elements from the A. gambiea genome.
#Returns the AT content percentage of a string
sub ATcontent {
	my ($seq) = @_;
	my $numTA = ($seq =~ tr/A|T//);
	return ($numTA / (length $seq));
}


# Returns the list of the files in a folder
sub listfolder {
    my ($folder) = @_;
    my @files = (  );
    unless(opendir(FOLDER, $folder)) {
	print "Cannot open folder $folder\n";
	exit;
    }
    @files = readdir(FOLDER);
    closedir(FOLDER);
#    shift(@files);
#   shift(@files);
	
	my $i = 0;
	my @new_files; #list of files without the "." and ".." files
	foreach my $file (@files) {
		unless (($file eq ".") || ($file eq "..")) {
			$new_files[$i] = $file;
			$i++;
		}
	}
	
   return (@new_files);
}

#based on load_fna subroutine, this simply loads a fasta file
sub load_fasta
{
    my $fname = shift;
    my $retval;
    my $line;
    my $accession;
    open FNA, "< $fname" or die "Can't open \"$fname\": $!";
    $line = <FNA>;
    if ($line =~ />(.+$)/) {  #title line
	$accession = $1;
    }
    else {
	print "Could not get accession (perhaps the first line is not a fasta file?)\n";
	exit;
    }
    while (<FNA>)
    {
	chomp;
	$retval .= $_;
    }
    close FNA;
    
    #remove blanks
    $retval =~ s/\s//g;
    return ($retval, $accession);
}

# itrmatch
# By A. Arensburger, modified by P. Arensburger.  Given two ITR sequences
# checks if they are ITRs allowing 3 missmatches.  Returns 0 if false, 1
# if true
sub itrmatch
{
	my ($str1, $str2) = @_;
	my $missmatch = 0;

	$str2 =~ tr/ACGTN/TGCAN/;
	$str2 = reverse($str2);
	for (my $i = 0; $i < 10; $i++) {

	    if (((substr($str1, $i, 1)) cmp (substr($str2, $i, 1))) != 0) {
		$missmatch++;
	    }
	    next if $missmatch > 3;
	}
	if ($missmatch > 3) {
	    return 0;
	}
	else {
	    return 1;
	}
}

# itrmatch_n
# An improvement on the sub "itrmatch2", this allows any number of missmatches.
# Returns 1 is gets a hit and 0 if not.
sub itrmatch_n
{
	my ($str1, $str2, $miss_num) = @_;
	my $missmatch = 0;
	my $firstbasemiss = 0; #this test if the first base is missmatch

	$str1 =~ tr/ACGTN/TGCAN/;
	$str1 = reverse($str1);
	for (my $i = 0; $i < 11; $i++) {	    
	    if (((substr($str1, $i, 1)) cmp (substr($str2, $i, 1))) != 0) {
		if ($i == 0) {
		    $firstbasemiss = 1;
		    next;
		}
		$missmatch++;
	    }
	    next if $missmatch > $miss_num;
	}
	if (($missmatch > $miss_num) || ($firstbasemiss == 1)) {
	    return 0;
	}
	else {
	    return 1;
	}
}

#a modification of the itrmatch_n, this compares two sequences returns 1 if they match 0 if not
sub seqmatch
{
	my ($str1, $str2, $miss_num) = @_;
	my $missmatch = 0;
	
	#test lenght of matches
	unless (length $str1 == length $str2) {
		print "lengths of matching sequences $str1 and $str2 don't add up (this is in agutils.pm)\n";
		exit;
	}

	for (my $i = 0; $i < length $str1; $i++) {	    
	    if (((substr($str1, $i, 1)) cmp (substr($str2, $i, 1))) != 0) {
		$missmatch++;
	    }
	    next if $missmatch > $miss_num;
	}
	if ($missmatch > $miss_num) {
	    return 0;
	}
	else {
	    return 1;
	}
}

#March 2008, an improvement over itrmatch_n and seqmatch.  Compares two sequences of the same length and returns the number of missmatches, allows for reverse complement of one of the squences for TIR matches
sub seqmatch2
{
	use agutils;

	my ($str1, $str2, $rc) = @_; #if rc is "1" means the input is rev-complemented
	my $missmatch = 0;
	
	#test lenght of matches
	unless (length $str1 == length $str2) {
		print "lengths of matching sequences $str1 and $str2 don't add up (this is in agutils.pm)\n";
		exit;
	}

	#test if one of the sequences must be reverse complemented
	if ($rc == 1) {
		$str2 = reverse $str2;
    		$str2 =~ tr/ACGTacgt/TGCAtgca/;
	}
	#test the matches
	for (my $i = 0; $i < length $str1; $i++) {	    
	    if (((substr($str1, $i, 1)) cmp (substr($str2, $i, 1))) != 0) {
		$missmatch++;
	    }
	}
	return $missmatch;
}

#scaff_seq
#Retreives the sequence from the scaffolds given a scaffold number and boundaries
sub scaff_seq
{
	my ($scaffold, $bound1, $bound2) = @_;
	my $dirname = '/home/no_backup/gambiaescaf'; #name of the directory where the scaffolds are stored
	my $sequence; #holds the sequence of the scaffold
	my $substring; #holds the substring of the scaffold of interest

	$filename = $dirname . "/" . $scaffold . '.fna';
	($sequence, $i) = load_fna($filename);
	return $substring = substr($sequence, $bound1, ($bound2 - $bound1));
}

#march 09, this script is defunct, now using "addzeros" instead
#adds 0 to the start of a number, used for sorting, $size is the total number of digits.  The number is assumed to be an integer
#sub zeronum {
#	my ($number, $size) = @_;
#
#	if (length $number > $size) {
#		print "number is too long, cannot add zeros";
#		exit;
#	}
#	my $zeros_to_add = $size - (length $number);
#	for (my $i=0; $i <$zeros_to_add; $i++) {
#		$number = "0" . $number;
#	}
#	return $number;
#}

#returns extract from genome
sub ext_genome {
	use Bio::Index::Fasta;
	use strict;
	my ($GENOME_FILE, $seqname, $c1, $c2) = @_;
	my $inx = Bio::Index::Fasta->new(
		-filename => "index_file",
		-write_flag => 1);
#	unless (-e "index_file") { #create index file if it does not yet exist
		$inx->make_index("$GENOME_FILE");
#		print "made index\n";
#	}
#	my $seqname = $ARGV[1]; #name of the sequence, if this is put as "none" the whole file is read
#	my $c1 = $ARGV[2]; #first coordinate if both this and next argument are blank the the whole file is given as output
#	my $c2 = $ARGV[3]; #second coordinate (see above)
	my $title; #holds the name of the fasta file;
	my $sequence; #holds the whole sequence of the fasta file
	my $substring; #the part we want to see
	my $reverse_complement = 0; #boolean, wether to rc or not
	my $obj = $inx->fetch($seqname);
	
	#testing for rc if true flag it and reverse the coodinates
	if ($c1 > $c2) {
		$reverse_complement = 1;
		my $tempc1 = $c1;
		$c1 = $c2;
		$c2 = $tempc1;
	}
	
	
	#test for rc
	if ($reverse_complement == 1) {
		if (($c1 == "") && ($c2 == "")){ #if no boundaries are given
			$substring = $obj->seq;
		}
		else { #if boundaries are present
			$substring = substr($obj->seq, $c1 - 1, ($c2-$c1 + 1));
		}
		$substring = rc ($substring);
	}
	else {
		if (($c1 == "") && ($c2 == "")){ #if no boundaries are given
			$substring = $obj->seq;
		}
		else { #if boundaries are present
			$substring = substr($obj->seq, $c1 - 1, ($c2-$c1+1));
		}
	}
	
	my $title_name = ">" . $seqname . "_" . $c1 . "_" . $c2;

	return ($title_name, $substring);
}

#given an nucleotide and protein sequence returns the mRNA sequence
# Feb 08.  Takes a nucleotide sequence and a protein sequence as input and outputs the mRNA sequence

sub mRNA {
	use strict; 
	use Bio::SeqIO;
	use Bio::PrimarySeq;

	(my $seq, my $protein) = @_;
	#determine if protein sequence has a stop codon if so, remove it
	if ($protein =~ /\*$/) {
		$protein = substr ($protein, 0, -1);
	}
	
	#determine if the nucleotide sequence ends with a stop codon, if it does add it to end of the output
	my $last_codon = substr($seq, (length $seq) - 3, 3);
	unless ($last_codon =~ /TAA|TAG|TGA/i) {
		$last_codon = "";
	}


	my $MATCHLEN = 4; #number of aa searched to find a match on the new strand	
		
	#create a new sequence object and translate it into all three frames
	my $seq_object  = new Bio::PrimarySeq( -seq => $seq,
						-display_id => 'example1');
	my $t1 = $seq_object->translate(-frame => 0)->seq();
	my $t2 = $seq_object->translate(-frame => 1)->seq();
	my $t3 = $seq_object->translate(-frame => 2)->seq();
	my $tlen = (length $t3) - 1; #length of the translated frames used to stop later
	
	
	my $match_seq = substr($protein, 0, $MATCHLEN); #sequence on proteinused to find the new strand
	my $match_len = 0; #length of the current match on the protein and translated strands
	my $start_pos = 0; #position where translation starts on translated strands
	my $end_pos; #position where translation ends on translated strands
	my $frame; #current frame
	my @tcode; #array where each element is an array of three data points 1) a frame, 2) a start position of translation, 3) stop position of translation
	my $search_seq; #holds the translated sequence that has to be searched next
	my $position = 0; #current position on the protein
	my $start_position = 0; #starting position on protein for current exon
	my $position_transl = 0; #current position on the translated sequences
	
	my @aaexon; #array that holds the exon sequences as amino acids
	my @nucexon; #array that holds the exon sequences as nucleotides
	my @nucintron; #array that holds the intron sequences
	
	#examine the translated sequences and generate a table of info about where the breaks are in @tcode
	while ($position < length($protein)) {
		($frame, $start_pos) = find_frame ($match_seq, $position_transl, $t1, $t2, $t3); #find the frame and where on the frame it starts
	
		if ($frame == 0) { #if can't find the next math this is aborts the program
			print "error, could not find a match to protein sequence $match_seq, after position $position_transl in the translated DNA sequences\n";
			return (0);
#			exit;
		}
	
		$match_len = match_length(substr($protein, $position, (length $protein) - $position), substr(frame_seq($frame, $t1, $t2, $t3), $start_pos, ((length $t1) - $start_pos))); #find the length of the match on the current frame
		
		#update the counters
		$end_pos = $start_pos + $match_len - 1;
		$position += $match_len - 1;
		$position_transl = $end_pos ; 
	
		#update current exon sequence
		push (@aaexon, substr ($protein, $start_position, $position - $start_position));
		$start_position = $position;
	
		#record the information
		push @tcode, [$frame, $start_pos, $end_pos];
	#print "$frame, $start_pos, $end_pos, $match_len, $tlen, $position\n";
	
		#determine the next aa sequence to search
		$match_seq = substr ($protein, $position, $MATCHLEN);
	#print "$match_seq\n";
	}
	
	#transalte the information in @tcode into mRNA
	my $n1 = $seq_object->seq(); #nucleotide sequence starting with first bp of first frame;
	my $n2 = substr($n1, 1, (length $n1) - 1); #nucleotide sequence starting with first bp of second frame;
	my $n3 = substr($n1, 2, (length $n1) - 2); #nucleotide sequence starting with first bp of third frame;
	
	#print the mRNA sequence
	my $mRNA; #string with mRNA sequence
	for my $info (@tcode) {
		if (@$info[0] == 1) {
			$mRNA .= substr($n1, @$info[1] * 3, (@$info[2] * 3) - (@$info[1] * 3));
		}
		elsif (@$info[0] == 2) {
			$mRNA .= substr($n2, @$info[1] * 3, (@$info[2] * 3) - (@$info[1] * 3));
		}
		elsif (@$info[0] == 3) {
			$mRNA .= substr($n3, @$info[1] * 3, (@$info[2] * 3) - (@$info[1] * 3));
		}
		else {
			return (0);
#			"error, no frame @$info[0] exists\n";
#			exit;
		}
	}
	return $mRNA . $last_codon;
	exit;
	
	#returns the string depending on the number, real simple
	sub frame_seq {
		(my $frame, my $s1, my $s2, my $s3) = @_;
		if ($frame == 1) {
			return $s1;
		}
		elsif ($frame == 2) {
			return $s2;
		}
		elsif ($frame == 3) {
			return $s3;
		}
		else {
			return (0);
#			print "error no such frame as $frame\n"; 
#			exit;
		}
	}
	
	#given a short sequence, minimal position, and three sequences find where the sequence matches in the three and the position
	sub find_frame {
		(my $seq, my $minimum, my $s1, my $s2, my $s3) = @_;
		
		#shorten the search to just those AA left to explore
		my $s1_short = substr ($s1, $minimum, (length ($s1) - $minimum));
		my $s2_short = substr ($s2, $minimum, (length ($s2) - $minimum));
		my $s3_short = substr ($s3, $minimum, (length ($s3) - $minimum));
		
		#find matches
		my $frame = 0;
		my $position = length $s1_short; #setting the position very high so the minimal match will be found
		while ($s1_short =~ /$seq/g) {
			if (pos($s1_short) < $position) {
				$frame = 1;
				$position = pos($s1_short);
			}
		}
		while ($s2_short =~ /$seq/g) {
			if (pos($s2_short) < $position) {
				$frame = 2;
				$position = pos($s2_short);
			}
		}
		while ($s3_short =~ /$seq/g) {
			if (pos($s3_short) < $position) {
				$frame = 3;
				$position = pos($s3_short);
			}
		}
	
		$position += $minimum - length ($seq); #adjust the position
		return ($frame, $position);
	}
	
	#given two strings determines how long the two strings match
	sub match_length {
		(my $s1, my $s2) = @_;
		my $index = 0;
		my $match = 0; #boolean 0 when sequences match, 1 when sequences stop matching
	
		while ($match == 0) {
			if (substr($s1, $index, 1) eq substr($s2, $index, 1)) {
				$index++;
			}
			else {
				$match = 1;
			}
			if (($index > length $s1) || ($index > length $s2)) {
				$match = 1;
			}
		}
		return ($index + 1);
		
	}
}

#convert number from something like "1" to "001", good for sorting
sub addzeros {

	(my $num, my $digits) = @_;

	#break number into interger and decimal parts
	my $integer = int($num);
	my $decimal = $num - $integer;
	
	my $zerostoadd = $digits - (length $integer);
	if ($zerostoadd < 0) {
		return "error, too few digits ($digits) to convert $num\n";
	}
	else {
		my $addigits; 
		for (my $i=1; $i <= $zerostoadd; $i++) {
			$addigits .= "0";
		}
		if ($decimal == 0) {
			return ("$addigits" . $integer);
		}
		else {
			my $number = $integer + $decimal;
			return ("$addigits" . $number);
		}
	}
}
#find the TIRs of a sequence
# sub findtirs {
# 	my ($seq) = @_;
# 
# 	my $MISSMATCH = 3; #total allowable mismatches
# 	my $endfound = 0; #boolean 0 until the end of the TIR is found
# 	my $pos = 0; #current position in the sequence
# 	my $lastgoodbase = 0; #position of the last match of bases
# 	my $miss = 0; #number of non-matching sequences
# 	while ($pos <= (0.5 * (length $seq)) && ($endfound == 0)) {
# 	  my $leftbase = substr($seq, $pos, 1); #base on the left end
# 	  my $rightbase = substr($seq, -$pos -1, 1);
# 	  
# 	  #update the current base
# 	  if ($leftbase eq (rc $rightbase)) {
# 	    $lastgoodbase = $pos;
# 	  }
# 	  else {
# 	    $miss++;
# 	  }
# 
# 	  #take stock if we need to stop
# 	  if ($miss > $MISSMATCH) {
# 	    $endfound = 1;
# 	  }
# 
# 	  $pos++;
# 	}
# 	my $tir1 = substr($seq, 0, $lastgoodbase + 1);
# 	my $tir2 = substr($seq, -$lastgoodbase - 1, $lastgoodbase + 1);
# 
# 	my @tirs;
# 	$tirs[0] = $tir1;
# 	$tirs[1] = $tir2;
# 	
# 	return(@tirs);
#}
1;
