package Relaxer::RunRegexp;
# -*- coding: UTF-8 -*-

use warnings;
use strict;
use utf8;

use Data::Dumper;
use Text::Balanced qw(extract_bracketed);

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
#            a       - limit char classes
#            u       - use unicode-strings
#            l       - use locale
#            g       - match globally
#
# Returns a hashref like:
#
#    status     - 1 if OK
#    errmsg     - contains error description if ! status
#    results    - arrayref of
#         batch_part_0 .. batch_part_N, elements are hashrefs:
#               found - 1 if regexp match this task
#               altered - text after replacement
#               matches - matches ( just one element, if not /g ), array of hashrefs
#                    from    - start position
#                    to      - end position
#                    groups  - captures, arrayref of hashrefs
#                        from    - start position
#                        to      - end position
#               substitutions - positions of substitutions in 'altered'
#                    from    - start position
#                    to      - end position
#                    groups  - captures, arrayref of hashrefs
#                        from    - start position
#                        to      - end position
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
        my @texts = @{$in->{text}};

        my $search = $in->{match}; # quotemeta($in->{match});
        my $global = $in->{flags}->{g};

        # (?adluimsx-imsx:pattern)  ## TODO: use v5.14 flags
        my $flags = '';
        my $flags_minus = '';
        ## TEMP: don't use 5.14 flags
        ##for ( qw( a d l u ) ) {
        ##    $flags .= $_ if $in->{flags}->{$_};
        ##}
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

        my $need_replace = defined $in->{replace};
        my $substseq = $need_replace ? _substitutions_sequence( $in->{replace} ) : [];

        eval {  # try ...

            for my $pattern ( @texts ) {

                my $result = {
                    found           => 0,
                    matches         => [],
                    substitutions   => [],
                };
                my $altered = '';
                $altered = $pattern if $need_replace; # copy source text

                while (my $c = ( $pattern =~ m{$search}g )) {

                    $result->{found} = 1;

                    my $match = {
                        from    => $-[0],
                        to      => $+[0],
                        groups  => [],
                    };

                    ## TODO: named groups
                    for (my $i = 1; $i < @-; $i++) {

                        my $group = {
                            from    => $-[$i],
                            to      => $+[$i],
                        };
                        push @{$match->{groups}}, $group;

                    }

                    if ($need_replace) {

                        ##

                    }

                    push @{$result->{matches}}, $match;
                    last unless $global;
                }

                push @{$out->{results}}, $result;
            }
        };

        # Something happpen
        if ($@) {
            $out->{status}  = 0;
            $out->{errmsg}  = $@;    ## TODO: strip filename and line
            $out->{results} = [];
            $out->{groups}  = [];
        } else {
            $out->{groups} = get_groups($in->{match});
        }
    }

    return $out;
}

=head2 get_groups

    my $groups = get_groups("text (group) text");

Parse regexp text and return match groups info.

    [{string => '(group)', from => 5, to => 12, level => 0}, ...]

=cut

sub get_groups {
    my ($match, $level, $pos) = @_;

    $level ||= 0;
    $pos   ||= 0;

    my @results;
    while ($match =~ /\(/g) {
        my $cpos = pos($match) - 1;
        substr($match, 0, $cpos, '');
        $pos += $cpos;

        pos($match) = 0;    # Reset position for Text::Balanced
        my @groups = extract_bracketed($match, '()');

        last unless defined $groups[0];

        my $groupstring = substr($match, 0, length($groups[0]), '');
        if (is_matching_group($groupstring)) {
            push @results,
              { string => $groupstring,
                from   => $pos,
                to     => $pos + length($groups[0]) - 1,
                level  => $level,
              };
        }

        my $grouppos = $pos;
        $pos += length($groupstring);
        $groupstring =~ s/^\(//;
        $groupstring =~ s/\)$//;
        push @results, get_groups($groupstring, $level + 1, $grouppos + 1);
    }

    return wantarray ? @results : \@results;
}

=head2 is_matching_group
What is_matching_group does
=cut

sub is_matching_group {

    # Named group. Matches
    # (?<name>)
    if ($_[0] =~ /^\(\?<[_A-Za-z][_A-Za-z0-9]*>/) {
        return 1;
    }

    # Named group. Matches
    # (?'name')
    if ($_[0] =~ /^\(\?'[_A-Za-z][_A-Za-z0-9]*'/) {
        return 1;
    }

    # Python/PRCE named group. Matches
    # (?P<name>)
    if ($_[0] =~ /^\(\?P<[_A-Za-z][_A-Za-z0-9]*>/) {
        return 1;
    }

    # Anything with ? or *
    # (?:...) - not matches
    # (*NAME) - not matches
    if ($_[0] =~ /^\([\?*]/) {
        return 0;
    }

    # Only simple matching groups left now. I hope.
    return 1;
}


# ------------------------------------------------------------------------------
#
#
sub _substitutions_sequence($)
{
    my ($r) = @_;
    my $seq = [];

    $r =~ qr/
        (?:
            [^\\\$]+		# all except backslash or dollar sign
            |
            \\(\D)		# escaped symbol, not a digit: capture 1 - escaped symbol
            |
            \\(\d+)		# backslash and group number: capture 2 - group number
            |
            \$(\d+)		# dollar and group number: capture 3 - group number
            |
            \$\{(\d+)\}	        # dollar and exact group number: capture 4 - group number
            |
            .			# any other symbol
        )
    /x;     ## append /a modifier for 5.14

    return $seq;
}
# ==============================================================================
1;
