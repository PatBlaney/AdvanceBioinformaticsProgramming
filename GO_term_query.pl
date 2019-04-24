#!/usr/bin/perl
use strict;
use warnings;
use DBI;

# Initialize variables for the DB handle (i.e connection)
my $dbh;

# Use DBI package to connect to MySQL DB
$dbh = DBI->connect( 'dbi:mysql:go', 'blaney.p', 'Bioinformatics93' )
  || die "Error opening database: $DBI::errstr\n";

$_ = "";

while ( defined $_ ) {

	# ask user to define desired GO term ID for query
	print "Enter desired GO term ID (type 'exit' to quit)----> ";
	chomp( $_ = <STDIN> );

	# Check if user wants to quit DB query
	if ( $_ =~ /^exit/i ) {

		print "--Goodbye--\n\n";
		exit;
	}

	# Check to insure valid and queriable GO term ID was given
	if ( not $_ =~ /^\d{1,}$/ ) {
		print "| $_ | is not a valid ID format. Enter numbers only.\n\n";
	}

	# If user gives valid GO term ID, convert string of numerics to integer
	# then query the DB for data using that GO ID integer
	if ( $_ =~ /^\d{1,}$/ ) {

		my $query_id = int $_;
		my $db_query = $dbh->prepare("SELECT id, name FROM term WHERE id = $query_id;");
		$db_query->execute();
		my ( $id, $name ) = $db_query->fetchrow_array;

	 	# Check if the GO term ID pulled from DB is defined, if so print it and the
	 	# GO term name, if not, print a message notifying the user
		if ( defined $id ) {

			print "GO ID| $id |\nname| $name |\n\n";
		}
		else {

			print "GO ID| $query_id |not found.\n\n";
		}
	}
}

# Disconnect from the DB
$dbh->disconnect() || die "Failed to disconnect\n";
