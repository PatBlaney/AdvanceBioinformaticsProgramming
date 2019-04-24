#!/usr/bin/perl
use strict;
use warnings;
use DiffExp;

# Based on predefined test data, 120 successess are expected
use Test::More tests => 120;

# Read in test data line by line
while (<DATA>) {
	chomp;
	
	# Instantiate a new BLAST object and set the attributes for testing
	my $diff_exp = DiffExp->new( diff_exp_line => $_ );
	
	# Check on various properties of set attributes for test data
	ok(defined $diff_exp->get_transcript());
	like($diff_exp->get_transcript(), '/\w+/');
	
	ok(defined $diff_exp->get_sp_ds());
	like($diff_exp->get_sp_ds(), '/\d.+\d/');
	
	ok(defined $diff_exp->get_sp_hs());
	like($diff_exp->get_sp_hs(), '/\d.+\d/');
	
	ok(defined $diff_exp->get_sp_log());
	like($diff_exp->get_sp_log(), '/\d.+\d/');
	
	ok(defined $diff_exp->get_sp_plat());
	like($diff_exp->get_sp_plat(), '/\d.+\d/');
}

__END__
c3833_g1_i2     4.00    0.07    16.84   26.37
c5834_g1_i1     925.70  1760.39 114.18  264.24
c5152_g1_i1     487.70  2200.08 1634.91 153.48
c4438_g1_i2     4.15    8.64    5.25    78.37
c1541_g1_i1     82.55   6.20    1.10    407.14
c14_g1_i2       2.36    5.25    0.00    185.25
c3710_g1_i1     8.79    6.45    331.50  3.12
c5084_g1_i1     462.23  170.65  82.65   1343.03
c2268_g1_i2     12.43   11.87   3.23    77.00
c5038_g1_i1     835.97  6594.79 178.12  1313.01
c5928_g1_i1     8785.03 11720.86        291.58  17505.61
c2086_g1_i2     8.17    0.00    17.47   15.98
