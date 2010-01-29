#!/usr/bin/env bash
set -e

java -Xmx2G -cp ../../bin failfinder.algs.SearchPathAnalyzer \
    vanilla.scfg.searchpath.1 \
    forced.scfg.searchpath.1