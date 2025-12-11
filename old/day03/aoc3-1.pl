#!/usr/bin/perl
use strict;
use warnings;

sub largest_bank_number {
    my ($line) = @_;
    my @digits = grep { /^\d$/ } split //, $line;

    return -1 if @digits < 2;

    # Build suffix max array: max digit strictly to the right of position i
    my @sufmax = (-1) x scalar(@digits);
    my $current_max = -1;
    for (my $i = $#digits; $i >= 0; $i--) {
        $sufmax[$i] = $current_max;
        $current_max = $digits[$i] if $digits[$i] > $current_max;
    }

    my $best_val = -1;
    my $best_str = "-1";

    for my $i (0 .. $#digits - 1) {
        my $right_max = $sufmax[$i];
        next if $right_max == -1;  # nothing to the right
        my $val = $digits[$i] * 10 + $right_max;
        if ($val > $best_val) {
            $best_val = $val;
            $best_str = $digits[$i] . $right_max;
        }
    }

    return $best_val;  # return the two-digit number as an integer
}

# Read from aocdata.txt
my $filename = "aocdata.txt";
open my $fh, '<', $filename or die "Could not open '$filename': $!";

my $sum = 0;

while (my $line = <$fh>) {
    chomp $line;
    next if $line =~ /^\s*$/;  # skip blank lines
    my $largest = largest_bank_number($line);
    print "Bank: $line -> Largest possible number: $largest\n" if $largest != -1;
    $sum += $largest if $largest != -1;
}

close $fh;

print "Total sum of largest numbers: $sum\n";
