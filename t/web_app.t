#!/usr/bin/env perl
use strict;
use warnings;

use Test::More tests => 2;
use Plack::Test;
use HTTP::Request::Common;

use FindBin '$Bin';
my $app = require "$Bin/../web_app.psgi";

test_psgi $app, sub {
	my $cb = shift;

	my $res = $cb->(GET "/static/index.html");
	like $res->content, qr{<body>};

	$res  = $cb->(GET "/static/index1.html");
	like $res->content, qr{not found};
};

