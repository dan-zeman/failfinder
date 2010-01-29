#!/usr/bin/env bash
set -e
set -x

cdecDir=../decoder
srcFile=example2.10.src

if [[ ! -e $srcFile ]]; then
    echo "Please provide the example2 directory from the Joshua distribution as input"
    exit 1
fi

$cdecDir/cdec -i $srcFile \
    -f scfg \
    -g example2/example2.heiro.tm.gz \
    -w weights \
    -F "LanguageModel -o 4 ./example2/example2.4gram.lm.gz" \
    -F WordPenalty \
    -K 500 -k 10 -r -P \
    > vanilla.scfg.nbest

awk -F' \\|\\|\\| ' 'BEGIN{prev=-1} {if(prev!=$1){print $2} prev=$1}' \
    < vanilla.scfg.nbest \
    > vanilla.scfg.topbest

paste -d '#' $srcFile vanilla.scfg.topbest \
    | sed 's/#/ ||| /g' \
    > forced.scfg.in

mkdir -p forestDir
$cdecDir/cdec -i forced.scfg.in \
    -f scfg \
    -g example2/example2.heiro.tm.gz \
    -w weights \
    -F "LanguageModel -o 4 ./example2/example2.4gram.lm.gz" \
    -F WordPenalty \
    -K 500 -k 0 -r -P \
    -O forestDir \
    > forced.scfg.nbest.src \
    2> forced.scfg.stderr
# Forests at forestDir/$n.json.gz

# Fix bug in cdec that puts source sentence in constrained n-best list
./cdec-scripts/fix_forced_nbest.py forced.scfg.in forced.scfg.nbest.src \
    > forced.scfg.nbest