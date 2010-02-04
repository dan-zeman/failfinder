#!/usr/bin/perl

use utf8;
use strict;
use warnings;
use Getopt::Long;

binmode STDIN,  ':utf8';
binmode STDOUT, ':utf8';

my $FROM           = 1;
my $TO             = 3;
my $MIN_DIFF       = 2;
my $LIMIT          = 10;
my $MAX_OCCURENCES = 20;

GetOptions(
    'from=i'           => \$FROM,
    'to=i'             => \$TO,
    'min_diff=i'       => \$MIN_DIFF,
    'limit=i'          => \$LIMIT,
    'max_occurences=i' => \$MAX_OCCURENCES,
);

my ( $UNCONFIRMED, $CONFIRMED ) = ( 0, 1 );
my ( @t1_minus_t2, @occurences );

my $header = <>;
die "no header in input" if !$header || $header !~ /^#/;
my @h = split /\t/, $header;
die "Wrong header format" if @h != 5 || $h[3] !~ /=/ || $h[4] !~ /=/;
my ( $system1, undef ) = split /=/, $h[3];
my ( $system2, undef ) = split /=/, $h[4];

my $line = 1;
while (<>) {
    chomp;
    my ( $id, $src, $rf, $t1, $t2 ) = split /\t/, $_;
    process_segment( $rf, $t1, $t2, $line );
    $line++;
}

foreach my $n ( $FROM .. $TO ) {
    print_ngrams( $CONFIRMED,   $n );
    print_ngrams( $UNCONFIRMED, $n );
}

#---- subs
sub print_ngrams {
    my ( $confirmed, $n ) = @_;
    my $hash_ref = $confirmed ? $t1_minus_t2[$CONFIRMED][$n] : $t1_minus_t2[$UNCONFIRMED][$n];
    my $un = $confirmed ? '' : 'un';
    my @positive = grep { $hash_ref->{$_} >= $MIN_DIFF } keys %{$hash_ref};
    my @negative = grep { $hash_ref->{$_} <= -$MIN_DIFF } keys %{$hash_ref};
    @positive = sort { $hash_ref->{$b} <=> $hash_ref->{$a} } @positive;
    @negative = sort { $hash_ref->{$a} <=> $hash_ref->{$b} } @negative;
    splice @positive, $LIMIT if @positive > $LIMIT;
    splice @negative, $LIMIT if @negative > $LIMIT;

    print "#${un}confirmed $n-gram diffs ($system1 - $system2) > 0\n";
    foreach my $ngram (@positive) {
        my $diff = $hash_ref->{$ngram};
        my $occ  = $occurences[$confirmed]{$ngram};
        $occ = $occ ? join ' ', @{$occ} : '';
        print "$diff\t$ngram\t$occ\n" if $diff;
    }

    print "#${un}confirmed $n-gram diffs ($system1 - $system2) < 0\n";
    foreach my $ngram (@negative) {
        my $diff = $hash_ref->{$ngram};
        my $occ  = $occurences[$confirmed]{$ngram};
        $occ = $occ ? join ' ', @{$occ} : '';
        print "$diff\t$ngram\t$occ\n" if $diff;
    }
    return;
}

sub process_segment {
    my ( $rf_str, $t1_str, $t2_str, $line ) = @_;
    my %is_confirmed;
    my ( $rf, $t1, $t2 ) = map { [ tokenize($_) ] } ( $rf_str, $t1_str, $t2_str );

    # Check reference translation, so we can quickly decide which n-grams are confirmed
    foreach my $ngram ( map { get_ngrams( $rf, $_ ) } ( $FROM .. $TO ) ) {
        $is_confirmed{$ngram}++;
    }

    # Process unigrams, bigrams, trigrams... (if $FROM==1 and $TO=3)
    foreach my $n ( $FROM .. $TO ) {
        my ( @minus, @count_t1, @count_t2 );

        # Score hypothesis 1
        foreach my $ngram ( get_ngrams( $t1, $n ) ) {
            my $confirmed = ( $count_t1[1]{$ngram} || 0 ) < ( $is_confirmed{$ngram} || 0 );
            $count_t1[$confirmed]{$ngram}++;
            $minus[$confirmed]{$ngram}++;
        }

        # Score hypothesis 2
        foreach my $ngram ( get_ngrams( $t2, $n ) ) {
            my $confirmed = ( $count_t2[1]{$ngram} || 0 ) < ( $is_confirmed{$ngram} || 0 );
            $count_t2[$confirmed]{$ngram}++;
            $minus[$confirmed]{$ngram}--;
        }

        # Add n-gram differences of this sentence to global differece
        foreach my $confirmed ( 0 .. 1 ) {
            for my $ngram ( grep { $minus[$confirmed]{$_} } keys %{ $minus[$confirmed] } ) {
                $t1_minus_t2[$confirmed][$n]{$ngram} += $minus[$confirmed]{$ngram};
                add_occurence( $ngram, $confirmed, $line );
            }
        }
    }
    return;
}

sub add_occurence {
    my ( $ngram, $confirmed, $line ) = @_;
    my $aref = $occurences[$confirmed]{$ngram};
    if ( !defined $aref ) {
        $occurences[$confirmed]{$ngram} = [$line];
    }
    elsif ( @{$aref} < $MAX_OCCURENCES ) {
        push @{$aref}, $line;
    }
}

sub get_ngrams {
    my ( $tokens_ref, $n ) = @_;
    my @ngrams = ();
    foreach my $start ( 0 .. @{$tokens_ref} - $n ) {
        my $ngram = join ' ', @{$tokens_ref}[ $start .. $start + $n - 1 ];
        push @ngrams, $ngram;
    }
    return @ngrams;
}

sub tokenize {
    my ($string) = @_;
    $string =~ s/(\W)/ $1 /g;
    $string =~ s/\s+/ /g;
    $string =~ s/^ //;
    $string =~ s/ $//;
    return split /\s/, $string;
}

# Copyright 2010 Martin Popel <popel@ufal.mff.cuni.cz>
# License: GNU GPL
