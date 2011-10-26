use inc::Module::Install;

name     'relaxer';
all_from 'lib/Relaxer.pm';
author   q{Kiev.pm http://kiev.pm.org/};
license  'perl';

requires 'JSON';
requires 'Plack';
requires 'Routes::Tiny';
requires 'Try::Tiny';

build_requires 'Test::More';

auto_install;

WriteAll;

