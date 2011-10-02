#!/usr/bin/perl -w
# -*- coding: UTF-8 -*-

use strict;
use warnings;

use Test::More;
use Data::Dumper;

use FindBin;
use lib "$FindBin::Bin/../../../lib";

use Relaxer::RunRegexp;

&main();
# ------------------------------------------------------------------------------
sub main
{
    my @tests = (

        # in 1
        {
            text    => [ 'Lorem ipsum' ],
            match   => '(.)m',
            flags   => { g => 1 },
        },
        # out->results 1
        [
            {
                found   => 1,
                matches => [
                    {
                        from =>  3, to =>  5,
                        groups => [
                            { from =>  3, to =>  4 },
                        ]
                    },
                    {
                        from =>  9, to => 11,
                        groups => [
                            { from =>  9, to => 10 },
                        ]
                    }
                ],
                substitutions => [],
            },
        ],

        # in 2
        {
            text    => [ 'qweqqq' ],
            match   => 'q',
            flags   => { x => 1, s => 1, m => 1, a => 1 },
            replace => '',
        },
        # out->results 2
        [
            {
                found   => 1,
                matches => [
                    {
                        from =>  0, to =>  1,
                        groups => [],
                    },
                ],
                substitutions => [],
            },
        ],

        # in 3
        {
            text    => [ 'Lorem ipsum' ],
            match   => 'M',
            flags   => { i => 1, g => 1 },
        },
        # out->results 3
        [
            {
                found   => 1,
                matches => [
                    {
                        from =>  4, to =>  5,
                        groups => [],
                    },
                    {
                        from => 10, to => 11,
                        groups => [],
                   }
                ],
                substitutions => [],
            },
        ],
    );

    my $n = scalar @tests / 2;
    plan tests => $n * 2;

    for my $i ( 1 .. $n ) {
        my $r = run_regexp( $tests[ ($i - 1) * 2 ] );
        my $sample = $tests[ ($i - 1) * 2 + 1 ];

        ok($r->{status} == 1 && $r->{errmsg} eq '', "Done $i");
        is_deeply($r->{results}, $sample, "Results $i");
    }
}
# ------------------------------------------------------------------------------
# ==============================================================================
1;
