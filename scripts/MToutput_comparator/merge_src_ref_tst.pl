#!/usr/bin/env perl

use utf8;
use strict;
use warnings;
#use autodie;
binmode STDOUT, ':utf8';
my $USAGE= "Usage: perl $0 src=<source_filename> ref=<reference_filename> <system1_name>=<system1_filename> <system2_name>=<system2_filename>";

die $USAGE if @ARGV != 4;
my ($src_name, $src_fn, $ref_name, $ref_fn, $test1_name, $test1_fn, $test2_name, $test2_fn) = map {split /=/, $_, 2} @ARGV;
die $USAGE if $src_name ne 'src' || $ref_name ne 'ref' || !defined $test2_fn;

my $SR = my_open($src_fn);
my $RF = my_open($ref_fn);
my $T1 = my_open($test1_fn);
my $T2 = my_open($test2_fn);
print "#sentence_number|id\tsrc=$src_fn\tref=$ref_fn\t$test1_name=$test1_fn\t$test2_name=$test2_fn\n";

my $n = 1;
while(my $sr = <$SR> ){
    chomp $sr;
    my $rf = <$RF>; die "Sentence #$n: no reference" if !defined $rf; chomp $rf;
    my $t1 = <$T1>; die "Sentence #$n: no test1" if !defined $t1; chomp $t1;
    my $t2 = <$T2>; die "Sentence #$n: no test2" if !defined $t2; chomp $t2;
    print "n=$n|id=?\t$sr\t$rf\t$t1\t$t2\n";
    $n++;
}


sub my_open {
  my $f = shift;
  if ($f eq "-") {
    binmode(STDIN, ":utf8");
    return *STDIN;
  }

  die "Not found: $f" if ! -e $f;

  my $opn;
  my $hdl;
  my $ft = `file '$f'`;
  # file might not recognize some files!
  if ($f =~ /\.gz$/ || $ft =~ /gzip compressed data/) {
    $opn = "zcat '$f' |";
  } elsif ($f =~ /\.bz2$/ || $ft =~ /bzip2 compressed data/) {
    $opn = "bzcat '$f' |";
  } else {
    $opn = "$f";
  }
  open $hdl, $opn or die "Can't open '$opn': $!";
  binmode $hdl, ":utf8";
  return $hdl;
}

# Copyright 2010 Martin Popel, Ondřej Bojar
# License: GNU GPL
