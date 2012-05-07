use Test::More tests => 3;
use 5.01;

use ACME::Autowrap
  (sub{$_[0]=~/one$/} => sub{my $old = shift;$old->(@_)."one"},
   \&sub_two          => sub{my $old = shift;$old->(@_)."two"});

sub sub_two{$_[0]=~/^two/;}

sub nice_one{$_[0]}
sub two_nice{$_[0]}
sub two_one{ $_[0]}

is (nice_one('a'), 'aone'   , "supplying anonymous sub");
is (two_nice('b'), 'btwo'   , "supplying named sub");
is (two_one( 'c'), 'conetwo', "two subroutines applied on the same sub");
