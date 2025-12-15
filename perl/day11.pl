#!/usr/bin/perl
use strict;
use warnings;

sub parse_graph {
    my ($lines) = @_;
    my %g;
    for my $line (@$lines) {
        next unless $line =~ /\S/;
        my ($name, $rhs) = split /:/, $line, 2;
        $name =~ s/^\s+|\s+$//g;
        $rhs  =~ s/^\s+|\s+$//g;
        my @targets = grep { $_ ne '' } split /\s+/, $rhs;
        $g{$name} = \@targets;
    }
    return \%g;
}

# ---------- Part 1 ----------
sub count_paths {
    my ($g, $start, $goal) = @_;
    my %memo;
    my %onstack;
    my $dfs;
    $dfs = sub {
        my ($u) = @_;
        return 1 if $u eq $goal;
        return $memo{$u} if exists $memo{$u};
        return 0 if $onstack{$u};
        $onstack{$u} = 1;
        my $total = 0;
        for my $v (@{ $g->{$u} // [] }) {
            $total += $dfs->($v);
        }
        delete $onstack{$u};
        $memo{$u} = $total;
        return $total;
    };
    return $dfs->($start);
}

# ---------- Part 2 ----------
sub count_paths_with_both {
    my ($g, $start, $goal, $a, $b) = @_;
    my %memo;
    my %onstack;
    my $dfs;
    $dfs = sub {
        my ($u, $va, $vb) = @_;
        if ($u eq $goal) {
            return ($va && $vb) ? 1 : 0;
        }
        my $key = join("|", $u, $va ? 1 : 0, $vb ? 1 : 0);
        return $memo{$key} if exists $memo{$key};
        return 0 if $onstack{$key};
        $onstack{$key} = 1;
        my $va2 = $va || ($u eq $a);
        my $vb2 = $vb || ($u eq $b);
        my $total = 0;
        for my $v (@{ $g->{$u} // [] }) {
            $total += $dfs->($v, $va2, $vb2);
        }
        delete $onstack{$key};
        $memo{$key} = $total;
        return $total;
    };
    return $dfs->($start, 0, 0);
}

sub main {
    @ARGV == 1 or die "Usage: reactor.pl input.txt\n";
    my $file = shift @ARGV;
    open my $fh, '<', $file or die "Can't open $file: $!";
    my @lines = <$fh>;
    close $fh;

    my $g = parse_graph(\@lines);

    my $part1 = count_paths($g, 'you', 'out');
    print "Part 1: paths you->out = $part1\n";

    my $total = count_paths($g, 'svr', 'out');
    my $both  = count_paths_with_both($g, 'svr', 'out', 'dac', 'fft');
    print "Part 2: total svr->out = $total\n";
    print "Part 2: paths visiting dac & fft = $both\n";
}

main();
