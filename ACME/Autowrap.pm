package ACME::Autowrap;

=head1 ACME::Autowrap;

=head2 Synopsis
   use this package to have your subroutines autowrapped

=cut

use 5.01;
use strict;
use warnings;
use Carp qw (croak carp);

my %packages;
my $DEBUG = $ENV{DEBUG};

sub DEBUG(&){
  $_[0]->() if $DEBUG;
}

sub import{
  shift; # remove the package name from argument list
  carp <<ERR if @_ % 2;
Odd number of arguments to ACME::Autowrap supplied - last one will be ignored
ERR
  my @subs;
  for(my $i=0;$i<@_;$i+=2){
    my ($filter,$wrapper)=@_[$i,$i+1];
    my ($f_sub, $w_sub);
    given (ref $filter){
      when ('CODE')  {$f_sub=$filter}
      when ('Regexp'){$f_sub=sub{$_[0]=~$filter}}
    }
    croak "Didn't know what to do with your filter `$filter'" unless defined $f_sub;

    $w_sub=$wrapper if ref $wrapper eq 'CODE';
    croak "Didn't know what to do with your filter `$filter'" unless defined $w_sub;
    push @subs,$f_sub, $w_sub;
  }
  $packages{(caller) [0]}= \@subs;
}

sub _make_cref {
  no strict 'refs';
  return scalar *{$_[0]}{CODE};
}

INIT {
  DEBUG{local $,=' ';
	print "$_ \t|", @{$packages{$_}},"\n" foreach keys %packages
      };
  my %functions;
  while (my ($_,$arg) = each %packages){
    no strict 'refs';
    while(my ($key,$val) = each %{*{"$_\::"}}){
      # iterate over the symboltable of that package
      local *ENTRY = $val;
      if (defined $val and defined *ENTRY{CODE}){
	for(my $i=0;$i<@$arg;$i+=2){
	  if($arg[0]->($key)){
	    $oldsub = _make_cref("$_\::$key");
	    
	  }
	}
      }
    }
  }
}



"oh yeah, that's a nice package";
