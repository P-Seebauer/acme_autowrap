use Test::More tests => 5;
# use_ok doesn't seem to work when using B::Hooks::EndOfScope

use ACME::Autowrap (qr/^regex/          => sub {my $old = shift; $old->(@_) . "regex"},
		    sub{$_[0] =~ /sub/} => sub {my $old = shift; $old->(@_) . "sub"},
		    -exclude            => [qw[regex_sub_excluded]],
		   );

sub regex_modified    {$_[0]}
sub sub_modified      {$_[0]}
sub regex_sub_modified{$_[0]}
sub not_modified      {$_[0]}
sub regex_sub_excluded{$_[0]}

is(not_modified('a'),       'a',        "not matching regex");
is(regex_modified('a'),     'aregex',   "matching regex");
is(sub_modified('a'),       'asub',     "matching sub");
is(regex_sub_modified('a'), 'aregexsub',"matching sub and regex (in right order)");
is(regex_sub_excluded('a'), 'a',        "excluded, but matching regex" );
