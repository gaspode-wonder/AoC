#!/usr/bin/perl
use strict;
use warnings;
use Text::CSV;

# Path to your CSV file
my $file = "aocdata.csv";

# Create CSV parser
my $csv = Text::CSV->new({ binary => 1, auto_diag => 1 });

open my $fh, "<", $file or die "Could not open '$file': $!";

my $total = 0;

while (my $row = $csv->getline($fh)) {
    foreach my $field (@$row) {
        # Each field is a range like "11-22"
        if ($field =~ /^(\d+)-(\d+)$/) {
            my ($start, $end) = ($1, $2);

            for my $id ($start .. $end) {
                # Regex: number is some digits repeated twice
                if ($id =~ /^([1-9][0-9]*)\1+$/) {
                    print "Invalid ID found: $id\n";
                    $total += $id;
                }
            }
        }
    }
}

close $fh;

print "Sum of invalid IDs: $total\n";
