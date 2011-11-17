use strict;
use warnings;

use Test::More;
use Relaxer::RunRegexp;

plan tests => 6;

my $mock = {'text' => ['foo'], match => '', flags => {}};

$mock->{match} = 'foo';
my $r = run_regexp($mock);

isa_ok $r->{groups}, 'ARRAY', 'groups in regex';
is_deeply $r->{groups}, [], 'no groups';

$mock->{match} = '(bar)';
$r = run_regexp($mock);
is_deeply $r->{groups}, [{from => 0, to => 4, level => 0, string => '(bar)'}],
  'one group';

$mock->{match} = 'foo(bar)';
$r = run_regexp($mock);
is_deeply $r->{groups}, [{from => 3, to => 7, level => 0, string => '(bar)'}],
  'one group';

$mock->{match} = 'foo(bar) baz (quee)';
$r = run_regexp($mock);
is_deeply $r->{groups},
  [ {from => 3,  to => 7,  level => 0, string => '(bar)'},
    {from => 13, to => 18, level => 0, string => '(quee)'}
  ],
  'two groups';


$mock->{match} = 'foo(bar(nested)) baz (quee)';
$r = run_regexp($mock);
is_deeply $r->{groups},
  [ {from => 3,  to => 15, level => 0, string => '(bar(nested))'},
    {from => 7,  to => 14, level => 1, string => '(nested)'},
    {from => 21, to => 26, level => 0, string => '(quee)'}
  ],
  'nested groups';
