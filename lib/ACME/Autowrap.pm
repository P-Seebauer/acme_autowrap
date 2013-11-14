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

our $VERSION = 0.002;

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


=head1 SYNOPSIS

  use ACME::Autowrap (qr/^aref/ => sub{my $old=shift; [$old->(@_)]},
                      sub{15 < length $_[0]} => sub{(shift)->(@_).'long subname'},
                      -exclude => 'aref_excluded');

  sub aref_sub{
    return qw/one two three/;
  }# returns that in an Array reference.

  sub very_long_subroutine_name{ 
    return 'this is a ';
  }#returns "this is a long subname".

  sub aref_excluded{
    return qw|this result won't be altered|
  }

=head1 DESCRIPTION

This module simply wraps your subroutines into whatever you supply to them. 
The syntax for the C<use>-directive:

   use Acme::Autowrap (I<Filter> => I<Wrapper>);

If an subroutine name matches to I<Filter> as if L<match::simple::match|match::simple/"DESCRIPTION"> would have been applied,
one of the following things happen (in that order):

=for :list
* If it is a code reference, the code reference will be called, with your subroutine as first argument
* If it is an object that does the role ACME::Autowrap::Wrapper it will be used as a wrapper and the C<wrap>-method of that role will be applied to your subroutine
* If it is a package name of a package that does that role, a new object will be created with a I<new> method with no arguments in the constructor.


To write your own wrappers, I recommend you to use the L<ACME::Autowrap::RuntimeWrapper|ACME::Autowrap::RuntimeWrapper> role. If you want to write your own wrapping procedure, use the role L<ACME::Autowrap::RuntimeWrapper|ACME::Autowrap::RuntimeWrapper>.

If your C<filter> is the string C<-exclude>, the filter will be used as an argument to an C<match::simple::match>. If this match succeds for any subroutine, it won't be wrapped.


=head1 BUGS

=for :list
* C<no ACME::Autowrap> doesn't work
* Prototypes aren't supported 
* There might be a problem with wrapping constant subroutines (those with empty prototypes)
* Oh yeah, and if warnings that your symbol table isn't numeric bother you ... don't use filters that are numeric, what are you trying to do anyway?


