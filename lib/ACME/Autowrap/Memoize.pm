package ACME::Autowrap::Memoize;

use base ACME::Autowrap::Wrapper;
use Memoize;

sub is_run_time_wrap{0}
sub wrap{
  my $self=shift;
  memoize($_[1], @$self)
}
sub new {
  my $package = shift;
  my $self = [@_];
  return bless($self,$package);
}

1;
