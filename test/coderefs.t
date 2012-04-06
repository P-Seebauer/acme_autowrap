use Test::More tests => 3;

use ACME::Autowrap (sub{$_[0]=~/one$/} => sub{1},
		    \&sub_two          => sub{$_[0]->()/2});

sub sub_two{
  $_[0]=~/^two/;
}

sub nice_one{3}
sub two_one{8}
sub two_nice{4}

is (nice_one , 1, "supplying anonymous sub");
is (nicer_two, 2, "supplying named sub");
is (two_one, 0.5, "two subroutines applied on the same sub");
