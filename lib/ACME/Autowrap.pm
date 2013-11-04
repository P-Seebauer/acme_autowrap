package ACME::Autowrap;
# Abstract: Automatically wrap subroutienes

use 5.01;
use strict;
use warnings;
use true;
use Carp qw (croak carp);


=head1 NAME

ACME::Autowrap

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


#use Module::Runtime qw(require_module);


my (%packages, @all_replaced_subs);
my $DEBUG;

BEGIN {$DEBUG = defined $ENV{ DEBUG } and $ENV{ DEBUG } eq 'AUTOWRAP';}
sub DEBUG($) {
  carp($_[0]) if $DEBUG;
}

sub replace_subroutine (&$$) {
  no strict 'refs';
  no warnings 'redefine';
  my $obj->{qw|new name old|} = @_;
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
    if (ref $filter eq 'CODE') {
      $f_sub = $filter
    } elsif (ref $filter eq 'Regexp') {
      $f_sub = sub {$_[0] =~ $filter}
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
		replace_subroutine{$wrapper->($oldsub, @_)}     $full_name, $oldsub;
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

__END__


=head1 SYNOPSIS

  use ACME::Autowrap (qr/aref$/ => sub{my $old=shift; [$old->(@_)]},
                      sub{15 < length $_[0]} => sub{(shift)->(@_).'long subname'});

  sub aref_sub{ 
    return qw/one two three/;
  }# returns that in an Array reference.

  sub very_long_subroutine_name{ 
    return 'this is a ';
  }#returns "this is a long subname".


=head1 BUGS

=over 4

=item C<no ACME::Autowrap> doesn't work

=item Prototypes aren't supported 

=item There might be a problem with wrapping constant subroutines (those with empty prototypes)


=back

Please report any bugs or feature requests to L<https://github.com/P-Seebauer/acme_autowrap>.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ACME::Autowrap


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=ACME-Autowrap>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/ACME-Autowrap>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/ACME-Autowrap>

=item * Search CPAN

L<http://search.cpan.org/dist/ACME-Autowrap/>

=back


=head1 LICENSE AND COPYRIGHT

Copyright 2013 Patrick Seebauer.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut




=head2 COPYRIGHT

Copyright (C) 2012 by Patrick Seebauer

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut

=head1 AUTHOR

Patrick Seebauer, C<< <patpatpat at cpan.org> >>

=cut
