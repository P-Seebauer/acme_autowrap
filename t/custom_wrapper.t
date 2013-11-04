package myOwnWrapper;

sub new{my $foo={};bless $foo, shift}
sub wrap{
  shift;
  my $old = shift;
  "<b>".$old->(@_)."</b>"
}

sub is_run_time_wrap{1};
package main;
use Test::More tests => 3;

use 5.01;

BEGIN {
  use_ok(ACME::Autowrap, qr/mine/ => myOwnWrapper->new());
}

sub mine    {"yay"}
is(mine(), '<b>yay</b>', 'wrapping with custom wrapper');

TODO:{
  local $TODO = "Inlining constant subs not implemented";
  sub mines (){"noo"}
  is(mines, '<b>nooo</b>', 'wrapping with custom wrapper that is inlined');
}
