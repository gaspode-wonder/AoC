#!/usr/bin/perl
use strict;
use warnings;

sub parse_line {
    my ($line) = @_;
    my ($diag) = $line =~ /\[([.#]+)\]/ or die "Malformed diagram: $line";
    my $n = length($diag);
    my $target = 0;
    for (my $i = 0; $i < $n; $i++) {
        my $ch = substr($diag, $i, 1);
        if ($ch eq '#') {
            $target |= (1 << $i);
        }
    }
    my @buttons;
    while ($line =~ /\(([^)]*)\)/g) {
        my $group = $1;
        $group =~ s/^\s+|\s+$//g;
        my $mask = 0;
        if ($group ne '') {
            for my $tok (split /[,\s]+/, $group) {
                next if $tok eq '';
                my $k = int($tok);
                if ($k >= 0 && $k < $n) {
                    $mask |= (1 << $k);
                }
            }
        }
        push @buttons, $mask; # empty -> 0 mask allowed
    }
    return ($n, $target, \@buttons);
}

sub bidir_bfs {
    my ($n, $target, $buttons) = @_;
    my $start = 0;
    return 0 if $start == $target;

    my %front_a = ($start => 0);
    my %front_b = ($target => 0);
    my @qa = ($start);
    my @qb = ($target);
    my %vis_a = ($start => 1);
    my %vis_b = ($target => 1);

    while (@qa && @qb) {
        if (@qa <= @qb) {
            my $size = scalar @qa;
            for (1..$size) {
                my $state = shift @qa;
                my $da = $front_a{$state};
                for my $mask (@$buttons) {
                    my $nxt = $state ^ $mask;
                    if (exists $front_b{$nxt}) {
                        return $da + 1 + $front_b{$nxt};
                    }
                    unless ($vis_a{$nxt}) {
                        $vis_a{$nxt} = 1;
                        $front_a{$nxt} = $da + 1;
                        push @qa, $nxt;
                    }
                }
            }
        } else {
            my $size = scalar @qb;
            for (1..$size) {
                my $state = shift @qb;
                my $db = $front_b{$state};
                for my $mask (@$buttons) {
                    my $nxt = $state ^ $mask;
                    if (exists $front_a{$nxt}) {
                        return $db + 1 + $front_a{$nxt};
                    }
                    unless ($vis_b{$nxt}) {
                        $vis_b{$nxt} = 1;
                        $front_b{$nxt} = $db + 1;
                        push @qb, $nxt;
                    }
                }
            }
        }
    }
    return undef; # unreachable
}

sub solve_day10 {
    my ($lines) = @_;
    my $total = 0;
    for my $line (@$lines) {
        next unless $line =~ /\S/;
        my ($n, $target, $buttons) = parse_line($line);
        my $presses = bidir_bfs($n, $target, $buttons);
        die "Unreachable target: $line\n" unless defined $presses;
        $total += $presses;
    }
    return $total;
}

sub main {
    my $filename = shift @ARGV;
    if (defined $filename) {
        open my $fh, '<', $filename or die "Cannot open $filename: $!";
        my @lines = <$fh>;
        chomp @lines;
        close $fh;
        my $ans = solve_day10(\@lines);
        print "Day 10 Part One Answer: $ans\n";
    } else {
        my @sample = (
            "[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}",
            "[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}",
            "[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}",
        );
        my $ans = solve_day10(\@sample);
        print "Sample total: $ans\n"; # Expected: 7
    }
}

main();
