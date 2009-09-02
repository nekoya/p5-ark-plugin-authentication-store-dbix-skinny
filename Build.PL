use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Ark::Plugin::Authentication::Store::DBIx::Skinny',
    license             => 'perl',
    dist_author         => 'Ryo Miyake <ryo.studiom@gmail.com>',
    dist_version_from   => 'lib/Ark/Plugin/Authentication/Store/DBIx/Skinny.pm',
    requires => {
        'Test::More' => 0,
        'version'    => 0,
    },
    add_to_cleanup      => [ 'Ark-Plugin-Authentication-Store-DBIx-Skinny-*' ],
);

$builder->create_build_script();
