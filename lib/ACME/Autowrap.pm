package ACME::Autowrap;

=head1 ACME::Autowrap;

=head2 Synopsis
   use this package to have your subroutines autowrapped

=cut

use 5.01;
use strict;
use warnings;
use Carp qw (croak carp);
#use Module::Runtime qw(require_module);

use Data::Dumper;


my (%packages, @all_replaced_subs);
my $DEBUG;

BEGIN {$DEBUG = defined $ENV{ DEBUG } and $ENV{ DEBUG } eq 'AUTOWRAP';}
sub DEBUG($) {
  carp($_[0]) if $DEBUG;
}

sub replace_subroutine (&$$) {
  no strict 'refs';
  my $obj->{qw|new name old|} = @_;
  no warnings;
  local ($^W);    # redefined subroutine...
  push @all_replaced_subs, $obj;
  *{$_[1]}=$_[0];
##  *{$obj->{name}} = $obj->{new} # why isn't that working??
}

sub unimport{$^H{+__PACKAGE__}=0}


sub import {
  DEBUG shift;    # remove the package name from argument list
  $^H{+__PACKAGE__}='yay';
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
      $w_sub = $wrapper;
    } else {
      $w_sub = $wrapper;
    }
    croak "Didn't know what to do with your wrapper `$wrapper'"
      unless defined $w_sub;
    push @subs, $f_sub, $w_sub;
  } ## end for (my $i = 0 ; $i < @_...)
  $packages{ (caller)[0] } = \@subs;
} ## end sub import


# Prototypes don't work yet
INIT {
  while (my ($package, $filter_wrappers) = each %packages) {
    no strict 'refs';
    while (my ($symbol_table_key, $val) = each %{ *{ "$package\::" } }) {

      # iterate over the symboltable
      local *ENTRY = $val;
      if (defined $val and defined *ENTRY{ CODE }) {

        # we found a subroutine
        my $full_name = "$package\::$symbol_table_key";
        for (my $i = 0 ; $i < @$filter_wrappers ; $i+=2) {
          my ($filter, $wrapper) =
            ($filter_wrappers->[$i], $filter_wrappers->[$i + 1]);
          if ($filter->($symbol_table_key)) {
            my $oldsub = *{ $full_name }{ CODE };  # TODO: change that.
	    my $newsub;
            if (ref $wrapper eq 'CODE') {
		$wrapper->($oldsub, @_)}     $full_name, $oldsub;
            } elsif ($wrapper->is_run_time_wrap) {
              replace_subroutine {$wrapper->wrap($oldsub, @_)} $full_name, $oldsub;
            } else {
              $wrapper->wrap($full_name, $val, $oldsub);
            }
          }
        }
      } ## end if (defined $val and defined...)
    } ## end while (my ($symbol_table_key...))
  } ## end while (my ($package, $filter_wrappers...))
} ## end INIT

"oh yeah, that's a nice package";


=head2 BUGS
   no ACME::Autowrap doesn't work

=head2 Author
   Patrick Seebauer


=head2 COPYRIGHT

Copyright (C) 2012 by Patrick Seebauer

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
