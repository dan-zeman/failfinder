#!/usr/bin/perl

use utf8;
use strict;
use warnings;
#use autodie;
binmode STDOUT, ':utf8';

die "Usage: perl $0 source reference test1 test\n" if @ARGV != 4;
my ($source, $reference, $test1, $test2) = @ARGV;
open my $SR, '<:utf8', $source;
open my $RF, '<:utf8', $reference;
open my $T1, '<:utf8', $test1;
open my $T2, '<:utf8', $test2;
print "#id\tsource=$source\treference=$reference\ttest1=$test1\ttest2=$test2\n";

my $n = 1;
while(my $sr = <$SR> ){
	chomp $sr;
	my $rf = <$RF>; die "Sentence #$n: no reference" if !defined $rf; chomp $rf;
	my $t1 = <$T1>; die "Sentence #$n: no test1" if !defined $t1; chomp $t1;
	my $t2 = <$T2>; die "Sentence #$n: no test2" if !defined $t2; chomp $t2;
	print "no_id\t$sr\t$rf\t$t1\t$t2\n";
    $n++;
}

