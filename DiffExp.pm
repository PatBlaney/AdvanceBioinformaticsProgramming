package DiffExp;
use Moose;
use feature 'say';
use MooseX::FollowPBP;

# Use BUILD consturctor to instantiate an object and set attributes
# at same time
sub BUILD {

	# Accept key-value hash reference as parameter then dereference it
	my ( $self, $args ) = @_;
	my $diff_exp_line = $args->{diff_exp_line};

	# Regex to isolate the transcript ID and expression data
	# points: Sp_ds, Sp_hs, Sp_log, and Sp_plat
	my $parsing_regex =
	  qr/(?<transcript_id>^\S+)\s*(?<expression_data>\d.*\d)/x;

	# If differential expression data line can be parsed, set all
	# attributes for each DiffExp object
	if ( $diff_exp_line =~ /$parsing_regex/ ) {

		$self->{transcript} = $+{transcript_id};

		my @expression_data = split('\s+', $+{expression_data});
		$self->{sp_ds}   = $expression_data[0];
		$self->{sp_hs}   = $expression_data[1];
		$self->{sp_log}  = $expression_data[2];
		$self->{sp_plat} = $expression_data[3];
	}
}

has 'transcript' => (
	is        => 'ro',
	isa       => 'Str',
	clearer   => 'clear_transcript',
	predicate => 'has_transcript'
);

has 'sp_ds' => (
	is        => 'ro',
	isa       => 'Num',
	clearer   => 'clear_sp_ds',
	predicate => 'has_sp_ds'
);

has 'sp_hs' => (
	is        => 'ro',
	isa       => 'Num',
	clearer   => 'clear_sp_hs',
	predicate => 'has_sp_hs'
);

has 'sp_log' => (
	is        => 'ro',
	isa       => 'Num',
	clearer   => 'clear_sp_log',
	predicate => 'has_sp_log'
);

has 'sp_plat' => (
	is        => 'ro',
	isa       => 'Num',
	clearer   => 'clear_sp_plat',
	predicate => 'has_sp_plat'
);

1;
