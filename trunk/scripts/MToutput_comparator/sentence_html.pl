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
.onlyA { background-color: red }
.onlyB { background-color: green }
.AandB { background-color: yellow }
.src { color: black; padding: 5px; background-color: #eeeeee }
.ref { color: black; padding: 5px; background-color: #cccccc }
.tst1 { color: black; padding: 5px; background-color: #ccffcc }
.tst2 { color: black; padding: 5px; background-color: #ffcccc }
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

<p>
SRC: <input type=\"checkbox\" checked onclick=\"change_style(this,'.src')\">
REF: <input type=\"checkbox\" checked onclick=\"change_style(this,'.ref')\">
TST1: <input type=\"checkbox\" checked onclick=\"change_style(this,'.tst1')\">
TST2: <input type=\"checkbox\" checked onclick=\"change_style(this,'.tst2')\">

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
    print "<p>\n";
    print "    <i>$info</i>\n";
    print "    <div class='src'><b>SRC:</b> $src</div>\n";
    print "    <div class='ref'><b>REF:</b> " . print_sentence($ref) . "<br></div>\n";
    print "    <div class='tst1'><b>$tst1_name:</b> " . print_sentence($tst1) . "<br></div>\n";
    print "    <div class='tst2'><b>$tst2_name:</b> " . print_sentence($tst2) . "<br></div>\n";
    print "</p>\n";
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
