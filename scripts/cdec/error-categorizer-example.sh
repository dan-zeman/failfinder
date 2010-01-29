#!/usr/bin/env bash
set -e

java -cp ../../bin failfinder.algs.ErrorCategorizer \
    vanilla.scfg.nbest \
    forced.scfg.nbest \
    desired.txt