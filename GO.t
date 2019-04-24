#!/usr/bin/perl
use strict;
use warnings;
use GO;

# Based on predefined test data, 29 successess are expected
use Test::More tests => 29;

# Initialize $_ so redefinition of $/ to regex will not cause warning
$_ = '';
local $/ = /\[Term]|\[Typedef]/;

# Read in test data line by line
while (<DATA>) {
	chomp;
	my $go = GO->new( record => $_ );

	# Check if attributes are defined and explicitly determine its value
	ok( defined $go->get_id() );
	ok( $go->has_id() );
	is( $go->get_id(), 'GO:2001316' );
	ok( defined $go->get_name() );
	ok( $go->has_name() );
	is( $go->get_name(), 'kojic acid metabolic process' );
	ok( defined $go->get_namespace() );
	ok( $go->has_namespace() );
	is( $go->get_namespace(), 'biological_process' );
	ok( defined $go->get_def() );
	ok( $go->has_def() );
	is( $go->get_def(), 'The chemical reactions and pathways involving kojic acid.' );

	# Initialize counter for all is_as
	my $is_as_count = 0;

	# Loop through the is_as array reference to check if all defined, increment
	# count for each success
	foreach my $is_a_ref ( @{ $go->get_is_as() } ) {

		ok( defined $is_a_ref );
		ok( $go->has_is_as($is_a_ref) );
		like( $is_a_ref, '/GO:[0-9]{7}/' );
		$is_as_count++;
	}

	# Ensure there is at least one is_a
	ok( $is_as_count > 0 );

	# Initialize counter for all alt_ids
	my $alt_ids_count = 0;

	# Loop through the is_as array reference to check if all defined, increment
	# count for each success
	foreach my $alt_id_ref ( @{ $go->get_alt_ids() } ) {

		ok( defined $alt_id_ref );
		ok( $go->has_alt_ids($alt_id_ref) );
		is( $alt_id_ref, 'GO:0019902' );
		$alt_ids_count++;
	}

	# Ensure there is at least on alt_id
	ok( $alt_ids_count > 0 );

}

__END__
[Term]
id: GO:2001316
name: kojic acid metabolic process
namespace: biological_process
alt_id: GO:0019902
def: "The chemical reactions and pathways involving kojic acid." [CHEBI:43572, GOC:di]
synonym: "5-hydroxy-2-(hydroxymethyl)-4H-pyran-4-one metabolic process" EXACT [CHEBI:43572, GOC:obol]
synonym: "5-hydroxy-2-(hydroxymethyl)-4H-pyran-4-one metabolism" EXACT [CHEBI:43572, GOC:obol]
synonym: "C6H6O4 metabolic process" RELATED [CHEBI:43572, GOC:obol]
synonym: "C6H6O4 metabolism" RELATED [CHEBI:43572, GOC:obol]
synonym: "kojic acid metabolism" EXACT [GOC:obol]
is_a: GO:0034308 ! primary alcohol metabolic process
is_a: GO:0042180 ! cellular ketone metabolic process
is_a: GO:0046483 ! heterocycle metabolic process
is_a: GO:1901360 ! organic cyclic compound metabolic process
