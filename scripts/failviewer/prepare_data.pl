#!/usr/bin/perl -w

use strict;
use File::Path;
use File::Basename;
use File::Copy;

my $DATA = "data.js";
my $file = $ARGV[0];
my $line; 

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

#print "$header\n";
print OUT "$header\n";

#prepare data  
my $data = "var orig_values = Array(\n";
#print OUT "var values = Array(";
open(IN, "<$dir$base.data") or die "Cannot open input file $dir$base.data, Error: $!\n";
my $first = 1;
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

#print "$data\n";
print OUT "$data\n";

close(OUT);

