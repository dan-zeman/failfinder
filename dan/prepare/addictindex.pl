#!/usr/bin/perl
# Indexes parallel training data for viewing in Addicter.
# Copyright © 2010 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
sub usage
{
    print STDERR ("Usage: addictindex.pl <options>\n");
    print STDERR ("Options:\n");
    print STDERR ("  -trs path ... path to source side of training data\n");
    print STDERR ("  -trt path ... path to target side of training data\n");
    print STDERR ("  -tra path ... path to alignment file for training data\n");
    print STDERR ("  -s path ..... path to source side of test data\n");
    print STDERR ("  -r path ..... path to reference translation of test data\n");
    print STDERR ("  -h path ..... path to system output (hypothesis) for test data\n");
    print STDERR ("  -ra path .... path to alignment of source and reference\n");
    print STDERR ("  -ha path .... path to alignment of source and hypothesis\n");
    print STDERR ("  -o path ..... path to output folder (number of index files will go there; default '.')\n");
}

use open ":utf8";
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");
use Getopt::Long;
use dzsys;

$opath = '.';
GetOptions
(
    'trs=s' => \$trspath,
    'trt=s' => \$trtpath,
    'tra=s' => \$trapath,
    's=s'   => \$spath,
    'r=s'   => \$rpath,
    'h=s'   => \$hpath,
    'ra=s'  => \$rapath,
    'ha=s'  => \$hapath,
    'o=s'   => \$opath
);
if($trspath eq '' || $trtpath eq '' || $trapath eq '')
{
    usage();
    die("Training data input paths are mandatory. The output path defaults to '.'.\n");
}
# Build index.
print STDERR ("Reading the training corpus...\n");
index_corpus('training', $trspath, $trtpath, $trapath, \%index, $opath);
if($spath ne '' && $rpath ne '' && $rapath ne '')
{
    print STDERR ("Reading the reference test data...\n");
    index_corpus('test', $spath, $rpath, $rapath, \%index, $opath);
}
if($spath ne '' && $hpath ne '' && $hapath ne '')
{
    print STDERR ("Reading the system output...\n");
    index_corpus('test.system', $spath, $hpath, $hapath, \%index, $opath);
}
# To speed up reading the index, do not save it in one huge file.
# Instead, split it up according to the first letters of the words.
# Collect the first characters of the indexed words.
@keys = sort(keys(%index));
map {$_ =~ m/^(.)/; $firstletters{$1}++} (@keys);
print STDERR ("The words in the corpus begin in ", scalar(keys(%firstletters)), " distinct characters.\n");
# Print the master index (list of first letters).
$indexname = "$opath/index.txt";
open(INDEX, ">$indexname") or die("Cannot write $indexname: $!\n");
print INDEX (join(' ', sort(keys(%firstletters))), "\n");
close(INDEX);
# Print the index.
my $last_fl;
foreach my $key (@keys)
{
    # Choose target index file according to the first letter.
    # The keys are sorted, so keys with starting letter A should not be interrupted by other keys.
    $key =~ m/^(.)/;
    my $fl = $1;
    if($fl ne $last_fl)
    {
        close(INDEX) unless($last_fl eq '');
        my $indexname = sprintf("$opath/index%04x.txt", ord($fl));
        open(INDEX, ">$indexname") or die("Cannot write $indexname: $!\n");
        print STDERR ("Writing index $indexname for words beginning in $fl...\n");
        $last_fl = $fl;
    }
    # Warning: The aliphrase can contain both colons and spaces. Hopefully it cannot contain tabs.
    my @links = map{"$_->{file}:$_->{line}:$_->{aliphrase}"} (@{$index{$key}});
    print INDEX ("$key\t", join("\t", @links), "\n");
}
close(INDEX);



###############################################################################
# SUBROUTINES
###############################################################################



#------------------------------------------------------------------------------
# Indexes a parallel corpus (source + target + alignment). For every word type
# notes all occurrences (positions + alignment-based glosses).
#------------------------------------------------------------------------------
sub index_corpus
{
    my $corptype = shift; # affects the file codes saved with word occurrences
    my $spath = shift;
    my $tpath = shift;
    my $apath = shift;
    my $index = shift; # Reference to the index hash.
    my $opath = shift; # Output path to copy the input files to.
    my ($sid, $tid);
    if($corptype eq 'training')
    {
        $sid = 'TRS';
        $tid = 'TRT';
        $ospath = "$opath/train.src";
        $otpath = "$opath/train.tgt";
        $oapath = "$opath/train.ali";
    }
    elsif($corptype eq 'test')
    {
        $sid = 'S';
        $tid = 'R';
        $ospath = "$opath/test.src";
        $otpath = "$opath/test.tgt";
        $oapath = "$opath/test.ali";
    }
    elsif($corptype eq 'test.system')
    {
        $sid = 'S';
        $tid = 'H';
        $ospath = "$opath/test.src";
        $otpath = "$opath/test.system.tgt";
        $oapath = "$opath/test.system.ali";
    }
    my $hsrc = dzsys::gopen($spath);
    my $htgt = dzsys::gopen($tpath);
    my $hali = dzsys::gopen($apath);
    open(OSRC, ">$ospath") or die("Cannot write $ospath: $!\n");
    open(OTGT, ">$otpath") or die("Cannot write $otpath: $!\n");
    open(OALI, ">$oapath") or die("Cannot write $oapath: $!\n");
    my $i_sentence = 0;
    while(1)
    {
        # Sanity check: All three files must have the same number of lines.
        if(eof($hsrc) && eof($htgt) && eof($hali))
        {
            last;
        }
        elsif(eof($hsrc) || eof($htgt) || eof($hali))
        {
            print STDERR ("WARNING! Source, target or alignment differ in number of sentences (eof at line no. $i_sentence).\n");
        }
        my $srcline = <$hsrc>;
        my $tgtline = <$htgt>;
        my $aliline = <$hali>;
        # Copy the lines just read to the output folder.
        print OSRC ($srcline);
        print OTGT ($tgtline);
        print OALI ($aliline);
        # Chop off the line break.
        $srcline =~ s/\r?\n$//;
        $tgtline =~ s/\r?\n$//;
        $aliline =~ s/\r?\n$//;
        my @srcwords = split(/\s+/, $srcline);
        my @tgtwords = split(/\s+/, $tgtline);
        my @alignments = map {my @a = split(/-/, $_); \@a} (split(/\s+/, $aliline));
        for(my $i = 0; $i<=$#srcwords; $i++)
        {
            my %record =
            (
                'file' => $sid,
                'line' => $i_sentence,
                'aliphrase' => join(' ', map {$tgtwords[$_->[1]]} (grep {$_->[0]==$i} (@alignments)))
            );
            push(@{$index->{$srcwords[$i]}}, \%record);
        }
        for(my $i = 0; $i<=$#tgtwords; $i++)
        {
            my %record =
            (
                'file' => $tid,
                'line' => $i_sentence,
                'aliphrase' => join(' ', map {$srcwords[$_->[0]]} (grep {$_->[1]==$i} (@alignments)))
            );
            push(@{$index->{$tgtwords[$i]}}, \%record);
        }
        $i_sentence++;
    }
    close($hsrc);
    close($htgt);
    close($hali);
    close(OSRC);
    close(OTGT);
    close(OALI);
    print STDERR ("Found $i_sentence word-aligned sentence pairs.\n");
    print STDERR ("The index contains ", scalar(keys(%{$index})), " distinct words (both source and target).\n");
}
