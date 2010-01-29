#!/usr/bin/perl

use strict;
use warnings;

use List::MoreUtils qw(any all);

binmode STDIN, "utf8";
binmode STDOUT, "utf8";

sub tokenize {
    my $sentence = shift;
    $sentence =~ s/(\W)/ $1 /g;
    $sentence =~ s/\s+/ /g;
    $sentence =~ s/^\s*(.*)\s*$/$1/;
    return split ( /\s/, $sentence);
}

sub matching_ngrams {
    my ($sent1, $sent2) = @_;
    
    my %tok2pos;
    for ( my $i = 0; $i < @$sent1; $i++ ) {
        push @{$tok2pos{$$sent1[$i]}}, $i;
    }

    my @ngrams;
    my @ngram_count = (0, 0, 0, 0);
    my %counted;
    for ( my $j = 0; $j < @$sent2; $j++ ) {
        foreach my $i ( @{$tok2pos{$$sent2[$j]}} ) {
            my $n = 0;
            while ( ($i + $n < @$sent1) && ($j + $n < @$sent2) && ($$sent1[$i + $n] eq $$sent2[$j + $n]) ) {
                if ( $n < 4 && !$counted{"$j $n"} ) {
                    $counted{"$j $n"} = 1;
                    $ngram_count[$n]++ if $n < 4 ;
                }
                if ( !defined $ngrams[$n]) {
                    $ngrams[$n] = [[$i, $j]];
                }
                else {
                    push @{$ngrams[$n]}, [$i, $j];
                }
                $n++;
            }
        }
    }

    my @used1;
    my @used2;
    my @brackets1;
    my @brackets2;
    my $n = $#ngrams;
    while ( $n >= 0 ) {
        foreach my $ngram ( @{$ngrams[$n]} ) {
            if ( ( !all { defined $used1[$_] } ( $ngram->[0] .. ($ngram->[0] + $n) ) )
              && ( !all { defined $used2[$_] } ( $ngram->[1] .. ($ngram->[1] + $n) ) ) ) {
                map { $used1[$_] = 1} ( $ngram->[0] .. ($ngram->[0] + $n) );
                map { $used2[$_] = 1} ( $ngram->[1] .. ($ngram->[1] + $n) );
                push @brackets1, [$ngram->[0], $ngram->[0] + $n];
                push @brackets2, [$ngram->[1], $ngram->[1] + $n];
            }
        }
        $n--;
    }
    return (\@brackets1, \@brackets2, \@ngram_count);
}

while (<>) {
    chomp;
    if ($_ =~ /^#/) {
        print "$_\n";
        next;
    }
    my ( $info, $src, $ref, $tst1, $tst2 ) = split ( /\t/, $_ );
    my @ref = tokenize($ref);
    my @tst1 = tokenize($tst1);
    my @tst2 = tokenize($tst2);

    my ($ref1_brackets, $tst1_brackets, $count1) = matching_ngrams( \@ref, \@tst1 );
    my ($ref2_brackets, $tst2_brackets, $count2) = matching_ngrams( \@ref, \@tst2 );
    
    foreach my $brackets (@$ref1_brackets) {
        $ref[$brackets->[0]] = '[[['.$ref[$brackets->[0]];
        $ref[$brackets->[1]] .= ']]]';
    }
    foreach my $brackets (@$tst1_brackets) {
        $tst1[$brackets->[0]] = '[[['.$tst1[$brackets->[0]];
        $tst1[$brackets->[1]] .= ']]]';
    }
    foreach my $brackets (@$ref2_brackets) {
        $ref[$brackets->[0]] = '{{{'.$ref[$brackets->[0]];
        $ref[$brackets->[1]] .= '}}}';
    }
    foreach my $brackets (@$tst2_brackets) {
        $tst2[$brackets->[0]] = '{{{'.$tst2[$brackets->[0]];
        $tst2[$brackets->[1]] .= '}}}';
    }

    my $diff = 0;
    foreach my $c (@$count1) { $diff += $c; }
    foreach my $c (@$count2) { $diff -= $c; }

    print "$info ngc1=[".join(",",@$count1)."] ngc2=[".join(",",@$count2)."] diff=$diff\t$src\t".join( " ", @ref )."\t".join( " ", @tst1 )."\t".join(" ",@tst2)."\n";
}

