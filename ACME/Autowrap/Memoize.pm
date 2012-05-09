package ACME::Autowrap::Memoize;

use base ACME::Autowrap::Wrapper;
use Memoize;

sub is_run_time_wrap{0}
sub wrap{memoize $_[1]}
sub new {
  my($package, $self) = (shift,{});
  return bless($self,$package);
}

1;
