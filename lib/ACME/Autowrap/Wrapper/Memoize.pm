package ACME::Autowrap::Wrapper::Memoize;

use Memoize;
use Role::Tiny::With;
with 'ACME::Autowrap::Wrapper';

sub wrap{
  my $self=shift;
  memoize($_[0])
}

sub new {
  my $package = shift;
  return bless({},$package);
}

1;
