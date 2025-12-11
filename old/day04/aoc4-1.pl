#!/usr/bin/env perl
use strict;
use warnings;

my $INPUT_FILE = "aocdata.txt";

my @DIRS = ([-1,-1],[0,-1],[1,-1],
            [-1, 0],        [1, 0],
            [-1, 1],[0, 1],[1, 1]);

sub read_grid {
    my ($path) = @_;
    open my $fh, '<', $path or die "Cannot open $path: $!";
    my @lines = ();
    while (my $line = <$fh>) {
        chomp $line;
        next if $line =~ /^\s*$/;
        push @lines, $line;
    }
    close $fh;
    my $w = length($lines[0]);
    for my $i (0..$#lines) {
        die "Non-rectangular grid at line ".($i+1).": expected $w, got ".length($lines[$i])
            if length($lines[$i]) != $w;
    }
    return \@lines;
}

sub count_neighbors {
    my ($grid, $x, $y) = @_;
    my $h = scalar(@$grid);
    my $w = length($grid->[0]);
    my $cnt = 0;
    for my $d (@DIRS) {
        my ($dx, $dy) = @$d;
        my $nx = $x + $dx;
        my $ny = $y + $dy;
        next if $nx < 0 || $ny < 0 || $nx >= $w || $ny >= $h;
        $cnt++ if substr($grid->[$ny], $nx, 1) eq '@';
    }
    return $cnt;
}

sub main {
    my $grid = read_grid($INPUT_FILE);

    my @accessible = ();
    my $h = scalar(@$grid);
    my $w = length($grid->[0]);
    my $total = 0;

    for my $y (0..$h-1) {
        for my $x (0..$w-1) {
            my $ch = substr($grid->[$y], $x, 1);
            $total++ if $ch eq '@';
            next unless $ch eq '@';
            my $n = count_neighbors($grid, $x, $y);
            push @accessible, [$x, $y, $n] if $n < 4;
        }
    }

    my $accessible_count = scalar(@accessible);

    print "Total rolls: $total\n";
    print "Accessible rolls (<4 adjacent '\@'): $accessible_count\n";
    print "\n>>> FINAL RESULT: $accessible_count rolls can be accessed <<<\n";
}

main();
