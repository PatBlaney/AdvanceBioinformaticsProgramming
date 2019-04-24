package GO;
use Moose;
use feature 'say';
use MooseX::FollowPBP;

# Use BUILD consturctor to instantiate an object and set attributes
# at same time
sub BUILD {

	# Accept key-value hash reference as parameter then dereference it
	my ( $self, $args ) = @_;
	my $record = $args->{record};

	# Regex used to parse GO term entry for ID, name, namespace, and def
	my $parsing_regex = qr/
		^id:\s+(?<id>.*?)\s+
		^name:\s+(?<name>.*?)\s+
		^namespace:\s+(?<namespace>.*?)\s+.*
		^def:\s+\"(?<def>.*?)\"\s+\[
		/msx;

	# Regex used to capture all is_as for each GO term entry
	my $find_is_as = qr/
		^is_a:\s+(?<is_a>.*?)\s+!
		/msx;

	# Regex used to capture all alt_ids for each GO term entry
	my $find_alt_ids = qr/
		^alt_id:\s+(?<alt_id>.*?)\s+
		/msx;

	# If entry can be parsed, set attributes for each GO term object with
	# parsed information
	if ( $record =~ /$parsing_regex/ ) {

		$self->{id}        = $+{id};
		$self->{name}      = $+{name};
		$self->{namespace} = $+{namespace};
		$self->{def}       = $+{def};

		# Add each found is_a to an array to capture all for each GO term
		my @is_as = ();
		while ( $record =~ /$find_is_as/g ) {

			push( @is_as, $+{is_a} );
		}

		# Set is_as attribute to the array of all capture for each GO term
		$self->{is_as} = \@is_as;

		# Add each found alt_id to an array to capture all for each GO term
		my @alt_ids = ();
		while ( $record =~ /$find_alt_ids/g ) {

			push( @alt_ids, $+{alt_id} );
		}

		# Set alt_ids attribute to the array of all capture for each GO term
		$self->{alt_ids} = \@alt_ids;
	}
}

# Method to print all fields of GO term
sub print_all {
	my ($self) = @_;

	# First check for if the GO term has an ID
	if ( $self->get_id() ) {

		# Print the ID, name, namespace, and def of the GO term
		say join( "\t",
			$self->get_id(),        $self->get_name(),
			$self->get_namespace(), $self->get_def() );

		# Check if GO term has is_as or alt_ids, if so print all
		if ( defined $self->get_is_as() ) {

			foreach my $is_a ( @{ $self->get_is_as() } ) {
				say "is_a:", $is_a;
			}
		}

		if ( defined $self->get_alt_ids() ) {

			foreach my $alt_id ( @{ $self->get_alt_ids() } ) {
				say "alt_id:", $alt_id;
			}
		}
	}

	# If no ID for the GO term, print helpful message
	else {

		say "This GO term cannot be printed.";
	}
}

has 'id' => (
	is        => 'ro',
	isa       => 'Str',
	clearer   => 'clear_id',
	predicate => 'has_id'
);

has 'name' => (
	is        => 'ro',
	isa       => 'Str',
	clearer   => 'clear_name',
	predicate => 'has_name'
);

has 'namespace' => (
	is        => 'ro',
	isa       => 'Str',
	clearer   => 'clear_namespace',
	predicate => 'has_namespace'
);

has 'def' => (
	is        => 'ro',
	isa       => 'Str',
	clearer   => 'clear_def',
	predicate => 'has_def'
);

has 'is_as' => (
	is        => 'ro',
	isa       => 'ArrayRef[Str]',
	clearer   => 'clear_is_as',
	predicate => 'has_is_as'
);

has 'alt_ids' => (
	is        => 'ro',
	isa       => 'ArrayRef[Str]',
	clearer   => 'clear_alt_ids',
	predicate => 'has_alt_ids'
);

1;
