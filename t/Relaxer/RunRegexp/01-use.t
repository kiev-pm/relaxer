#!/usr/bin/perl -w
# -*- coding: UTF-8 -*-

use strict;
use warnings;
use utf8;

use Test::More tests => 2;

use FindBin;
use lib "$FindBin::Bin/../../../lib";

use_ok('Relaxer::RunRegexp');

&main();
# ------------------------------------------------------------------------------
sub main
{
    ok( ref run_regexp() eq 'HASH', 'run_regexp() returns hashref' );
}
# ------------------------------------------------------------------------------
1;
