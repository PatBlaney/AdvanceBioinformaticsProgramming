#!/usr/bin/perl
use strict;
use warnings;
use feature 'say';

read_GO_desc();

sub read_GO_desc {
	my $GO_desc_file = '/scratch/go-basic.obo';
	open( my $go_desc, '<', $GO_desc_file ) or die $!;

	# Initialize $_ so redefinition of $/ to regex will not cause warning.
	$_ = '';
	local $/ = /\[Term]|\[Typedef]/;

	# Read file and parse for data of interest.
	while ( my $long_GO_desc = <$go_desc> ) {
		chomp $long_GO_desc;
		
	  	# Capture the GO ID, name, namespace, and definition from the GO term file	  	
		my $parsing_regex = qr/
							(?<id>GO:\d+)
							\sname:\s(?<name>.*)
							\snamespace:\s(?<namespace>.*[a-z])
							\s.*def:\s\"(?<def>.+\.|.+)\".\[
							/msx;
							
		# Regex to get all is_a Go Terms
		my $findIsa = qr/
					  ^is_a:\s+(?<isa>.*?)\s+!
					  /msx;

		# Regex to get all alt_id Go Terms
		my $findAltId = qr/
						^alt_id:\s+(?<alt_id>.*?)\s+
						/msx;

		if ( $long_GO_desc =~ /$parsing_regex/ ) {

			# Print the GO ID, name, namespace, and def separated by a new line  
			say join("\n", $+{id}, $+{name}, $+{namespace}, $+{def});

			say "alt_ids:";
			my @alt_ids = ();
			while ( $long_GO_desc =~ /$findAltId/g ) {
				
				push( @alt_ids, $+{alt_id} );
			}

			# Not all records contain alt IDs, so check first before printing.
			if (@alt_ids) {
				
				say join( ",", @alt_ids );
			}

			say "isa:";
			my @isas = ();
			while ( $long_GO_desc =~ /$findIsa/g ) {
				
				push( @isas, $+{isa} );
			}
			
			say join( ",", @isas ), "\n";
		}
		else {
			
			say STDERR $long_GO_desc;
		}
	}
	
	close $go_desc;
}
