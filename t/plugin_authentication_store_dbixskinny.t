use Test::Base;
use File::Temp;

eval "use DBI; use DBIx::Skinny";
plan skip_all => 'DBIx::Skinny required to run this test' if $@;

my $dbname = "testdatabase";
END { unlink $dbname }

{
    # create Database
    my $dbnameh = DBI->connect("dbi:SQLite:$dbname")
        or die DBI->errstr;

    $dbnameh->do(<<'...');
CREATE TABLE users (
    id INTEGER NOT NULL PRIMARY KEY,
    name     TEXT NOT NULL,
    password TEXT NOT NULL
);
...

    $dbnameh->do("INSERT INTO users (name, password) values ('user1', 'pass1');");
    $dbnameh->do("INSERT INTO users (name, password) values ('user2', 'pass2');");
}

{
    package T1::Skinny;
    use DBIx::Skinny setup => +{
        dsn      => "dbi:SQLite:testdatabase",
        name     => '',
        password => '',
    };

    package T1::Skinny::Schema;
    use DBIx::Skinny::Schema;
    install_table users => schema {
        pk 'name';
        columns qw/name password/;
    };
}

{
    package T1;
    use Ark;

    use_plugins qw/
        Session
        Session::State::Cookie
        Session::Store::Memory

        Authentication
        Authentication::Credential::Password
        Authentication::Store::DBIx::Skinny
        /;

    package T1::Model::Skinny;
    use Ark 'Model::Adaptor';

    __PACKAGE__->config(
        class => 'T1::Skinny',
    );

    package T1::Controller::Root;
    use Ark 'Controller';

    has '+namespace' => default => '';

    sub index :Path {
        my ($self, $c) = @_;

        if ($c->user && $c->user->authenticated) {
            $c->res->body( 'logged in: ' . $c->user->obj->name );
        } else {
            $c->res->body( 'require login' );
        }
    }

    sub login :Local {
        my ($self, $c) = @_;
        my $user = $c->authenticate({ username => 'user1', password => 'pass1' });
        $c->res->body( $user ? 'login succeeded' : 'login failed' );
    }

    sub login_fail :Local {
        my ($self, $c) = @_;
        my $user = $c->authenticate({ username => 'user', password => 'password' });
        $c->res->body( $user ? 'login succeeded' : 'login failed' );
    }
}

plan tests => 4;

use Ark::Test 'T1',
    components => [qw/Controller::Root
                      Model::Skinny
                     /],
    reuse_connection => 1;


is(get('/'), 'require login', 'not login ok');
is(get('/login_fail'), 'login failed', 'login failed ok');
is(get('/login'), 'login succeeded', 'login ok');
is(get('/'), 'logged in: user1', 'logged in ok');
