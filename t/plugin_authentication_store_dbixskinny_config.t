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
CREATE TABLE members (
    id INTEGER NOT NULL PRIMARY KEY,
    membername TEXT NOT NULL,
    password   TEXT NOT NULL
);
...

    $dbnameh->do("INSERT INTO members (membername, password) values ('member1', 'pass1');");
    $dbnameh->do("INSERT INTO members (membername, password) values ('member2', 'pass2');");
}

{
    package T1::DB;
    use DBIx::Skinny setup => +{
        dsn      => "dbi:SQLite:testdatabase",
        name     => '',
        password => '',
    };

    package T1::DB::Schema;
    use DBIx::Skinny::Schema;
    install_table members => schema {
        pk 'membername';
        columns qw/membername password/;
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

    __PACKAGE__->config(
        'Plugin::Authentication::Store::DBIx::Skinny' => {
            model      => 'DB',
            table      => 'members',
            user_field => 'membername',
        }
    );

    package T1::Model::DB;
    use Ark 'Model::Adaptor';

    __PACKAGE__->config(
        class => 'T1::DB',
    );

    package T1::Controller::Root;
    use Ark 'Controller';

    __PACKAGE__->config->{namespace} = '';

    sub index :Path {
        my ($self, $c) = @_;

        if ($c->user && $c->user->authenticated) {
            $c->res->body( 'logged in: ' . $c->user->obj->membername );
        } else {
            $c->res->body( 'require login' );
        }
    }

    sub login :Local {
        my ($self, $c) = @_;
        my $user = $c->authenticate({ username => 'member1', password => 'pass1' });
        $c->res->body( $user ? 'login succeeded' : 'login failed' );
    }

    sub login_fail :Local {
        my ($self, $c) = @_;
        my $user = $c->authenticate({ username => 'member', password => 'password' });
        $c->res->body( $user ? 'login succeeded' : 'login failed' );
    }
}

plan 'no_plan';

use Ark::Test 'T1',
    components => [qw/Controller::Root
                      Model::DB
                     /],
    reuse_connection => 1;


is(get('/'), 'require login', 'not login ok');
is(get('/login_fail'), 'login failed', 'login failed ok');
is(get('/login'), 'login succeeded', 'login ok');
is(get('/'), 'logged in: member1', 'logged in ok');
