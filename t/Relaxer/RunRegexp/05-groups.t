use strict;
use warnings;

use Test::More;
use Relaxer::RunRegexp;

plan tests => 6;

sub group_deeply;

my $mock = {'text' => ['foo'], match => '', flags => {}};

$mock->{match} = 'foo';
my $r = run_regexp($mock);

group_deeply 'foo' => [], 'no groups';

group_deeply
  '(bar)' => [
    {   from   => 0,
        to     => 4,
        level  => 0,
        string => '(bar)'
    }
  ],
  'one group';

group_deeply
  'foo(bar)' => [
    {   from   => 3,
        to     => 7,
        level  => 0,
        string => '(bar)'
    }
  ],
  'one group';

group_deeply
  'foo(bar) baz (quee)' => [
    {from => 3,  to => 7,  level => 0, string => '(bar)'},
    {from => 13, to => 18, level => 0, string => '(quee)'}
  ],
  'two groups';


group_deeply
  'foo(bar(nested)) baz (quee)' => [
    {from => 3,  to => 15, level => 0, string => '(bar(nested))'},
    {from => 7,  to => 14, level => 1, string => '(nested)'},
    {from => 21, to => 26, level => 0, string => '(quee)'}
  ],
  'nested groups';

sub group_deeply {
    my $regexp  = shift;
    my $compare = shift;
    my $flags = ref $_[0] ? shift : {};
    my $description = shift;

    my $mock = {
        text  => ['foo'],
        match => $regexp,
        flags => $flags
    };

    my $r = run_regexp($mock);
    is_deeply $r->{groups}, $compare, $description;
}
