use inc::Module::Install;

name     'relaxer';
all_from 'lib/Relaxer.pm';
author   q{Yaroslav Korshak <yko@cpan.org>};
license  'perl';

build_requires 'Test::More';

auto_install;

WriteAll;

