#!/usr/bin/perl -w
# -*- coding: UTF-8 -*-

use strict;
use warnings;

use Test::More tests => 4;
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
        text    => 'Lorem ipsum',
        match   => '+',
    });

    ok( ! $r->{status},                                         'Shit happen' );
    like( $r->{errmsg}, qr/^Quantifier follows nothing/i,       'Error message - quantifier' );

    # test 2
    $r = run_regexp({
        text    => 'Lorem ipsum',
        match   => '(',
    });

    ok( ! $r->{status},                                         'Shit happen again' );
    like( $r->{errmsg}, qr/^Unmatched/i,                        'Error message - unmatched' );
}
# ------------------------------------------------------------------------------
1;
