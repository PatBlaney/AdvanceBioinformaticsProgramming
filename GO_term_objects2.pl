#!/usr/bin/perl
use strict;
use warnings;
use feature 'say';
use GO;

# Retrieve all GO term object and print their information in sorted order
my $GO_terms = read_GO_desc();
foreach my $id ( sort keys $GO_terms ) {

	$GO_terms->{$id}->print_all();
}

sub read_GO_desc {

	my $GO_desc_file = '/scratch/go-basic.obo';
	open( my $go_desc, '<', $GO_desc_file ) or die $!;

	# Initialize $_ so redefinition of $/ to regex will not cause warning.
	$_ = '';
	local $/ = /\[Term]|\[Typedef]/;

	# Initialize hash to store GO term objects with all associated information
	my %GO_terms;

	# Read file and parse for data of interest.
	while ( my $record = <$go_desc> ) {
		chomp $record;

		# Instantiate a new GO object for each GO term
		my $go = GO->new();

 		# Set the attributes of each new GO term object using the parse GO entry method
		$go->parse_GO_entry($record);

		# Check that each GO term object has an ID attribute before adding it to the hash
		if ( defined $go->id() ) {

			$GO_terms{ $go->id() } = $go;
		}
	}

	close $go_desc;
	return \%GO_terms;
}
