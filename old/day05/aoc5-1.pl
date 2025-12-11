#!/usr/bin/env perl
use strict;
use warnings;

my $INPUT_FILE = "aocdata.txt";

open my $fh, '<', $INPUT_FILE or die "Cannot open $INPUT_FILE: $!";
my @lines = ();
while (my $line = <$fh>) {
    chomp $line;
    push @lines, $line;
}
close $fh;

# Split ranges and IDs at blank line
my $split_index;
for my $i (0..$#lines) {
    if ($lines[$i] =~ /^\s*$/) {
        $split_index = $i;
        last;
    }
}
die "No blank line separating ranges and IDs" unless defined $split_index;

my @ranges = @lines[0..$split_index-1];
my @ids    = @lines[$split_index+1..$#lines];

sub parse_ranges {
    my @range_lines = @_;
    my @ranges;
    for my $line (@range_lines) {
        my ($start, $end) = split /-/, $line;
        push @ranges, [$start, $end];
    }
    return @ranges;
}

sub is_fresh {
    my ($id, $ranges_ref) = @_;
    for my $r (@$ranges_ref) {
        my ($start, $end) = @$r;
        return 1 if $id >= $start && $id <= $end;
    }
    return 0;
}

my @parsed_ranges = parse_ranges(@ranges);
my @fresh_ids = grep { is_fresh($_, \@parsed_ranges) } @ids;

print "Total available IDs: " . scalar(@ids) . "\n";
print "Fresh IDs: " . scalar(@fresh_ids) . "\n";
# print "List of fresh IDs: " . join(", ", @fresh_ids) . "\n";
