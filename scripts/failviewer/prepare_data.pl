#!/usr/bin/perl -w

use strict;
use File::Path;
use File::Basename;
use File::Copy;

my $DATA = "data.js";
my $file = $ARGV[0];
my $line; 

my @CLASSES = qw(onlyA onlyB AandB);

my ($base,$dir,$ext) = fileparse($file, qr/\..*/);
#print("dir=$dir base=$base ext=$ext\n");

open(OUT, ">$DATA") or die "Cannot create output file $DATA, Error: $!\n";

#prepare headers  
my $header = "var header = Array(\n";
#print OUT "var values = Array(";
open(IN, "<$dir$base.header") or die "Cannot open input file $dir$base.header, Error: $!\n";
my $first = 1;
while($line=<IN>)
{
	chomp $line;
	$line =~ s/([^ ]+)/\"$1\"/g;
	$line =~ s/ /,/g;
	if($first == 1) {
		$header .= "Array($line)";
		#print OUT "Array($line)";
	}
	else{
		$header .= ",\nArray($line)";
		#print OUT ",\nArray($line)\n";
	}	
	$first = 0;
}
close(IN);
$header .= "\n);";
#print OUT "\n);";

print OUT "$header\n";

#prepare data  
my $data = "var orig_values = Array(\n";
#print OUT "var values = Array(";
open(IN, "<$dir$base.data") or die "Cannot open input file $dir$base.data, Error: $!\n";
$first = 1;
while($line=<IN>)
{
	chomp $line;
	$line =~ s/^([^ ]*)/\"$1\"/;
	$line =~ s/ /,/g;
	if($first == 1) {
		$data .= "Array($line)";
		#print OUT "Array($line)";
	}
	else{
		$data .= ",\nArray($line)";
		#print OUT ",\nArray($line)\n";
	}	
	$first = 0;
}
close(IN);
$data .= "\n);";
#print OUT "\n);";

print OUT "$data\n";


#prepare alignmments

my ($src_name, $ref_name, $tst1_name, $tst2_name ) = qw(SRC REF TST1 TST2);

my $alignments = "var alignments = Array(\n";
#print OUT "var values = Array(";
open(IN, "<$dir$base.align") or die "Cannot open input file $dir$base.align, Error: $!\n";
$first = 1;
my $nblines = 0;
while($line=<IN>)
{
	chomp $line;
    if ( $line =~ /^\#/ ) {
        $tst1_name = $1 if ( $line =~ /test1=([^\s]+)/ );
        $tst2_name = $1 if ( $line =~ /test2=([^\s]+)/ );
        next;
    }

	$line =~ s/\'/\\\'/g;
	$line =~ s/\"/\\\"/g;
	$line =~ s/,/\\,/g;	

	my ( $info, $src, $ref, $tst1, $tst2 ) = split ( /\t/, $line );
    #make an array of 4 items SRC, REF, SYS1, SYS2
   
    my $pref = print_sentence($ref);
   	my $ptst1 = print_sentence($tst1);
   	my $ptst2 = print_sentence($tst2);
    
    if($first == 1) {
		$alignments .= "Array(\"$src\", \"". $pref . "\", \"". $ptst1 ."\", \"". $ptst2 ."\")";
	}
	else{
		$alignments .= ",\nArray(\"$src\", \"". $pref . "\", \"". $ptst1 ."\", \"". $ptst2 ."\")";
	}	
	
	$first = 0;
	$nblines++;
}
close(IN);
$alignments .= "\n);";
#print OUT "\n);";

print OUT "$alignments\n";


#prepare FAKE errors
my $errors = "var errors = Array(\n";
#print OUT "var errors = Array(";

#open(IN, "<$dir$base.errors") or die "Cannot open input file $dir$base.errors, Error: $!\n";
#$first=1;
#while($line=<IN>)
#{
#	chomp $line;
#}
#close(IN);

my @fakeerrors = ("0,0,0,0,0", "1,0,1,0,0", "0,1,0,0,1", "0,1,0,1,0", "0,1,1,1,0", "1,1,0,1,0", "1,0,0,1,1", "1,1,1,1,1");
$first = 1;

for(my $i=0; $i<$nblines; $i++)
{
	my $j = $i % $#fakeerrors;
	
	if($first == 1)
	{
		$errors .= "Array(" . $fakeerrors[$j] . ")";
	}
	else
	{
		$errors .= ",\nArray(" . $fakeerrors[$j] . ")";
	}
	
	$first = 0;
}
$errors .= "\n);";
#print OUT "\n);";

print OUT "$errors\n";

print OUT "var errors_names = Array('SEARCH','REACH','MODEL','SRC','KEYBOARD-TO-CHAIR');\n";

close(OUT);


#######################################
#######################################
############# FUNCTIONS ###############
#######################################
#######################################

sub print_sentence {
    
    my $sentence = shift;
    my $output;

    # separate brackets
    $sentence =~ s/(\[\[\[|\]\]\]|\{\{\{|\}\}\})/\t$1\t/g;
    $sentence =~ s/\t+/\t/g;
    $sentence =~ s/^\t*(.+)\t*$/$1/;

    my @chunks = split ( /\t/, $sentence );
    my $in_square = 0;
    my $in_curly = 0;
    my $state = 0;
    
    foreach my $chunk (@chunks) {
        if ( $chunk eq '[[[') {
            $in_square = 1;
        }
        elsif ( $chunk eq ']]]' ) {
            $in_square = 0;
        }
        elsif ( $chunk eq '{{{') {
            $in_curly = 1;
        }
        elsif ( $chunk eq '}}}' ) {
            $in_curly = 0;
        }
        else {
            my $new_state = $in_square * 2 + $in_curly;
            if ( $new_state != $state ) {
                $output .= "</span>" if $state != 0;
                $output .= "<span class=\\'" . $CLASSES[$new_state - 1] . "\\'>" if $new_state != 0;
            }
            $state = $new_state;
            $output .= $chunk;
        }
    }
    $output .= "</span>" if $state != 0;
    return $output;
}



