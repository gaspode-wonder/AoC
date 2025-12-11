use strict;
use warnings;

my %PUZZLES;

sub register {
    my ($day, $func) = @_;
    $PUZZLES{$day} = $func;
}

sub run {
    my ($day) = @_;
    $PUZZLES{$day}->();
}

1;
