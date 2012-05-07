package ACME::Autowrap;

=head1 ACME::Autowrap;

=head2 Synopsis
   use this package to have your subroutines autowrapped

=cut

use 5.01;
use strict;
use warnings;
use Carp qw (croak carp);
use Module::Runtime qw(require_module);

my %packages;
my $DEBUG = $ENV{ DEBUG };

sub DEBUG($) {
  carp($_[0]) if $DEBUG;
}

sub import {
  shift;    # remove the package name from argument list
  carp <<ERR if @_ % 2;
Odd number of arguments to ACME::Autowrap supplied - last one will be ignored
ERR
  my @subs;
  for (my $i = 0 ; $i < @_ ; $i+=2) {
    my ($filter, $wrapper) = @_[$i, $i + 1];
    my ($f_sub, $w_sub);
    given (ref $filter) {
      when ('CODE') {$f_sub = $filter}
      when ('Regexp') {
        $f_sub = sub {$_[0] =~ $filter}
      }
    }
    croak "Didn't know what to do with your filter `$filter'"
      unless defined $f_sub;

    if (ref $wrapper eq 'CODE') {
      $w_sub = ACME::Autowrap::Wrapper->new($wrapper);
    } elsif (ref $wrapper eq '') {
      require_module "ACME::Autowrap::${wrapper}";
      $w_sub = "ACME::Autowrap::${wrapper}"->new();
    }
    croak "Didn't know what to do with your wrapper `$wrapper'"
      unless defined $w_sub;
    push @subs, $f_sub, $w_sub;
  } ## end for (my $i = 0 ; $i < @_...)
  $packages{ (caller)[0] } = \@subs;
} ## end sub import

INIT {
  my %functions;
  while (my ($package, $arg) = each %packages) {
    no strict 'refs';
    while (my ($key, $val) = each %{ *{ "$package\::" } }) {

      # iterate over the symboltable of that package
      local *ENTRY = $val;
      if (defined $val and defined *ENTRY{ CODE }) {

        # we found a subroutine
        my $full_name = "$package\::$key";
        for (my $i = 0 ; $i < @$arg ; $i+=2) {
          my ($filter, $wrapper) = ($arg->[$i], $arg->[$i + 1]);
          if ($filter->($key)) {
            my $oldsub = *{ $full_name }{ CODE };
            if ($wrapper->is_run_time_wrap) {
              local ($^W);    # redefined subroutine...
              no warnings;
              *{ $full_name } = sub {$wrapper->wrap($oldsub, @_)};
            } else {
              $wrapper->wrap($full_name, $val, $oldsub);
            }
          }
        }
      }
    } ## end while (my ($key, $val) = ...)
  } ## end while (my ($package, $arg...))
} ## end INIT

package ACME::Autowrap::Wrapper;
sub is_run_time_wrap {1}
sub new              {bless $_[1], $_[0]}
sub wrap             {(shift)->(@_)}

"oh yeah, that's a nice package";
