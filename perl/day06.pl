#!/usr/bin/perl
use strict;
use warnings;

sub parse_ops {
    my ($line) = @_;
    $line =~ s/\s+/ /g;
    $line =~ s/^\s+|\s+$//g;
    my @ops = grep { $_ ne '' } split(/ /, $line);
    return \@ops;
}

sub parse_grid_tokens {
    my ($lines) = @_;
    my @rows = map { [ split(/\s+/, $_) ] } @$lines;
    my $width = 0;
    for my $r (@rows) {
        $width = @$r if @$r > $width;
    }
    # transpose
    my @cols;
    for my $c (0 .. $width-1) {
        my @col;
        for my $r (@rows) {
            push @col, $r->[$c] if defined $r->[$c];
        }
        push @cols, [ map { int($_) } @col ];
    }
    return \@cols;
}

sub parse_grid_constructed {
    my ($lines) = @_;
    my $maxlen = 0;
    $maxlen = length($_) > $maxlen ? length($_) : $maxlen for @$lines;
    my @padded = map { $_ . (' ' x ($maxlen - length($_))) } @$lines;

    my @transposed;
    for my $c (0 .. $maxlen-1) {
        my $s = join('', map { substr($_, $c, 1) } @padded);
        push @transposed, $s;
    }

    # group contiguous digit columns
    my @groups;
    my $current = [];
    for my $col (@transposed) {
        if ($col =~ /\d/) {
            push @$current, $col;
        } else {
            if (@$current) {
                push @groups, [ map { int($_) } @$current ];
                $current = [];
            }
        }
    }
    if (@$current) {
        push @groups, [ map { int($_) } @$current ];
    }
    return \@groups;
}

sub eval_and_print {
    my ($label, $ops, $cols) = @_;
    my $total = 0;
    print "\n--- $label ---\n";
    for my $i (0 .. $#$ops) {
        my $op = $ops->[$i];
        my @nums = @{ $cols->[$i] };
        my $res;
        if ($op eq '+') {
            $res = 0; $res += $_ for @nums;
        } elsif ($op eq '*') {
            $res = 1; $res *= $_ for @nums;
        }
        print "$op on [@nums] -> $res\n";
        $total += $res;
    }
    print "$label Total = $total\n";
    return $total;
}

sub solve {
    my ($filename) = @_;
    open my $fh, '<', $filename or die "Cannot open $filename: $!";
    my @data = grep { /\S/ } map { chomp; $_ } <$fh>;
    close $fh;

    my $op_line = $data[-1];
    my @body = @data[0 .. $#data-1];
    my $ops = parse_ops($op_line);

    # L2R
    my $l2r_cols = parse_grid_tokens(\@body);
    my $total_l2r = eval_and_print("Left-to-Right", $ops, $l2r_cols);

    # R2L
    my $r2l_cols = [ reverse @{ parse_grid_constructed(\@body) } ];
    my $rev_ops  = [ reverse @$ops ];
    my $total_r2l = eval_and_print("Right-to-Left", $rev_ops, $r2l_cols);

    return ($total_l2r, $total_r2l);
}

my ($l2r, $r2l) = solve("input/day06.txt");
print "\nDay 6 Answer (Left-to-Right): $l2r\n";
print "Day 6 Answer (Right-to-Left): $r2l\n";
