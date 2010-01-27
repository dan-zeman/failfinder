#!/usr/bin/env python

from sys import *
from optparse import OptionParser
parser = OptionParser()
parser.add_option("-i", "--input", dest="input",default="-",
                        help="The input corpus", metavar="FILE")

parser.add_option("-o", "--output", dest="output",default="output.",
                        help="The output file prefix", metavar="PREFIX")

parser.add_option("-n", "--n-gram",dest="ng",default=8,type="int",
                        help="The maximum ngrames", metavar="NUM")

parser.add_option("-p", "--prob",dest="prob",default=0.5,type="float",
                        help="The probability for highest ngram", metavar="NUM")


(options, args) = parser.parse_args()

if options.input == None or options.output == None:
	parser.print_help();
	exit();

def outputNGram(sent, n):
	ngs = [];
	for i in range(0,len(sent)-n+1):
		ngs.append(tuple(sent[i:i+n]));
	return set(ngs);

def sortng(ng1,ng2):
	for i in range(0,len(ng1)):
		if i >= len(ng2):
			return 1;
		if ng1[i] < ng2[i]:
			return -1;
		elif ng1[i] > ng2[i]:
			return 1;
	if len(ng1) < len(ng2):
		return -1;
	return 0;
		

inp = None;
if options.input == "-":
	inp = stdin;
else:
	inp = open(options.input,"r");

sntno = 0;

maxn = options.ng;

prob = options.prob;

allNG = [];

for line in inp:
	sntno += 1;
	txt = line.strip().split();
	ofname = options.output+"%05d.sri" % sntno;
	for i in range(1,maxn+1):
		allNG.append(outputNGram(txt,i));

	op = open(ofname,"w");
	op.write("\n\\data\\\n");
	for i in range(0,maxn):
		if len(allNG[i])==0:
			break;
		op.write("ngram %d=%d\n" % (i+1,len(allNG[i])))
	op.write("\n");

	for i in range(0,maxn):
		ngs1 = list(allNG[i]);
		if len(ngs1) == 0:
			break;
		op.write("\\%d-gram:\n" % (i+1) );
		ngs1.sort(sortng);
		for gram in ngs1:
			op.write("%g\t" % prob);
			for word in gram:
				op.write("%s " % word);
			op.write("\n");
		op.write("\n");


	op.write("\\end\\\n");
			





