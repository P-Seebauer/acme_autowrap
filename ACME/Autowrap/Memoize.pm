package ACME::Autowrap::Memoize;
use Memoize;

sub is_run_time_wrap{$_[0]->{run_time_wrap}}
sub wrap{memoize $_[1]}
sub new {
  my($package) = shift;
  my $self = {run_time_wrap=>0};
  return bless($self,$package);
}

1;
