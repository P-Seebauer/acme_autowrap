use Test::More tests => 2;
use 5.01;

use ACME::Autowrap qr/^one/ => sub {my $old = shift; $old->(@_) . "one"};

sub one_modified {$_[0]}
sub not_modified {$_[0]}

is(one_modified('a'), 'aone', "matching regex");
is(not_modified('a'), 'a',    "not matching regex");

