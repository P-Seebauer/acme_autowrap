package ACME::Autowrap::DefaultWrapper;

use true;
use Role::Tiny::With;
with 'ACME::Autowrap::RuntimeWrapper';

sub new {
  my($package) = shift;
  my $self = shift;
  return bless($self,$package);
}

sub wrap_runtime {
  my ($s, $old) = shift;
  $s->(@_);
}
