#!/usr/bin/env python

import gzip
import bz2
from sys import *
from optparse import OptionParser
parser = OptionParser()
parser.add_option("-i", "--input", dest="input",default="-",
                        help="The input corpus", metavar="FILE")

parser.add_option("-p", "--phrase-table", dest="phrasetable",default=None,
                        help="The input phrase table", metavar="FILE")

parser.add_option("-o", "--output", dest="output",default="output.",
                        help="The output file prefix", metavar="PREFIX")

parser.add_option("-n", "--max-parts",dest="nfile",default=50,type="int",
                        help="Total number of output files", metavar="NUM")

parser.add_option("-m", "--max-phrase-lenght",dest="mpl",default=10,type="int",
                        help="The max phrase length", metavar="NUM")

parser.add_option("-c", "--coverage_file",dest="cvg",
                        help="The coverage file", metavar="FILE")

(options, args) = parser.parse_args()
def qopen(fname,mode="r",level=5):
	item = fname.split(".");
	if(item[-1]=="gz"):
		return gzip.GzipFile(fname,mode,5);
	elif (item[-1]=="bz2"):
		return bz2.BZ2File(fname,mode,5);
	else:
		return open(fname,mode);


if options.input == None or options.output == None or options.phrasetable == None:
	parser.print_help();
	exit();
			

if options.input == "-":
	inp = stdin;
else:
	inp = open(options.input,"r");


sents = [];

for line in inp:
	words = line.strip().split();
	sents.append((tuple(words),[]));
	for k in words:
		sents[-1][1].append(0);
	
	

sents = tuple(sents);


phrases = [];

for i in range(0,options.mpl):
	phrases.append({});

phrases = tuple(phrases);

for i in range(0,len(sents)):
	words = sents[i][0];
	for j in range(1,options.mpl+1):
		for k in range(0,len(words)-j+1):
			phrase = tuple(words[k:k+j]);
			if phrases[j-1].has_key(phrase):
				phrases[j-1][phrase].append((i,k,k+j));
			else:
				phrases[j-1][phrase] = [(i,k,k+j)];

tfiles=[];
sentPerFile = int(len(sents) / (options.nfile+1));
if len(sents) > sentPerFile * options.nfile:
	sentPerFile += 1;
for i in range(0,options.nfile):
	fname = options.output + "%05d-%05d.phrases" % (i*sentPerFile,(i+1)*sentPerFile-1);
	tfiles.append((open(fname,"w"),[]));

tfiles = tuple(tfiles);

def flushfiles(fi,buffer):
	for line in buffer:
		fi.write(line);
	del buffer[:];

i = 0;
for pp in qopen(options.phrasetable,"r"):
	sph = pp.split("|||");
	phrs = tuple(sph[0].strip().split());
	j = len(phrs);
	if phrases[j-1].has_key(phrs):
		lastfi = -1;
		for entry in phrases[j-1][phrs]:
			findex = int(entry[0] / sentPerFile);
			for k in range(entry[1],entry[2]):
				sents[entry[0]][1][k] = 1;
			#print findex,len(tfiles)
			if findex == lastfi:
				continue
			lastfi = findex;
			tfiles[findex][1].append(pp);
			if(len(tfiles[findex][1])>=500000):
				flushfiles(tfiles[findex][0],tfiles[findex][1]);


for file in tfiles:
	flushfiles(file[0],file[1]);
	file[0].close();


covfile = open(options.cvg,"w");

for s in sents:
	for i in range(0,len(s[1])):
		if s[1][i] == 0:
			covfile.write("__UNC_(%s)" % s[0][i]);
		else:
			covfile.write("%s" % s[0][i]);
		if  i < len(s[1])-1:
			covfile.write(" ");
		else:
			covfile.write("\n");




