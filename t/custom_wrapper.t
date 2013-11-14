use Moops;

class ::littleRuntimeWrapper{
  with 'ACME::Autowrap::RuntimeWrapper';

  method wrap_runtime{
    my $old = shift;
    "<b>".$old->(@_)."</b>"
  }
}

  class ::littleCompileTimeWrapper {
    with 'ACME::Autowrap::Wrapper';
    method wrap{
      my ($name,$old) = @_;
      no strict 'refs';
      no warnings 'redefine';
      *{$name}=sub {"called: ".$old->(@_)};
    }
}

use Test::More tests => 4;
use 5.01;

use ACME::Autowrap (runtime      => littleRuntimeWrapper->new,
		    runtime_n    => 'littleRuntimeWrapper',
		    compiletime  => littleCompileTimeWrapper->new,
		    compiletime_n=> 'littleCompileTimeWrapper',
		   );

sub runtime       {$_[0]}
sub runtime_n     {$_[0]}
sub compiletime   {$_[0]}
sub compiletime_n {$_[0]}

is (runtime       ("one"),'<b>one</b>','runtime wrapper object');
is (runtime_n     ("one"),'<b>one</b>','runtime wrapper name');
is (compiletime   ("one"),'called: one','compile wrapper object');
is (compiletime_n ("one"),'called: one','compile wrapper name');
