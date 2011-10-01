package Relaxer::RunRegexp;
# -*- coding: UTF-8 -*-

use warnings;
use strict;
use utf8;

use Data::Dumper;

use base qw(Exporter);

# === Export ===================================================================
#
# Export by default
our @EXPORT = qw(
    run_regexp
);
# Export on demand
our @EXPORT_OK = qw();

# === Functions ================================================================
#
# Accepts a hashref with following keys:
#
#    text        - input text
#    match       - regular expression
#    replace     - if defined, it's substitution text for s/// mode; otherwise, m// mode
#    flags       - modifiers: a hashref
#            i       - case-insensitive
#            s       - single-line
#            m       - multi-line
#            x       - extended syntax
#            a       -
#            u       - ?
#            l       - ?
#            g       - match globally
#    batch       - 1 = split input text into list of lines
#
# Returns a hashref like:
#
#    status     - 1 if OK
#    errmsg     - contains error description if ! status
#    results    - arrayref of
#            batch_part_0 .. batch_part_N, elements are hashrefs:
#               found - 1 if regexp match this task
#               matches - matches ( just one element, if not /g ), array of hashrefs
                    #from    - start position
                    #to      - end position
                    #groups  - captures, arrayref of hashrefs
                    #    from    - start position
                    #    to      - end position
#
sub run_regexp($)
{
    my ($in) = @_;

    # Retval
    my $out = {
        status      => 1,
        errmsg      => '',
        results     => [],
    };

    # Analyze params
    $in->{text}     //= '';
    $in->{match}    //= '';

    if ($in->{text} eq '' || $in->{match} eq '') {
        $out->{status} = 0;
        $out->{errmsg} = 'Nothing to match';
    }
    else {

        ## TODO: named grouping

        # Split input to set of patterns
        ## TODO: check EOL markers from different browsers,
        ## save proper position in input text
        my @patterns = $in->{batch} ? split(/\n/, $in->{text}) : ( $in->{text} );

        my $search = $in->{match}; # quotemeta($in->{match});
        my $global = $in->{flags}->{g};

        # (?adluimsx-imsx:pattern)
        my $flags = '';
        for ( qw( a d l u i m s x ) ) {
            ## TODO: minus modifiers
            $flags .= $_ if $in->{flags}->{$_};
        }
        $search = "(?$flags:$search)" if $flags;

        for my $patt ( @patterns ) {

            my $result = {
                found   => 0,
                matches => [],
            };

            if (! defined $in->{replace}) {
                # m operator

                while (my $c = ( $patt =~ m{$search}g )) {

                    $result->{found} = 1;

                    my $match = {
                        from    => $-[0],
                        to      => $+[0],
                        groups  => [],
                    };

                    for (my $i = 1; $i <= $c; $i++) {

                        my $group = {
                            from    => $-[$i],
                            to      => $+[$i],
                        };
                        push @{$match->{groups}}, $group;

                    }

                    push @{$result->{matches}}, $match;

                    last if ! $global;
                }

            }
            else {
                # s operator
            }

            push @{$out->{results}}, $result;
        }
    }

    return $out;
}
# ==============================================================================
1;
