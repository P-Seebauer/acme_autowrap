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
  my $$self = '';
  return bless($self,$package);
}

1;
