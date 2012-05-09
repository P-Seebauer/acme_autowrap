package ACME::Autowrap::Wrapper;

=head1 ACME::Autowrap::Wrapper;

=head2 Synopsis
   This is just a role module for a Autowrap::Wrapper.

=cut

sub is_runtime_wrapper{1};
sub wrap;

BEGIN{
  # insert the wrap-method with a ... operator
   eval <<YADA_CODE if $^V>=5.11.0
   sub wrap{...};
YADA_CODE
  }



1;
