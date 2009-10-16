use inc::Module::Install;
name 'Ark-Plugin-Authentication-Store-DBIx-Skinny';
all_from 'lib/Ark/Plugin/Authentication/Store/DBIx/Skinny.pm';

requires 'Ark';
requires 'DBIx::Skinny';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
