use 5.006;
use strict;
use warnings FATAL => 'all';
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'ACME::Autowrap',
    license             => 'Artistic_2_0',
    dist_author         => q{Patrick Seebauer <patpatpat@cpan.org>},
    dist_version_from   => 'lib/ACME/Autowrap.pm',
    release_status      => 'stable',
    configure_requires => {
        'Module::Build' => 0,
    },
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
		 Carp => 1.22,
		 true => 0.16,
    },
    add_to_cleanup     => [ 'ACME-Autowrap-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
