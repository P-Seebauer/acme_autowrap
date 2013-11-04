use Test::More tests => 6;

use 5.01;

BEGIN {
  use_ok(ACME::Autowrap::Memoize);

  use_ok(ACME::Autowrap,
    sub {$_[0] !~ /no$/ and $_[0] =~ /mem/} => ACME::Autowrap::Memoize->new());
}

sub mem()    {state $foo; $foo++}
sub no_mem() {state $foo; $foo++}

is(mem,    0, '1st call to memoized sub works');
is(mem,    0, '2nd call to memoized sub returns same value');
is(no_mem, 0, '1st call to not memoized sub works');
is(no_mem, 1, '2nd call to not memoized sub returns other value');