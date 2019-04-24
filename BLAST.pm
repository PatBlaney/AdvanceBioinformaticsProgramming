package BLAST;
use Moose;
use feature 'say';
use MooseX::FollowPBP;

# Use BUILD consturctor to instantiate an object and set attributes
# at same time
sub BUILD {

	# Accept key-value hash reference as parameter then dereference it
	my ( $self, $args ) = @_;
	my $blast_line = $args->{blast_line};

	# Isolate the transcript ID, isoform number, GI number,
	# SwissProt ID with version number, protein entry name,
	# identity percentage, length of query sequence, count
	# of mismatches, and gap opening count
	my $parsing_regex = qr/
						(?<transcript>\S+)\|
						(?<isoform>m\.\d+)\s+gi\|
						(?<gi>\d+)\|sp\|
						(?<swissprot>.+)\.\d\|
						(?<entry_name>\w+)\s+
						(?<identity>\d{1,3}\.\d+)\s+
						(?<len>\d+)\s+
						(?<mismatch>\d+)\s+
						(?<gapopen>\d+)
						/x;

	# If BLAST line can be parsed, set all attributes for each BLAST object
	if ( $blast_line =~ /$parsing_regex/ ) {

		$self->{transcript} = $+{transcript};
		$self->{isoform}    = $+{isoform};
		$self->{gi}         = $+{gi};
		$self->{sp}         = $+{swissprot};
		$self->{prot}       = $+{entry_name};
		$self->{pident}     = $+{identity};
		$self->{len}        = $+{len};
		$self->{mismatch}   = $+{mismatch};
		$self->{gapopen}    = $+{gapopen};
	}
}

# Method to print out all attributes for each BLAST object
sub print_all {

	my ($self) = @_;

	# Sanity check to see if BLAST object has a transcript ID
	if ( defined $self->get_transcript() ) {

		# Print out all attributes for BLAST object in tab-separated format
		say join( "\t",
			$self->get_transcript(), $self->get_isoform(),
			$self->get_gi(),         $self->get_sp(),
			$self->get_prot(),       $self->get_pident(),
			$self->get_len(),        $self->get_mismatch(),
			$self->get_gapopen() );
	}

	# Print out message to let user know the BLAST object cant be printed
	# since it has no transcript ID
	else {

		say "This BLAST object cannot be printed.";
	}
}

# Set the attributes for all BLAST objects
has 'transcript' => (
	is        => 'ro',
	isa       => 'Str',
	clearer   => 'clear_transcript',
	predicate => 'has_transcript'
);

has 'isoform' => (
	is        => 'ro',
	isa       => 'Str',
	clearer   => 'clear_isoform',
	predicate => 'has_isoform'
);

has 'gi' => (
	is        => 'ro',
	isa       => 'Int',
	clearer   => 'clear_gi',
	predicate => 'has_gi'
);

has 'sp' => (
	is        => 'ro',
	isa       => 'Str',
	clearer   => 'clear_sp',
	predicate => 'has_sp'
);

has 'prot' => (
	is        => 'rw',
	isa       => 'Str',
	clearer   => 'clear_prot',
	predicate => 'has_prot'
);

has 'pident' => (
	is        => 'ro',
	isa       => 'Num',
	clearer   => 'clear_pident',
	predicate => 'has_pident'
);

has 'len' => (
	is        => 'ro',
	isa       => 'Int',
	clearer   => 'clear_len',
	predicate => 'has_len'
);

has 'mismatch' => (
	is        => 'ro',
	isa       => 'Int',
	clearer   => 'clear_mismatch',
	predicate => 'has_mismatch'
);

has 'gapopen' => (
	is        => 'ro',
	isa       => 'Int',
	clearer   => 'clear_gapopen',
	predicate => 'has_gapopen'
);

1;
