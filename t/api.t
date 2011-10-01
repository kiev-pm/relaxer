#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 6;

use Plack::Response;
use Plack::Test;

use HTTP::Request::Common qw(GET POST);
use JSON;

use_ok 'Relaxer::API';

my $api = new_ok 'Relaxer::API';

my $app = $api->to_psgi_app;

subtest 'render_json' => sub {
    my $res = Plack::Response->new(@{$api->render_json({foo => 'bar'})});

    is $res->status, 200;
    is $res->headers->header('Content-Type'), 'application/json';
    is_deeply decode_json($res->body->[0]), {foo => 'bar'};
};


subtest '/wrong_url' => sub {
    test_psgi $app, sub {

        my $cb  = shift;
        my $res = $cb->(GET '/wrong_url');
        is $res->code, 404;
      }
};

subtest '/api/execute wrong arguments' => sub {
    test_psgi $app, sub {
        my $cb = shift;

        my $res = $cb->(POST '/api/execute', Content => encode_json {});
        is $res->code, 200;

        my $data = decode_json $res->content;
        ok !$data->{status};
      }
};

subtest '/api/execute right arguments' => sub {
    test_psgi $app, sub {
        my $cb = shift;

        my $res = $cb->(
            POST '/api/execute',
            Content =>
              encode_json {text => 'test', match => 'test', flags => {}}
        );

        is $res->code, 200;

        my $data = decode_json $res->content;
        ok $data->{status};
        ok $data->{results}->[0]->{found};
      }
};
