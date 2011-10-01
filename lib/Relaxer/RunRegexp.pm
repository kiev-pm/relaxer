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
#    text        - input text, array of strings
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
    $in->{match}    //= '';

    if (!ref $in->{text} || ref $in->{text} ne 'ARRAY' || @{$in->{text}} == 0 || $in->{match} eq '') {
        $out->{status} = 0;
        $out->{errmsg} = 'Nothing to match';
    }
    else {
        my @patterns = @{$in->{text}};

        my $search = $in->{match}; # quotemeta($in->{match});
        my $global = $in->{flags}->{g};

        # (?adluimsx-imsx:pattern)
        my $flags = '';
        my $flags_minus = '';
        for ( qw( a d l u ) ) {
            $flags .= $_ if $in->{flags}->{$_};
        }
        for ( qw( i m s x ) ) {
            if ($in->{flags}->{$_}) {
                $flags .= $_;
            }
            else {
                $flags_minus .= $_;
            }
        }
        $flags .= "-$flags_minus" if $flags_minus;
        $search = "(?$flags:$search)" if $flags;

        eval {  # try ...

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

                        ## TODO: named grouping
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
        };

        # Something happpen
        if ($@) {
            $out->{status}  = 0;
            $out->{errmsg}  = $@;           ## TODO: strip filename and line
            $out->{results} = [];
        }
    }

    return $out;
}
# ==============================================================================
1;
