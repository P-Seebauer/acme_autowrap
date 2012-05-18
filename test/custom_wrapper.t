package myOwnWrapper;

sub new{my $foo={};bless $foo, shift}
sub wrap{
  shift;
  my $old = shift;
  "<b>".$old->(@_)."</b>"
}

sub is_run_time_wrap{1};
package main;
use Test::More tests => 2;

use 5.01;

BEGIN {
  use_ok(ACME::Autowrap, qr/mine/ => myOwnWrapper->new());
}

sub mine()    {"yay"}
say myOwnWrapper->new;
is(mine, '<b>yay</b>', 'wrapping with custom wrapper');
