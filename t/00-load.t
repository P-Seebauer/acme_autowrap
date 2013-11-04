#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'ACME::Autowrap' ) || print "Bail out!\n";
}

diag( "Testing ACME::Autowrap $ACME::Autowrap::VERSION, Perl $], $^X" );
