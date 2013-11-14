package ACME::Autowrap;
# ABSTRACT: Automatically wrap subroutines
use strict;
use warnings;
use true;
#use Devel::Pragma ':all';
use B::Hooks::EndOfScope;
use match::smart 'match';
use Scalar::Util 1.02 'blessed';

use Carp qw|carp croak|;

our $VERSION = 0.001;

sub unimport{$^H{+__PACKAGE__}=0}
sub import {
  my $p = shift;
  carp <<ERR if @_ % 2;
Odd number of arguments to ACME::Autowrap supplied - last one will be ignored
ERR
  my (@excluded, %packages);
  for (my $i = 0 ; $i < @_ ; $i+=2) {
    my ($filter, $wrapper) = @_[$i, $i + 1];
    my ($w_sub);
    if ($filter eq '-exclude'){
      push @excluded, $wrapper;
      next;
    }

    if (ref $wrapper eq 'CODE') {
      use ACME::Autowrap::DefaultWrapper;
      $w_sub = ACME::Autowrap::DefaultWrapper->new($wrapper);
    } elsif($wrapper->does('ACME::Autowrap::Wrapper')) {
      $w_sub = blessed $wrapper ? $wrapper : $wrapper->new;
    }# elsif ((my $w_name = "ACME::Autowrap::Wrapper::$wrapper")->does('ACME::Autowrap::Wrapper')) {
     # $w_sub = $w_name->new;
    #}

    unless (defined $w_sub) {
      croak "Didn't know what to do with your wrapper `$wrapper', ignoring it";
      next
    }
    push @{$packages{ (caller)[0] }}, $filter, $w_sub;
  }				## end for (my $i = 0 ; $i < @_...)
  
  on_scope_end {
    while (my ($package, $filter_wrappers) = each %packages) {
      no strict 'refs';
      while (my ($symbol_table_key, $val) = each %{ *{ "$package\::" } }) {
	next if grep {match($symbol_table_key ,$_)} @excluded;
	local *ENTRY = $val;
	if (defined $val and defined *ENTRY{ CODE } ) {
	  for (my $i = 0 ; $i < @$filter_wrappers ; $i+=2) {
	    my ($filter, $wrapper) = ($filter_wrappers->[$i], $filter_wrappers->[$i + 1]);
	    if (match($symbol_table_key,$filter)) {
	      my ($full_name) = "$package\::$symbol_table_key";
	      my $oldsub = *{$full_name}{CODE};
	      $wrapper->wrap($full_name, $oldsub);
	    }
	  }
	}
      }
    }
  };
}

    ##  
    ##  # Prototypes don't work yet
    ##  INIT {
    ##    while (my ($package, $filter_wrappers) = each %packages) {
    ##      no strict 'refs';
    ##      while (my ($symbol_table_key, $val) = each %{ *{ "$package\::" } }) {
    ##  
    ##        # iterate over the symboltable
    ##        local *ENTRY = $val;
    ##        if (defined $val and defined *ENTRY{ CODE }) {
    ##          # we found a subroutine
    ##          my $full_name = "$package\::$symbol_table_key";
    ##          for (my $i = 0 ; $i < @$filter_wrappers ; $i+=2) {
    ##            my ($filter, $wrapper) =
    ##              ($filter_wrappers->[$i], $filter_wrappers->[$i + 1]);
    ##            if ($filter->($symbol_table_key)) {
    ##              my $oldsub = *{ $full_name }{ CODE };  # TODO: change that.
    ##  	    my $newsub;
    ##              if (ref $wrapper eq 'CODE') {
    ##  		replace_subroutine{$wrapper->($oldsub, @_)}     $full_name, $oldsub;
    ##              } elsif ($wrapper->is_run_time_wrap) {
    ##                replace_subroutine {$wrapper->wrap($oldsub, @_)} $full_name, $oldsub;
    ##              } else {
    ##                $wrapper->wrap($full_name, $val, $oldsub);
    ##              }
    ##            }
    ##          }
    ##        } ## end if (defined $val and defined...)
    ##      } ## end while (my ($symbol_table_key...))
    ##    } ## end while (my ($package, $filter_wrappers...))
    ##  } ## end INIT

__END__



=head1 NAME

ACME::Autowrap

=head1 VERSION

Version 0.001

=head1 SYNOPSIS

  use ACME::Autowrap (qr/^aref/ => sub{my $old=shift; [$old->(@_)]},
                      sub{15 < length $_[0]} => sub{(shift)->(@_).'long subname'});

  sub aref_sub{
    return qw/one two three/;
  }# returns that in an Array reference.

  sub very_long_subroutine_name{ 
    return 'this is a ';
  }#returns "this is a long subname".


=head1 DESCRIPTION {

This module simply wraps your subroutines into whatever you supply to them. 
The syntax for the C<use>-directive:

   use Acme::Autowrap (<Filter> => <Wrapper>);

If an subroutine name matches to I<Filter> as if L<match::simple/DESCRIPTION|match::simple's smart-match) would have been applied,
one of the following things happen (in that order):

=over 4

=item If it is a code reference, the code reference will be called, with your subroutine as first argument

=item If it is an object that does the role ACME::Autowrap::Wrapper it will be used as a wrapper and the C<wrap>-method of that role will be applied to your subroutine

=item If it is a package name of a package that does that role, a new object will be created with a I<new> method with no arguments in the constructor.


To write your own wrappers, I recommend you to use the L<ACME::Autowrap::RuntimeWrapper|ACME::Autowrap::RuntimeWrapper> role. If you want to write your own wrapping procedure, use the role L<ACME::Autowrap::RuntimeWrapper|ACME::Autowrap::RuntimeWrapper>.
}

=head1 BUGS

=over 4

=item C<no ACME::Autowrap> doesn't work

=item Prototypes aren't supported 

=item There might be a problem with wrapping constant subroutines (those with empty prototypes)

=item Oh yeah, and if warnings that your symbol table isn't numeric bother you ... don't use filters that are numeric, what are you trying to do anyway?


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
