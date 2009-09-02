use Test::More tests => 1;
use FindBin;
use lib "$FindBin::Bin";

BEGIN {
use_ok(
    'Ark::Plugin::Authentication::Store::DBIx::Skinny'
);
}
