#!/usr/bin/perl
#simpledb.plx
use warnings;
use strict;
use POSIX;
use SDBM_File;

# Declare hash to tie DB to and initlaize variable with DB name
my %dbm;
my $db_file = "demo.dbm";

# Tie the DB to the hash by creating and setting permissions, give confirmation
# if connection successful or failure
tie %dbm, 'SDBM_File', $db_file, O_CREAT | O_RDWR, 0644;
if ( tied %dbm ) {
	print "File $db_file now open.\n";
}
else {
	die "Sorry - unable to open $db_file\n";
}

$_ = "";

# Use loop to prompt user for DB option, output message if invalid option passed
until (/^q/i) {
	print "What would you like to do? ('o' for options): ";
	chomp( $_ = <STDIN> );
	if    ( $_ eq "o" ) { dboptions() }
	elsif ( $_ eq "r" ) { readdb() }
	elsif ( $_ eq "l" ) { listdb() }
	elsif ( $_ eq "w" ) { writedb() }
	elsif ( $_ eq "d" ) { deletedb() }
	elsif ( $_ eq "x" ) { cleardb() }
	else                { print "Sorry, not a recognized option.\n"; }
}

# Untie from the DB upon completion of use
untie %dbm;

# Subroutine to display all valid options to pass to the DB and their descriptions
sub dboptions {
	print <<EOF;
		Options available:
		o - view options
		r - read entry
		l - list all entries
		w - write entry
		d - delete entry
		x - delete all entries
EOF
}

# Subroutine that accepts DB hash key and returns associated stored value if it exists
sub readdb {
	my $keyname = getkey();
	if ( exists $dbm{"$keyname"} ) {
		print "Element '$keyname' has value $dbm{$keyname}";
	}
	else {
		print "Sorry, this element does not exist.\n";
	}
}

# Subroutine to display all stored key-value pairs in the DB
sub listdb {
	foreach ( sort keys(%dbm) ) {
		print "$_ => $dbm{$_}\n";
	}
}

# Subroutine that accepts a key and a value, stores pair in DB unless key already used
sub writedb {
	my $keyname = getkey();
	my $keyval  = getval();
	if ( exists $dbm{$keyname} ) {
		print "Sorry, this element already exists.\n";
	}
	else {
		$dbm{$keyname} = $keyval;
	}
}

# Subroutine that accepts key and outputs message to confirm deletion
sub deletedb {
	my $keyname = getkey();
	if ( exists $dbm{$keyname} ) {
		print "This will delete the entry $keyname.\n";
		delete $dbm{$keyname} if besure();
	}
}

# Subroutine will output message to confirm clear all entries in DB
sub cleardb {
	print "This will delete the entire contents of the current database.\n";
	undef %dbm if besure();
}

# Subroutine that requests key from user to look up in DB
sub getkey {
	print "Enter key name of element: ";
	chomp( $_ = <STDIN> );
	$_;
}

# Subroutine that requests value from user to look up in DB
sub getval {
	print "Enter value of element: ";
	chomp( $_ = <STDIN> );
	$_;
}

# Subroutine to pose confirmation warning to user before final action
# Will return TRUE if (and only if) that input matches /^y/i
sub besure {
	print "Are you sure you want to do this?";
	$_ = <STDIN>;
	/^y/i;
}

