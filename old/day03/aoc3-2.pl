#!/usr/bin/perl
use strict;
use warnings;

sub largest_bank_number {
    my ($line, $k) = @_;   # $k = length of number to build (12)
    my @digits = grep { /^\d$/ } split //, $line;
    my $n = scalar(@digits);

    return -1 if $n < $k;  # not enough digits

    my @result;
    my $to_pick = $k;
    my $start = 0;

    # Greedy selection: at each step, pick the largest digit possible
    while ($to_pick > 0) {
        # Remaining digits we must leave room for
        my $end = $n - $to_pick;
        my $max_digit = -1;
        my $pos = $start;

        # Find the largest digit we can pick within the allowed window
        for my $i ($start .. $end) {
            if ($digits[$i] > $max_digit) {
                $max_digit = $digits[$i];
                $pos = $i;
            }
        }

        push @result, $max_digit;
        $start = $pos + 1;
        $to_pick--;
    }

    return join("", @result);
}

# Read from aocdata.txt
my $filename = "aocdata.txt";
open my $fh, '<', $filename or die "Could not open '$filename': $!";

my $sum = 0;

while (my $line = <$fh>) {
    chomp $line;
    next if $line =~ /^\s*$/;  # skip blank lines
    my $largest = largest_bank_number($line, 12);
    print "Bank: $line -> Largest possible 12-digit number: $largest\n" if $largest ne "-1";
    $sum += $largest if $largest ne "-1";
}

close $fh;

print "Total sum of largest 12-digit numbers: $sum\n";
