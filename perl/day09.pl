#!/usr/bin/perl
use strict;
use warnings;
use Time::HiRes qw(time);

# Enable autoflush: STDERR and STDOUT
BEGIN {
    select(STDERR); $| = 1;
    select(STDOUT); $| = 1;
}

sub read_points {
    my ($filename) = @_;
    open my $fh, '<', $filename or die "Cannot open $filename: $!";
    my @pts;
    while (<$fh>) {
        chomp;
        next unless /\S/;
        my ($x, $y) = split /[, ]+/, $_;
        push @pts, [ int($x), int($y) ];
    }
    close $fh;
    return \@pts;
}

sub solve_part1 {
    my ($pts) = @_;
    my $n = scalar @$pts;
    my $max_area = 0;
    for (my $i=0; $i<$n; $i++) {
        my ($x1,$y1) = @{$pts->[$i]};
        for (my $j=$i+1; $j<$n; $j++) {
            my ($x2,$y2) = @{$pts->[$j]};
            my $area = (abs($x2-$x1)+1) * (abs($y2-$y1)+1);
            $max_area = $area if $area > $max_area;
        }
    }
    return $max_area;
}

sub build_edges {
    my ($red) = @_;
    my $n = scalar @$red;
    my @edges;
    for my $i (0..$n-1) {
        my ($x1,$y1) = @{$red->[$i]};
        my ($x2,$y2) = @{$red->[($i+1)%$n]};
        push @edges, [$x1,$y1,$x2,$y2];
    }
    return \@edges;
}

sub scanline_intervals {
    my ($edges) = @_;
    my %ys;
    for my $e (@$edges) {
        my (undef,$y1,undef,$y2) = @$e;
        $ys{$y1} = 1; $ys{$y2} = 1;
    }
    my @rows = sort { $a <=> $b } keys %ys;
    my $ymin = $rows[0];
    my $ymax = $rows[-1];

    my %intervals;
    my $t0 = time();
    for my $y ($ymin..$ymax) {
        my @xs;
        for my $e (@$edges) {
            my ($x1,$y1,$x2,$y2) = @$e;
            if ($x1 == $x2) {
                my ($lo,$hi) = ($y1 <= $y2) ? ($y1,$y2) : ($y2,$y1);
                if ($lo <= $y && $y < $hi) {
                    push @xs, $x1;
                }
            }
        }
        next unless @xs;
        @xs = sort { $a <=> $b } @xs;
        my @segs;
        for (my $i=0; $i<@xs; $i+=2) {
            last if $i+1 >= @xs;
            push @segs, [$xs[$i], $xs[$i+1]];
        }
        if (@segs) {
            my @merged;
            my ($curL,$curR) = @{$segs[0]};
            for my $s (@segs[1..$#segs]) {
                my ($L,$R) = @$s;
                if ($L <= $curR + 1) {
                    $curR = $R if $R > $curR;
                } else {
                    push @merged, [$curL,$curR];
                    ($curL,$curR) = ($L,$R);
                }
            }
            push @merged, [$curL,$curR];
            $intervals{$y} = \@merged;
        }
        # Preprocessing heartbeat every 1000 rows scanned
        if (($y - $ymin) % 1000 == 0) {
            my $elapsed = sprintf("%.2f", time() - $t0);
            print STDERR "Scanline: processed y=$y (elapsed ${elapsed}s)\n";
        }
    }
    return \%intervals;
}

sub build_row_index {
    my ($intervals) = @_;
    my @rows = sort { $a <=> $b } keys %$intervals;
    my %row_to_idx;
    for my $i (0..$#rows) { $row_to_idx{$rows[$i]} = $i; }
    return (\@rows, \%row_to_idx);
}

sub row_max_widths {
    my ($rows, $intervals) = @_;
    my @widths;
    for my $y (@$rows) {
        my $wmax = 0;
        for my $seg (@{$intervals->{$y}}) {
            my ($L,$R) = @$seg;
            my $w = $R - $L + 1;
            $wmax = $w if $w > $wmax;
        }
        push @widths, $wmax;
    }
    return \@widths;
}

sub interval_covers {
    my ($intervals_y,$xmin,$xmax) = @_;
    for my $seg (@$intervals_y) {
        my ($L,$R) = @$seg;
        return 1 if $L <= $xmin && $R >= $xmax;
    }
    return 0;
}

sub solve_part2_fast {
    my ($red) = @_;
    my $t0 = time();
    print STDERR "Part 2: building polygon edges...\n";
    my $edges = build_edges($red);

    print STDERR "Part 2: computing scanline intervals...\n";
    my $intervals = scanline_intervals($edges);

    print STDERR "Part 2: indexing rows and widths...\n";
    my ($rows,$row_to_idx) = build_row_index($intervals);
    return 0 unless @$rows;
    my $widths = row_max_widths($rows,$intervals);

    my $n = @$red;
    my $max_area = 0;
    my $checked = 0;
    my $report_every = 10000; # show frequent progress; adjust as needed
    my $last_report = time();

    print STDERR "Part 2: evaluating $n red tiles => ", ($n*($n-1))/2, " pairs...\n";

    for my $i (0..$n-1) {
        my ($x1,$y1) = @{$red->[$i]};
        for my $j ($i+1..$n-1) {
            $checked++;

            # time-based heartbeat to avoid buffering delays
            if ($checked % $report_every == 0) {
                my $now = time();
                if ($now - $last_report >= 0.25) { # at most 4 msgs/sec
                    my $elapsed = sprintf("%.2f", $now - $t0);
                    print STDERR "Checked $checked pairs (elapsed ${elapsed}s)\n";
                    $last_report = $now;
                }
            }

            my ($x2,$y2) = @{$red->[$j]};
            my ($xmin,$xmax) = ($x1<$x2)?($x1,$x2):($x2,$x1);
            my ($ymin,$ymax) = ($y1<$y2)?($y1,$y2):($y2,$y1);

            next unless exists $row_to_idx->{$ymin} && exists $row_to_idx->{$ymax};
            my $li = $row_to_idx->{$ymin};
            my $ri = $row_to_idx->{$ymax};
            next unless $rows->[$ri]-$rows->[$li] == $ri-$li;

            my $width = $xmax-$xmin+1;
            my $ok = 1;
            for my $idx ($li..$ri) {
                if ($widths->[$idx] < $width) { $ok=0; last; }
            }
            next unless $ok;

            for my $idx ($li..$ri) {
                my $y = $rows->[$idx];
                unless (interval_covers($intervals->{$y},$xmin,$xmax)) {
                    $ok=0; last;
                }
            }
            next unless $ok;

            my $area = $width*($ymax-$ymin+1);
            $max_area = $area if $area>$max_area;
        }
        # Row-level heartbeat
        my $elapsed = sprintf("%.2f", time() - $t0);
        print STDERR "Row $i/$n done (pairs checked $checked, elapsed ${elapsed}s)\n";
    }
    my $total_elapsed = sprintf("%.2f", time() - $t0);
    print STDERR "Total pairs checked: $checked (elapsed ${total_elapsed}s)\n";
    return $max_area;
}

sub main {
    my $filename = shift @ARGV || 'input/day09.txt';
    my $red = read_points($filename);

    my $part1 = solve_part1($red);
    print "Day 9 Part One Answer: $part1\n";

    my $part2 = solve_part2_fast($red);
    print "Day 9 Part Two Answer: $part2\n";
}

main();
