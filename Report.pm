package Report;
use Moose;
use feature 'say';
use MooseX::FollowPBP;
use DiffExp;

# Open file to write report to
open( REPORT, '>', 'final_report.txt' ) or die $!;

# Use BUILD consturctor to instantiate an object and set attributes
# at same time
sub BUILD {

	# Accept key-value hash reference as parameter then dereference it
	my ( $self, $args ) = @_;
	my $diff_exp     = $args->{diff_exp};
	my $protein_id   = $args->{protein_id};
	my $protein_desc = $args->{protein_desc};
	my $GO_terms     = $args->{GO_terms};

	# Set each attribute if it is defined
	if ( defined $diff_exp ) {

		$self->{diff_expressions} = $diff_exp;
	}
	if ( defined $protein_id ) {

		$self->{protein_id} = $protein_id;
	}
	if ( defined $protein_desc ) {

		$self->{protein_desc} = $protein_desc;
	}
	if ( defined $GO_terms ) {

		$self->{GO_terms} = $GO_terms;
	}
}

# Prints information for each transcript to report
sub print_all {

	my ($self) = @_;

	my $diff_exp_obj = $self->get_diff_expressions();
	my $protein_id   = $self->get_protein_id();
	my $protein_desc = $self->get_protein_desc();
	my $GO_terms     = $self->get_GO_terms();

	# Initlaize counter to identify the beginning of new set of GO terms
	my $go_id_counter = 0;

	# Cyle through array of all GO objects associated with each transcript
	foreach my $go_obj ( @{$GO_terms} ) {

		# Increment the counter after each GO ID
		$go_id_counter++;

		# If first GO ID and valid GO object, print report line entry in tab separated format
		if ( $go_id_counter == 1 && $go_obj ne 'NA' ) {

			say REPORT join( "\t",
				$diff_exp_obj->get_transcript(), $diff_exp_obj->get_sp_ds(),
				$diff_exp_obj->get_sp_hs(),      $diff_exp_obj->get_sp_log(),
				$diff_exp_obj->get_sp_plat(),    $protein_id,
				$go_obj->get_id(),               $go_obj->get_name(),
				$protein_desc );
		}
		elsif ( $go_obj ne 'NA' ) {

			# Print rest of GO IDs with linked GO name after first line
			say REPORT "\t" x 6, $go_obj->get_id(), "\t", $go_obj->get_name();
		}
	}
}

has 'diff_expressions' => (
	is        => 'ro',
	isa       => 'DiffExp',
	clearer   => 'clear_diff_expressions',
	predicate => 'has_diff_expressions'
);

has 'protein_id' => (
	is        => 'ro',
	isa       => 'Str',
	clearer   => 'clear_protein_id',
	predicate => 'has_protein_id'
);

has 'protein_desc' => (
	is        => 'ro',
	isa       => 'Str',
	clearer   => 'clear_protein_desc',
	predicate => 'has_protein_desc'
);

has 'GO_terms' => (
	is        => 'ro',
	isa       => 'ArrayRef',
	clearer   => 'clear_GO_terms',
	predicate => 'has_GO_terms'
);

1;
