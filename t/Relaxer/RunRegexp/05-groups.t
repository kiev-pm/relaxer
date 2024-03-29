use strict;
use warnings;

use Test::More;
use Relaxer::RunRegexp;

plan tests => 15;

sub group_deeply; # $string_regexp, $arrayref_groups, $comment

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

group_deeply
  'foo(?:bar) (baz)' => [
    {   from   => 11,
        to     => 15,
        level  => 0,
        string => '(baz)'
    }
  ],
  'groups that should not be matched';


for my $start (qw/: = ! <= <! >/) {
    group_deeply
      "foo(?${start}bar) (baz)" => [
        {   from   => 10 + length($start),
            to     => 14 + length($start),
            level  => 0,
            string => '(baz)'
        }
      ],
      "groups starting with '${start}' should be ignored";
}

group_deeply
  "foo(?<NAME>foo) (?&NAME) (baz)" => [
    {   from   => 3,
        to     => 14,
        level  => 0,
        string => '(?<NAME>foo)'
    },
    {   from   => 25,
        to     => 29,
        level  => 0,
        string => '(baz)'
    }
  ],
  "reference to named group should be ignored";

group_deeply
  "foo (*PRUNE) (baz)" => [
    {   from   => 13,
        to     => 17,
        level  => 0,
        string => '(baz)'
    }
  ],
  "* marked keywords should be ignored";

# Should warn:
# The "branch reset" pattern is not supported by Relaxer.
# No group information available

group_deeply
  'foo(|:bar)' => [],
  '"branch reset" pattern makes group detection too tricky. no support';


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
    if ($r->{errmsg}) {
        fail $r->{errmsg};
        diag explain $r;
        return;
    }
    is_deeply $r->{groups}, $compare, $description or diag explain $r->{groups};
}
