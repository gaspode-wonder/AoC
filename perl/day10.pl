#!/usr/bin/perl
use strict;
use warnings;
use List::Util qw(max sum);

# ---------- Part 1 ----------
sub parse_line_part1 {
    my ($line) = @_;
    my ($diag) = $line =~ /\[([.#]+)\]/ or die "Malformed diagram: $line";
    my $n = length($diag);
    my $target = 0;
    for (my $i = 0; $i < $n; $i++) {
        $target |= (1 << $i) if substr($diag, $i, 1) eq '#';
    }
    my @buttons;
    while ($line =~ /\(([^)]*)\)/g) {
        my $mask = 0;
        for my $tok (split /[,\s]+/, $1) {
            next if $tok eq '';
            my $k = int($tok);
            $mask |= (1 << $k);
        }
        push @buttons, $mask;
    }
    return ($n, $target, \@buttons);
}

sub bidir_bfs {
    my ($n, $target, $buttons) = @_;
    my $start = 0;
    return 0 if $start == $target;

    my (%da,%db,%va,%vb,@qa,@qb);
    $da{$start}=0; $db{$target}=0; $va{$start}=1; $vb{$target}=1;
    @qa=($start); @qb=($target);

    while (@qa && @qb) {
        if (@qa <= @qb) {
            my $size = @qa;
            for (1..$size) {
                my $s = shift @qa;
                my $d = $da{$s};
                for my $m (@$buttons) {
                    my $t = $s ^ $m;
                    return $d+1+$db{$t} if exists $db{$t};
                    unless ($va{$t}) { $va{$t}=1; $da{$t}=$d+1; push @qa,$t; }
                }
            }
        } else {
            my $size = @qb;
            for (1..$size) {
                my $s = shift @qb;
                my $d = $db{$s};
                for my $m (@$buttons) {
                    my $t = $s ^ $m;
                    return $d+1+$da{$t} if exists $da{$t};
                    unless ($vb{$t}) { $vb{$t}=1; $db{$t}=$d+1; push @qb,$t; }
                }
            }
        }
    }
    die "Unreachable in Part 1";
}

sub solve_part1_total {
    my ($lines) = @_;
    my $total = 0;
    for my $line (@$lines) {
        next unless $line =~ /\S/;
        my ($n,$target,$buttons) = parse_line_part1($line);
        $total += bidir_bfs($n,$target,$buttons);
    }
    return $total;
}

# ---------- Part 2 ----------
sub parse_line_part2 {
    my ($line) = @_;
    my @buttons;
    while ($line =~ /\(([^)]*)\)/g) {
        my @idx = grep { $_ ne '' } split(/[,\s]+/, $1);
        push @buttons, \@idx;
    }
    my ($tg) = $line =~ /\{([^}]*)\}/ or die "Missing target braces: $line";
    my @target = map { int($_) } grep { $_ ne '' } split(/[,\s]+/, $tg);
    my $m = @target;
    for my $b (@buttons) {
        @$b = grep { $_ >= 0 && $_ < $m } @$b;
    }
    return (\@buttons, \@target);
}

sub heuristic {
    my ($state,$target) = @_;
    my $h = 0;
    for my $i (0..$#$target) {
        $h += $target->[$i] - $state->[$i];
    }
    return $h;
}

sub solve_machine_astar {
    my ($buttons,$target) = @_;
    my $m = @$target;

    # Precompute increments
    my @inc;
    for my $b (@$buttons) {
        my @v = (0) x $m;
        $v[$_]++ for @$b;
        push @inc, \@v;
    }

    my @start = (0) x $m;
    my $goal_key = join(",", @$target);

    my @queue = ( [\@start, 0, heuristic(\@start,$target)] );
    my %seen = ( join(",", @start) => 0 );

    while (@queue) {
        # Pop lowest f = g+h
        @queue = sort { $a->[1]+$a->[2] <=> $b->[1]+$b->[2] } @queue;
        my ($state,$g,$h) = @{ shift @queue };
        my $key = join(",", @$state);
        return $g if $key eq $goal_key;

        for my $v (@inc) {
            my @new = map { $state->[$_] + $v->[$_] } (0..$m-1);
            next if grep { $new[$_] > $target->[$_] } (0..$m-1);
            my $nk = join(",", @new);
            my $new_g = $g+1;
            next if exists $seen{$nk} && $seen{$nk} <= $new_g;
            $seen{$nk} = $new_g;
            my $new_h = heuristic(\@new,$target);
            push @queue, [\@new,$new_g,$new_h];
        }
    }
    die "No solution found for Part 2";
}

sub solve_part2_total {
    my ($lines) = @_;
    my $total=0;
    for my $line (@$lines) {
        next unless $line =~ /\S/;
        my ($buttons,$target) = parse_line_part2($line);
        $total += solve_machine_astar($buttons,$target);
    }
    return $total;
}

# ---------- Estimation ----------
sub estimate_machine {
    my ($buttons,$target) = @_;
    my $m = scalar @$target;
    my $btn_count = scalar @$buttons;
    my $space = 1; $space *= ($_+1) for @$target;
    my @sizes = map { scalar @$_ } @$buttons;
    my $max_cov = @sizes ? max(@sizes) : 0;
    my $avg_cov = @sizes ? (sum(@sizes)/@sizes) : 0;
    my $sum_t = sum(@$target);
    my $max_t = @$target ? max(@$target) : 0;
    my $lb1 = $max_t;
    my $lb2 = $max_cov ? int(($sum_t + $max_cov - 1)/$max_cov) : 0;
    my @touched = (0) x $m;
    for my $btn (@$buttons) { $touched[$_]++ for @$btn; }
    my @untouchable = grep { $touched[$_] == 0 && $target->[$_] > 0 } (0..$m-1);
    return {
        m => $m, b => $btn_count, space => $space,
        max_target => $max_t, sum_target => $sum_t,
        max_button_coverage => $max_cov,
        avg_button_coverage => sprintf("%.2f",$avg_cov),
        lb_presses => ($lb1 > $lb2 ? $lb1 : $lb2),
        untouchable => \@untouchable,
    };
}

sub estimate_file {
    my ($lines) = @_;
    my $i = 0;
    for my $line (@$lines) {
        next unless $line =~ /\S/;
        $i++;
        my ($buttons,$target) = parse_line_part2($line);
        my $est = estimate_machine($buttons,$target);
        print "Machine $i:\n";
        print "  Counters: $est->{m}\n";
        print "  Buttons: $est->{b}\n";
        print "  State space upper bound: $est->{space}\n";
        print "  Max target: $est->{max_target}\n";
        print "  Sum target: $est->{sum_target}\n";
        print "  Max button coverage: $est->{max_button_coverage}\n";
        print "  Avg button coverage: $est->{avg_button_coverage}\n";
        print "  Lower bound presses: $est->{lb_presses}\n";
        if (@{ $est->{untouchable} }) {
            print "  WARNING: Untouchable counters with >0 target: ";
            print join(",", @{ $est->{untouchable} }), "\n";
        }
        print "\n";
    }
}

# ---------- Main ----------
sub main {
    @ARGV >= 3 or die "Usage: day10.pl --part 1|2|estimate input.txt\n";
    my $flag = shift @ARGV;
    $flag eq '--part' or die "First arg must be --part\n";
    my $mode = shift @ARGV;
    my $filename = shift @ARGV;

    open my $fh, '<', $filename or die "Cannot open $filename: $!";
    my @lines = <$fh>; chomp @lines; close $fh;

    if ($mode eq '1') {
        my $ans = solve_part1_total(\@lines);
        print "Day 10 Part 1 Answer: $ans\n";
    } elsif ($mode eq '2') {
        my $ans = solve_part2_total(\@lines);
        print "Day 10 Part 2 Answer: $ans\n";
    } elsif ($mode eq 'estimate') {
        estimate_file(\@lines);
    } else {
        die "Part must be 1, 2, or estimate\n";
    }
}

main();
