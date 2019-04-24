#!/usr/bin/perl
use strict;
use warnings;
use BLAST;

# Based on predefined test data, 27 successess are expected
use Test::More tests => 27;

# Read in test data line by line
while (<DATA>) {
	chomp;

	# Instantiate a new BLAST object and set the attributes for testing
	my $blast = BLAST->new( blast_line => $_ );

	# Check if attributes are defined explicitly determine its value
	ok( defined $blast->get_transcript() );
	ok( $blast->has_transcript() );
	is( $blast->get_transcript(), 'c997_g1_i1' );
	
	ok( defined $blast->get_isoform() );
	ok( $blast->has_isoform() );
	is( $blast->get_isoform(), 'm.796' );
	
	ok( defined $blast->get_gi() );
	ok( $blast->has_gi() );
	like( $blast->get_gi(), '/[0-9]{8}/' );
	
	ok( defined $blast->get_sp() );
	ok( $blast->has_sp() );
	is( $blast->get_sp(), 'Q9HGN6' );
	
	ok( defined $blast->get_prot() );
	ok( $blast->has_prot() );
	is( $blast->get_prot(), 'DUS1_SCHPO' );
	
	ok( defined $blast->get_pident() );
	ok( $blast->has_pident() );
	is( $blast->get_pident(), '100.00' );
	
	ok( defined $blast->get_len() );
	ok( $blast->has_len() );
	is( $blast->get_len(), '399' );
	
	ok( defined $blast->get_mismatch() );
	ok( $blast->has_mismatch() );
	is( $blast->get_mismatch(), '0' );
	
	ok( defined $blast->get_gapopen() );
	ok( $blast->has_gapopen() );
	is( $blast->get_gapopen(), '0' );
}

__END__
c997_g1_i1|m.796	gi|74638589|sp|Q9HGN6.1|DUS1_SCHPO	100.00	399	0	0	1	399	1	399	0.0	  825
