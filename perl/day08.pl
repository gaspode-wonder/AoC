#!/usr/bin/perl
use strict;
use warnings;
use List::Util qw(max);

# -------- Union-Find --------
my @parent;
my @size;

sub uf_init {
    my ($n) = @_;
    @parent = (0 .. $n-1);
    @size   = (1) x $n;
}

sub uf_find {
    my ($x) = @_;
    $parent[$x] = uf_find($parent[$x]) if $parent[$x] != $x;
    return $parent[$x];
}

sub uf_union {
    my ($a, $b) = @_;
    $a = uf_find($a);
    $b = uf_find($b);
    return 0 if $a == $b;
    if ($size[$a] < $size[$b]) {
        ($a, $b) = ($b, $a);
    }
    $parent[$b] = $a;
    $size[$a]  += $size[$b];
    return 1;
}

sub dist2 {
    my ($p, $q) = @_;
    my ($dx,$dy,$dz) = ($p->[0]-$q->[0], $p->[1]-$q->[1], $p->[2]-$q->[2]);
    return $dx*$dx + $dy*$dy + $dz*$dz;
}

sub read_points {
    my ($filename) = @_;
    open my $fh, '<', $filename or die "Cannot open $filename: $!";
    my @pts;
    while (<$fh>) {
        chomp;
        next unless /\S/;
        my ($x,$y,$z) = split /[, ]+/, $_;
        push @pts, [int($x), int($y), int($z)];
    }
    close $fh;
    return \@pts;
}

sub main {
    my $filename = shift @ARGV || 'input/day08.txt';
    my $points   = read_points($filename);
    my $n        = @$points;

    # Build all pairs
    my @pairs;
    for my $i (0..$n-1) {
        for my $j ($i+1..$n-1) {
            push @pairs, [$i,$j,dist2($points->[$i],$points->[$j])];
        }
    }
    @pairs = sort { $a->[2] <=> $b->[2] } @pairs;

    uf_init($n);
    my $pairs_considered = 0;
    my $part1_answer;
    my $part2_answer;

    for my $pair (@pairs) {
        my ($i,$j,$d2) = @$pair;
        $pairs_considered++;
        uf_union($i,$j);   # attempt union, may or may not merge

        # Part One: after 1000 pairs considered
        if ($pairs_considered == 1000 && !defined $part1_answer) {
            my %seen;
            my @sizes;
            for my $idx (0..$n-1) {
                my $root = uf_find($idx);
                next if $seen{$root}++;
                push @sizes, $size[$root];
            }
            @sizes = sort { $b <=> $a } @sizes;
            $part1_answer = $sizes[0] * $sizes[1] * $sizes[2];
        }

        # Part Two: when all connected
        my $root0 = uf_find(0);
        if ($size[$root0] == $n && !defined $part2_answer) {
            $part2_answer = $points->[$i]->[0] * $points->[$j]->[0];
            last;
        }
    }

    print "Day 8 Part One Answer: $part1_answer\n";
    print "Day 8 Part Two Answer: $part2_answer\n";
}

main();
