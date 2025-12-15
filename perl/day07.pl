#!/usr/bin/perl
use strict;
use warnings;
use List::Util qw(max);

sub load_input {
    my ($filename) = @_;
    open my $fh, '<', $filename or die "Cannot open $filename: $!";
    my @lines = grep { /\S/ } map { chomp; $_ } <$fh>;
    close $fh;
    return \@lines;
}

sub find_start {
    my ($grid_ref) = @_;
    my @grid = @$grid_ref;
    for my $r (0 .. $#grid) {
        my $idx = index($grid[$r], 'S');
        return ($r, $idx) if $idx != -1;
    }
    die "No S found\n";
}

# Part One: count total splits (every beam hitting a splitter increments)
sub count_splits {
    my ($grid_ref) = @_;
    my @grid = @$grid_ref;
    my $h = scalar @grid;
    my $w = List::Util::max(map { length($_) } @grid);
    @grid = map { $_ . ('.' x ($w - length($_))) } @grid;

    my ($sr, $sc) = find_start(\@grid);

    my @beam = (0) x $w;
    $beam[$sc] = 1;
    my $splits = 0;

    for my $r ($sr .. $h-2) {
        my @next = (0) x $w;
        for my $c (0 .. $w-1) {
            next unless $beam[$c];
            my $cell = substr($grid[$r+1], $c, 1);
            if ($cell eq '^') {
                $splits += $beam[$c];
                $next[$c-1] = 1 if $c > 0;
                $next[$c+1] = 1 if $c < $w-1;
            } else {
                $next[$c] = 1;
            }
        }
        @beam = @next;
    }
    return $splits;
}

# Part Two: count total timelines (branching at splitters, accumulate counts)

sub count_timelines {
    my ($grid_ref) = @_;
    my @grid = @$grid_ref;
    my $h = scalar @grid;
    my $w = List::Util::max(map { length($_) } @grid);
    @grid = map { $_ . ('.' x ($w - length($_))) } @grid;

    my ($sr, $sc) = find_start(\@grid);

    my @ways = (0) x $w;
    $ways[$sc] = 1;
    my $total = 0;

    for my $r ($sr .. $h-2) {
        my @next = (0) x $w;
        for my $c (0 .. $w-1) {
            my $count = $ways[$c] or next;
            my $cell = substr($grid[$r+1], $c, 1);
            if ($cell eq '^') {
                $next[$c-1] += $count if $c > 0;
                $next[$c+1] += $count if $c < $w-1;
            } else {
                $next[$c] += $count;
            }
        }
        @ways = @next;
    }
    $total += $_ for @ways;
    return $total;
}

sub main {
    my $filename = (@ARGV && $ARGV[0]) ? $ARGV[0] : 'input/day07.txt';
    my $lines = load_input($filename);

    my $part1 = count_splits($lines);
    my $part2 = count_timelines($lines);

    print "Day 7 Part One Answer: $part1\n";
    print "Day 7 Part Two Answer: $part2\n";
}

main();
