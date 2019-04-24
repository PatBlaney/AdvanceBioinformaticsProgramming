#!/usr/bin/perl
use strict;
use warnings;

# Load CGI
use CGI;

# Create CGI instance
my $query = new CGI;

# Get name parameter from $query
my $name = $query->param('Name');

# Print $query header
print $query->header();

# Print Hello World
print "Hello World!";
