package Relaxer::API;

use warnings;
use strict;
require Carp;

use JSON;
use Plack::Request;
use Routes::Tiny;

use Relaxer::RunRegexp;

sub new {
    my $class = shift;

    my $self = bless {@_}, $class;

    $self->init_routes;

    $self;
}

sub init_routes {
    my $self = shift;

    my $routes = $self->{_routes} = Routes::Tiny->new;

    $routes->add_route('/api/execute',
        defaults => {action => \&_action_regexp_execute});
}

sub to_psgi_app {
    my $self = shift;

    sub { $self->dispatch(@_) };
}

sub dispatch {
    my ($self, $env) = @_;

    my $path = $env->{PATH_INFO};
    if (my $route = $self->{_routes}->match($path)) {
        my $action = $route->{params}{action};

        return $action->($self, $env, $route->{params});
    }

    return [404, ['Content-type' => 'text/plain'], ['Not found']];

}

sub render_json {
    my ($self, $data) = @_;

    [200, ['Content-Type' => 'application/json'], [encode_json $data]];
}

sub _action_regexp_execute {
    my ($self, $env, $params) = @_;

    my $req = Plack::Request->new($env);

    my $regexp_params = decode_json($req->content);

    my $regexp = Relaxer::RunRegexp::run_regexp($regexp_params);

    $self->render_json($regexp);
}

1;

__END__

=head1 NAME

Relaxer::API - [One line description of module's purpose here]


=head1 SYNOPSIS

    use Relaxer::API;


=head1 DESCRIPTION

Relaxer

=head1 ATTRIBUTES

L<Relaxer::API> implements following attributes:

=head1 LICENCE AND COPYRIGHT

Copyright (C) 2011, Kiev.pm.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
