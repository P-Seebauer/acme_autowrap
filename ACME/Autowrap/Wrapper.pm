package ACME::Autowrap::Wrapper;

=head1 ACME::Autowrap::Wrapper;

=head2 Synopsis
   This is just a role module for a Autowrap::Wrapper.

=cut
BEGIN{
   eval <<YADA_CODE if $^V>=5.11.0
   sub is_runtime_wrapper {...};
   sub wrap{...};
YADA_CODE
  }

sub is_runtime_wrapper{1};
sub wrap;


1;
