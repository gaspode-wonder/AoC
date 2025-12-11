# Source - https://stackoverflow.com/a
# Posted by Michael Carman, modified by community. See post 'Timeline' for change history
# Retrieved 2025-12-02, License - CC BY-SA 3.0
use strict;
use warnings;
use Text::CSV;

my $file = 'aocdata.csv';
my @data;
#my $total=0;
open(my $fh, '<', $file) or die "Can't read file '$file' [$!]\n";
while (my $line = <$fh>) {
    chomp $line;
    my @fields = split(/,/, $line);
    push @data, \@fields;
}

print @data

=begin comment
foreach my $row (@data) {
    if (my $line =~ /\b(\d+)\1+\b/) {
        my $total++;
        print "$total\n";
    }
}
=end comment