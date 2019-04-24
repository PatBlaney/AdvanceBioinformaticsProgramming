#!/usr/bin/perl
use strict;
use warnings;
use feature 'say';
use BLAST;

# Retrieve all BLAST objects in a sorted order and print all information
my $BLAST_info = read_blast();
foreach my $transcript_id (sort keys $BLAST_info) {
	
	$BLAST_info->{$transcript_id}->print_all();
}

# Read in BLAST file, parse to create BLAST objects, and store in hash
sub read_blast {

	# Open a filehandle for the BLAST output file.
	my $blast_filename      = '/scratch/RNASeq/blastp.outfmt6';
	open( my $blast_file, '<', $blast_filename ) or die $!;

	# Hash to store BLAST file information
	my %BLAST_info;
	
	# Read each BLAST line and parse information
	while (my $blast_line = <$blast_file>) {
		chomp $blast_line;
		
		# Instantiate a new BLAST object
		my $blast = BLAST->new();
		
		 # Set the attributes of each new BLAST object using the parse blast hit method
		$blast->parse_blast_hit($blast_line);
		
		# Sanity check that each BLAST object has a transcript ID attribute before 
		# adding it to the hash
		if (defined $blast->transcript()) {
			
			$BLAST_info{ $blast->transcript()} = $blast;
		}
	}
	
	# Close the BLAST file and return the BLAST info hash as a reference
	close $blast_file;
	return \%BLAST_info;
}