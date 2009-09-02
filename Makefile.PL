use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Ark::Plugin::Authentication::Store::DBIx::Skinny',
    AUTHOR              => 'Ryo Miyake <ryo.studiom@gmail.com>',
    VERSION_FROM        => 'lib/Ark/Plugin/Authentication/Store/DBIx/Skinny.pm',
    ABSTRACT_FROM       => 'lib/Ark/Plugin/Authentication/Store/DBIx/Skinny.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'version'    => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Ark-Plugin-Authentication-Store-DBIx-Skinny-*' },
);
