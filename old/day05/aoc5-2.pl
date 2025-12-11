#!/usr/bin/env perl
use strict;
use warnings;

my $INPUT_FILE = "aocdata.txt";

open my $fh, '<', $INPUT_FILE or die "Cannot open $INPUT_FILE: $!";
my @ranges;
while (my $line = <$fh>) {
    chomp $line;
    last if $line =~ /^\s*$/;  # stop at blank line
    my ($start, $end) = split /-/, $line;
    push @ranges, [$start, $end];
}
close $fh;

# Sort ranges
@ranges = sort { $a->[0] <=> $b->[0] } @ranges;

# Merge
my @merged;
for my $r (@ranges) {
    my ($start, $end) = @$r;
    if (!@merged || $start > $merged[-1]->[1] + 1) {
        push @merged, [$start, $end];
    } else {
        $merged[-1]->[1] = $end if $end > $merged[-1]->[1];
    }
}

# Count
my $total = 0;
for my $m (@merged) {
    $total += $m->[1] - $m->[0] + 1;
}

print "Total fresh IDs: $total\n";
