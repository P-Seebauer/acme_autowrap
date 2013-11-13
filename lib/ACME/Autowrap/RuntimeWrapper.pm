package RuntimeWrapper;
use true;

use Role::Tiny;
with 'ACME::Autowrap::Wrapper';
requires qw"wrap_runtime";

sub wrap{
  my ($s,$name,$old) = @_;
  no strict 'refs';
  no warnings 'redefine';
  *{$name}=sub {$s->wrap_runtime($old,$name)};
}

