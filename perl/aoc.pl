#!/usr/bin/env perl
use strict;
use warnings;

# Load registry from the same directory as this script
require "./registry.pl";

# Auto-load all dayNN.pl files from the current directory
for my $file (glob("./day*.pl")) {
    require $file;
}

# CLI usage
my $day = shift @ARGV or die "Usage: $0 <day>\n";
run($day);
