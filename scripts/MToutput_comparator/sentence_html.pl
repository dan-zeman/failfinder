#!/usr/bin/perl

use strict;
use warnings;

binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";

my @CLASSES = qw(onlyA onlyB AandB);

print "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\">
<html>
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">
<head>

<style>
.onlyA { background-color: #ff8888 }
.onlyB { background-color: #8888ff }
.AandB { background-color: #bb55bb }
.info { padding: 0px; font-size: 10pt; font-weight: bold; color: #550055 }
.src { color: black; padding: 5px; background-color: #eeeeee }
.ref { color: black; padding: 5px; background-color: #ddaadd }
.tst1 { color: black; padding: 5px; background-color: #ccccff }
.tst2 { color: black; padding: 5px; background-color: #ffcccc }
h6 { font-size: 10pt; margin: 1px }
</style>

<script language=javascript>

function changecss(theClass,element,value) {
	 var cssRules;

	 var added = false;
	 for (var S = 0; S < document.styleSheets.length; S++){

    if (document.styleSheets[S]['rules']) {
	  cssRules = 'rules';
	 } else if (document.styleSheets[S]['cssRules']) {
	  cssRules = 'cssRules';
	 } else {
	  //no rules found... browser unknown
	 }

	  for (var R = 0; R < document.styleSheets[S][cssRules].length; R++) {
	   if (document.styleSheets[S][cssRules][R].selectorText == theClass) {
	    if(document.styleSheets[S][cssRules][R].style[element]){
	    document.styleSheets[S][cssRules][R].style[element] = value;
	    added=true;
		break;
	    }
	   }
	  }
	  if(!added){
	  if(document.styleSheets[S].insertRule){
			  document.styleSheets[S].insertRule(theClass+' { '+element+': '+value+'; }',document.styleSheets[S][cssRules].length);
			} else if (document.styleSheets[S].addRule) {
				document.styleSheets[S].addRule(theClass,element+': '+value+';');
			}
	  }
	 }
}

function change_style(cb,cl) {
    if (cb.checked) {
        changecss(cl,'display','block');
    }
    else {
        changecss(cl,'display','none');
    }
}

</script>
</head>
<body>

<p align='center'>
show SRC: <input type=\"checkbox\" checked onclick=\"change_style(this,'.src')\">\&nbsp;\&nbsp;
show REF: <input type=\"checkbox\" checked onclick=\"change_style(this,'.ref')\">\&nbsp;\&nbsp;
show TST1: <input type=\"checkbox\" checked onclick=\"change_style(this,'.tst1')\">\&nbsp;\&nbsp;
show TST2: <input type=\"checkbox\" checked onclick=\"change_style(this,'.tst2')\">
</p>
";

my ($src_name, $ref_name, $tst1_name, $tst2_name ) = qw(SRC REF TST1 TST2);


while (<>) {

    chomp;
    if ( $_ =~ /^\#/ ) {
        $tst1_name = $1 if ( $_ =~ /test1=([^\s]+)/ );
        $tst2_name = $1 if ( $_ =~ /test2=([^\s]+)/ );
        next;
    }

    my ( $info, $src, $ref, $tst1, $tst2 ) = split ( /\t/, $_ );

    my @ngc1 = ( $info =~ /ngc1=\[([\d,]+)\]/ ) ? split (",", $1) : (0, 0, 0, 0);
    my @ngc2 = ( $info =~ /ngc2=\[([\d,]+)\]/ ) ? split (",", $1) : (0, 0, 0, 0);
    my $id = ( $info =~ /id=([^\s]+)/ ) ? $1 : '?';
    my $diff = ( $info =~ /diff=([^\s]+)/ ) ? $1 : '?';

print "
<p>
    <div class='info'>ID: $id\&nbsp;\&nbsp;\&nbsp; Difference in matching: $diff</div>
    <div class='src'><h6>SRC:</h6> $src</div>
    <div class='ref'><h6>REF:</h6> ".print_sentence($ref)."<br></div>
    <div class='tst1'><h6>
        $tst1_name\&nbsp;\&nbsp;\&nbsp;
        1-grams: $ngc1[0],\&nbsp;\&nbsp;\&nbsp;
        2-grams: $ngc1[1],\&nbsp;\&nbsp;\&nbsp;
        3-grams: $ngc1[2],\&nbsp;\&nbsp;\&nbsp;
        4-grams: $ngc1[3]</h6>
        ".print_sentence($tst1)."
    </div>
    <div class='tst2'><h6>
        $tst2_name\&nbsp;\&nbsp;\&nbsp;
        1-grams: $ngc2[0],\&nbsp;\&nbsp;\&nbsp;
        2-grams: $ngc2[1],\&nbsp;\&nbsp;\&nbsp;
        3-grams: $ngc2[2],\&nbsp;\&nbsp;\&nbsp;
        4-grams: $ngc2[3]</h6>
        ". print_sentence($tst2)."
    </div>
</p>
";
}

print "</body>\n</html>\n";

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
                $output .= "<span class='" . $CLASSES[$new_state - 1] . "'>" if $new_state != 0;
            }
            $state = $new_state;
            $output .= $chunk;
        }
    }
    $output .= "</span>" if $state != 0;
    return $output;
}
