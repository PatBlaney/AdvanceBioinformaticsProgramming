#!/usr/bin/perl
use strict;
use warnings;
use feature 'say';

say "Content-type: text/plain\n";
say "Hello CGI World!\n";
say $ENV{REMOTE_ADDR};
say $ENV{SCRIPT_NAME};
say $ENV{SERVER_NAME};
say $ENV{REQUEST_METHOD};
say $ENV{SCRIPT_FILENAME};
say $ENV{SERVER_SOFTWARE};
say $ENV{QUERY_STRING};
say $ENV{CONTEXT_DOCUMENT_ROOT};
say $ENV{REQUEST_URI};