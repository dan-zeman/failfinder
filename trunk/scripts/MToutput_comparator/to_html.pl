#!/usr/bin/perl

use utf8;
use strict;
use warnings;
use Getopt::Long;

binmode STDIN,  ':utf8';
binmode STDOUT, ':utf8';

my $NGRAMS = undef;
my $BRACKETS = 1;

GetOptions(
    'ngrams=s' => \$NGRAMS,
);

my ( $system1, $system2, $maxn ) = ( undef, undef, 0 );
my @ngram_table;
my ( $lines,       $rows )      = ( 0, 0 );
my ( $UNCONFIRMED, $CONFIRMED ) = ( 0, 1 );
my @CLASSES = qw(onlyA onlyB AandB alone);
if ( defined $NGRAMS ) { read_ngrams($NGRAMS); }

sub read_ngrams {
    my ($ngram_filename) = @_;
    open my $NF, '<:utf8', $ngram_filename;
    my ($target);
    LINE:
    while (<$NF>) {
        chomp;
        if ( my ( $un, $n, $s1, $s2, $p ) = /^#([^c]*)confirmed (\d+)-gram diffs .([^ ]+) - ([^)]+). ([<>])/ ) {
            if ( !defined $system1 && !defined $system2 ) {
                ( $system1, $system2 ) = ( $s1, $s2 );
            }
            elsif ( $system1 ne $s1 || $system2 ne $s2 ) {
                die "Different system names: $system1 ne $s1 || $system2 ne $s2";
            }
            if ( $n > $maxn ) { $maxn = $n; }
            my $confirmed = $un ? $UNCONFIRMED : $CONFIRMED;
            my $positive = $p eq '>' ? 1 : 0;
            $target = $ngram_table[$confirmed][$n][$positive] = [];
            next LINE;
        }
        my ( $diff, $ngram, $line_numbers ) = split /\t/, $_;
        $ngram =~ s/'/&apos;/g;
        $ngram =~ s/</&lt;/g;
        $ngram =~ s/>/&gt;/g;
        $ngram =~ s/"/&quot;/g;    #TODO de-escape later
        push @{$target}, [ $diff, $ngram, $line_numbers ];
    }
    if ( @{$target} > $rows ) { $rows = @{$target}; }
    close $NF;
}

sub print_ngram {
    my ( $a, $diff, $ngram, $line_numbers ) = @_;
    if ( !defined $diff ) {
        print " <td class='n $a'></td><td class='$a'></td>\n";
    }
    else {
        my ($first_number) = split / /, $line_numbers, 2;
        print "  <td class='n $a'>$diff</td>",
            "<td class='$a'><a href='#s$first_number'",
            " onclick=\"filter('$line_numbers','$ngram')\">$ngram</a></td>\n";
    }
    return;
}

sub print_ngram_table {
    my ($confirmed) = @_;
    my $descript = $confirmed ? 'confirmed' : 'unconfirmed';
    my $wins     = $confirmed ? 'wins'      : 'loses';
    print "<div id='$descript'>\n <span>n-grams $descript by the reference</span><br/>\n";

    for my $n ( 1 .. $maxn ) {
        next if !$ngram_table[$confirmed][$n];
        print "<table class='gram$n'>\n";
        print "<caption>$n-gram</caption>";
        print "<tr><th colspan='2' class='a'>$system1 $wins</th><th colspan='2' class='b'>$system2 $wins</th></tr>\n";
        for my $row ( 0 .. $rows - 1 ) {
            print " <tr>\n";
            print_ngram( 'a', @{ $ngram_table[$confirmed][$n][1][$row] } );
            print_ngram( 'b', @{ $ngram_table[$confirmed][$n][0][$row] } );
            print " </tr>\n";
        }
        print "</table><!--class gram$n-->\n";
    }

    print "</div><!--id $descript-->\n";

    return;
}

sub print_sentences {
    my $header = <>;
    print "<div id='sentences'>\n";
    while (<>) {
        chomp;
        my ( $info, $sr, $rf, $t1, $t2 ) = split /\t/, $_;
        ( $rf, $t1, $t2 ) = map { preprocess_sentence($_) } ( $rf, $t1, $t2 );
        $lines++;
        my @ngc1 = ( $info =~ /ngc1=\[([\d,]+)\]/ ) ? split (',', $1) : (0, 0, 0, 0);
        my @ngc2 = ( $info =~ /ngc2=\[([\d,]+)\]/ ) ? split (',', $1) : (0, 0, 0, 0);
        my $id = ( $info =~ /id=(\S+)/ ) ? $1 : '?';
        my $diff = ( $info =~ /diff=(\S+)/ ) ? $1 : '?';
        my $sentence_number = ( $info =~ /n=(\d+)/ ) ? $1 : $lines;
        print "<div class='sentence' id='s$sentence_number'>\n";
        print " <div class='sent_info'>sentence #$sentence_number\&nbsp;\&nbsp;\&nbsp;ID: $id\&nbsp;\&nbsp;\&nbsp; Matching n-grams: $system1 - $system2 = $diff</div>\n";
        print " <div class='src'><div class='info'>SRC:</div> $sr </div>\n";
        print " <div class='ref'><div class='info'>REF:</div><div class='t'> $rf </div></div>\n";
        print " <div class='tstA'><div class='info'>$system1:\&nbsp;\&nbsp;\&nbsp;
        1-grams: $ngc1[0],\&nbsp;\&nbsp;\&nbsp;
        2-grams: $ngc1[1],\&nbsp;\&nbsp;\&nbsp;
        3-grams: $ngc1[2],\&nbsp;\&nbsp;\&nbsp;
        4-grams: $ngc1[3]</div><div class='t'> $t1 </div></div>\n";
        print " <div class='tstB'><div class='info'>$system2:\&nbsp;\&nbsp;\&nbsp;
        1-grams: $ngc2[0],\&nbsp;\&nbsp;\&nbsp;
        2-grams: $ngc2[1],\&nbsp;\&nbsp;\&nbsp;
        3-grams: $ngc2[2],\&nbsp;\&nbsp;\&nbsp;
        4-grams: $ngc2[3]</div><div class='t'> $t2 </div></div>\n";
        print "</div>\n";
    }
    print "</div><!--sentences-->\n";
    return;
}

sub preprocess_sentence {
    return $BRACKETS ? convert_brackets(@_) : tokenize(@_);
}

sub convert_brackets {
    my $sentence = shift;
    my $output   = '';

    # separate brackets
    $sentence =~ s/(\[\[\[|\]\]\]|\{\{\{|\}\}\}|<<<|>>>)/\t$1\t/g;
    $sentence =~ s/\t+/\t/g;
    $sentence =~ s/^\t*(.+)\t*$/$1/;

    my @chunks    = split( /\t/, $sentence );
    my $in_square = 0;
    my $in_curly  = 0;
    my $in_angle  = 0;
    my $state     = 0;

    foreach my $chunk (@chunks) {
        if ( $chunk eq '[[[' ) {
            $in_square = 1;
        }
        elsif ( $chunk eq ']]]' ) {
            $in_square = 0;
        }
        elsif ( $chunk eq '{{{' ) {
            $in_curly = 1;
        }
        elsif ( $chunk eq '}}}' ) {
            $in_curly = 0;
        }
        elsif ( $chunk eq '<<<' ) {
            $in_angle = 1;
        }
        elsif ( $chunk eq '>>>' ) {
            $in_angle = 0;
        }
        else {
            my $new_state = $in_square + $in_curly * 2;
              # 0 for none, 1 for curly only, 2 for square only, 3 for both
            $new_state = 4 if $new_state == 0 && $in_angle;
              # 4 for alone
            if ( $new_state != $state ) {
                $output .= ' </span>' if $state != 0;
                $output .= '<span class="' . $CLASSES[ $new_state - 1 ] . '"> ' if $new_state != 0;
            }
            $state = $new_state;
            $output .= $chunk;
        }
    }
    $output .= ' </span>' if $state != 0;
    return $output;
}

sub tokenize {
    my ($string) = @_;
    $string =~ s/(\W)/ $1 /g;
    $string =~ s/\s+/ /g;
    $string =~ s/^ //;
    $string =~ s/ $//;
    return $string;
}

sub print_header {
    my ($header_filename) = @_;
    open my $HF, '<:utf8', $header_filename;
    while (<$HF>) { print; }
    close $HF;
}

sub print_menu {
    print "<div id='menu'>
    Show: <fieldset>Sentences
    <input type='checkbox' checked='checked' onclick='hide_show(sent_infos,this)' />info
    <input type='checkbox' checked='checked' onclick='hide_show(infos,this)' />names
    <input type='checkbox' checked='checked' onclick='hide_show(sources,this)' /><span class='src'>src</span>
    <input type='checkbox' checked='checked' onclick='hide_show(references,this)' /><span class='ref'>ref</span>
    <input type='checkbox' checked='checked' onclick='hide_show(tests1,this)' /><span class='tstA'>$system1</span>
    <input type='checkbox' checked='checked' onclick='hide_show(tests2,this)' /><span class='tstB'>$system2</span>
    </fieldset>
    <fieldset><a href='#ngrams'>N-gram stats</a>";
    print "<input type='checkbox' checked='checked' onclick=\"confirmed.style.display=this.checked?'block':'none'\"/>confirmed
    <input type='checkbox' checked='checked' onclick=\"unconfirmed.style.display=this.checked?'block':'none'\"/>unconfirmed\n";
    print "</fieldset>\n";
    print "<input id = 'show_all_button' type = 'button' onclick = 'show_all_sentences()' value = 'Show all sentences' />\n";
    print "</div>\n";
    return;
}

print_header('header_template.html');
print "<body onload='prepare()'>\n";
print_menu();
print "<div id='nonmenu'>\n";
if ( defined $NGRAMS ) {
    print "<div id='ngrams'>\n";
    print_ngram_table($CONFIRMED);
    print_ngram_table($UNCONFIRMED);
    print "</div><!--ngrams-->\n";
}

print_sentences();
print "</div>\n</body>\n</html>\n";

# Copyright 2010 Martin Popel <popel@ufal.mff.cuni.cz>, David Mareček <marecek@ufal.mff.cuni.cz>, Ondrej Bojar <bojar@ufal.mff.cuni.cz>
# License: GNU GPL
