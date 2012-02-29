#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Std;

binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";

my %options=();
getopts("b:w:", \%options);

my @list;

while (<>) {
    chomp;
    if ( $_ =~ /^#/ ) {
        print "$_\n";
    }
    elsif ( $_ =~ /diff=(-?\d+)\s/ && $1 != 0 ) {
        push @list, [$_, $1];
    }
}

my @sorted = map { $_->[0] } sort { $a->[1] <=> $b->[1] } @list;
my @best = splice ( @sorted, 0, $options{'b'} ) if $options{'b'};
my @worst = splice ( @sorted, @sorted - $options{'w'}, @sorted ) if $options{'w'};

@sorted = (@best, @worst) if (@best || @worst);
print join( "\n", @sorted ), "\n";
 


