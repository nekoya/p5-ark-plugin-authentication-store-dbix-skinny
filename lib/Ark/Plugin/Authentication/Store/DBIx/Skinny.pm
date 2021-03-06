package Ark::Plugin::Authentication::Store::DBIx::Skinny;
use Ark::Plugin 'Auth';

our $VERSION = '0.1.0';

has dbix_skinny_model => (
    is      => 'rw',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my $self = shift;
        $self->class_config->{model} || 'Skinny';
    },
);

has dbix_skinny_table_name => (
    is      => 'rw',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my $self = shift;
        $self->class_config->{table} || 'users';
    },
);

has dbix_skinny_user_field => (
    is      => 'rw',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my $self = shift;
        $self->class_config->{user_field} || 'name';
    },
);

around find_user => sub {
    my $prev = shift->(@_);
    return $prev if $prev;

    my ($self, $id, $info) = @_;
    my $model = $self->app->model( $self->dbix_skinny_model );
    my $user;
    if ($model->can('find_user')) {
        $user = $model->find_user($id, $info);
    }
    else {
        $user = $model->single(
            $self->dbix_skinny_table_name,
            { $self->dbix_skinny_user_field => $id }
        );
    }

    if ($user) {
        $self->ensure_class_loaded('Ark::Plugin::Authentication::User');
        return Ark::Plugin::Authentication::User->new(
            store => 'DBIx::Skinny',
            obj   => $user,
            hash  => $user->get_columns,
        );
    }
    return;
};

around 'from_session' => sub {
    my $prev = shift->(@_);
    return $prev if $prev;

    my ($self, $user) = @_;

    return unless $user->{store} eq 'DBIx::Skinny';

    $self->ensure_class_loaded('Ark::Plugin::Authentication::User');

    Ark::Plugin::Authentication::User->new(
        store       => 'DBIx::Skinny',
        hash        => $user->{hash},
        obj_builder => sub {
            my $model = $self->app->model( $self->dbix_skinny_model );
            $model->single(
                $self->dbix_skinny_table_name,
                {
                    $self->dbix_skinny_user_field =>
                    $user->{hash}{ $self->dbix_skinny_user_field }
                }
            );
        },
    );
};

1;

__END__

=head1 NAME

Ark::Plugin::Authentication::Store::DBIx::Skinny

=head1 SYNOPSIS

1. add the plugin to 'use_plugins' list for your app.

use_plugins qw{
...
Authentication::Store::DBIx::Skinny
};

2. write configurations of plugin, default as

__PACKAGE__->config(
    'Plugin::Authentication::Store::DBIx::Skinny' => {
        model      => 'Skinny',
        table      => 'users',
        user_field => 'name',
    }
);

=head1 DESCRIPTION

Authentication plugin for Ark with DBIx::Skinny

Ark - web application framework like Catalyst - http://github.com/typester/ark-perl/tree/master

=head1 SEE ALSO

L<DBIx::Skinny>

=head1 AUTHOR

Ryo Miyake  C<< <ryo.studiom __at__ gmail.com> >>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
