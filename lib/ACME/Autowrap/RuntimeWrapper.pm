package ACME::Autowrap::RuntimeWrapper;

use Role::Tiny;
use true;
with 'ACME::Autowrap::Wrapper';

sub wrap{
  my ($s,$name,$old) = @_;
  no strict 'refs';
  no warnings 'redefine';
  *{$name}=sub {$s->wrap_runtime($old, @_)};
}
