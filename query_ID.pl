#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use feature 'say';

# Initialize variables for the DB handle (i.e connection), query string,
# synonym and associated GO ID
my ( $dbh, $sth, $id, $synonym );

# Use DBI package to connect to MySQL DB
$dbh = DBI->connect( 'dbi:mysql:go', 'blaney.p', 'Bioinformatics93' )
  || die "Error opening database: $DBI::errstr\n";

# Query table for specific ID
$sth = $dbh->prepare(
	"SELECT term_id, term_synonym FROM term_synonym WHERE term_id = 42952;")
  || die "Prepare failed: $DBI::errstr\n";

# Execute retrieval query
$sth->execute()
  || die "Couldn't execute query: $DBI::errstr\n";

# Print out all synonyms with associated GO ID that were gathered with query
while ( ( $id, $synonym ) = $sth->fetchrow_array ) {
	say "$synonym has ID $id";
}

# Signal completion of query execution
$sth->finish();

# Disconnect from the DB
$dbh->disconnect() || die "Failed to disconnect\n";
