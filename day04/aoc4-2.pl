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
    my @grid = ();
    while (my $line = <$fh>) {
        chomp $line;
        next if $line =~ /^\s*$/;
        push @grid, [split //, $line];
    }
    close $fh;
    return \@grid;
}

sub count_neighbors {
    my ($grid, $x, $y) = @_;
    my $h = scalar(@$grid);
    my $w = scalar(@{$grid->[0]});
    my $cnt = 0;
    for my $d (@DIRS) {
        my ($dx, $dy) = @$d;
        my $nx = $x + $dx;
        my $ny = $y + $dy;
        next if $nx < 0 || $ny < 0 || $nx >= $w || $ny >= $h;
        $cnt++ if $grid->[$ny][$nx] eq '@';
    }
    return $cnt;
}

sub remove_accessible {
    my ($grid) = @_;
    my $h = scalar(@$grid);
    my $w = scalar(@{$grid->[0]});
    my @to_remove;
    for my $y (0..$h-1) {
        for my $x (0..$w-1) {
            if ($grid->[$y][$x] eq '@') {
                if (count_neighbors($grid, $x, $y) < 4) {
                    push @to_remove, [$x, $y];
                }
            }
        }
    }
    for my $pos (@to_remove) {
        my ($x, $y) = @$pos;
        $grid->[$y][$x] = '.';
    }
    return scalar(@to_remove);
}

sub main {
    my $grid = read_grid($INPUT_FILE);
    my $total_removed = 0;
    while (1) {
        my $removed = remove_accessible($grid);
        last if $removed == 0;
        $total_removed += $removed;
    }
    print "Total rolls removed: $total_removed\n";
}

main();
