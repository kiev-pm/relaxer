#!/usr/bin/perl -w
# -*- coding: UTF-8 -*-

use strict;
use warnings;

use Test::More tests => 6;
use Data::Dumper;

use FindBin;
use lib "$FindBin::Bin/../../../lib";

use Relaxer::RunRegexp;

&main();
# ------------------------------------------------------------------------------
sub main
{
    # test 1
    my $r = run_regexp({
    });
    ok( ! $r->{status},                         'No text and regexp' );
    is( $r->{errmsg}, 'Nothing to match',       'Error message 1 ok' );

    # test 2
    $r = run_regexp({
        text => 'foo',
    });
    ok( ! $r->{status},                         'No regexp' );
    is( $r->{errmsg}, 'Nothing to match',       'Error message 2 ok' );

    # test 3
    $r = run_regexp({
        match => '[a-z]',
    });
    ok( ! $r->{status},                         'No input text' );
    is( $r->{errmsg}, 'Nothing to match',       'Error message 3 ok' );
}
# ------------------------------------------------------------------------------
1;
