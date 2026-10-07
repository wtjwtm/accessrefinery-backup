#!/bin/bash
# The RQ5 reducing column for the 7-Keys dataset, MiniSAT backend: what
# tools/figures/extract_scalability_RRI.sh reads as column 3 of
# paper_figures/archive_data/Experiment-Scalability-RRI-K4.dat.
#
# Why one process per policy.  The two AccessAnalyzer baselines
# (tools/accessanalyzer-reimpl/mining_{miner,reducer}_{z3,cvc5}.sh) cap every
# file at `timeout 3600` and, once a file returns 124, skip every later file of
# that dataset.  Their summary.csv therefore stops early, and the rows that were
# never written become the 3600000 ms sentinel that extract_scalability_RRI.sh
# fills - "at least an hour" - in the plotting data.  A whole-dataset
# AccessRefinery run cannot be capped the same way: it writes its summary.txt only
# after the last policy of the last round, so one timeout would lose the whole
# dataset.  Running one process per policy gives that same per-file cap.  The
# price is that a whole-dataset run shares one MCPFactory across the policies, so
# its numbers are cross-policy incremental while these are batch numbers: this
# column is comparable with other per-policy runs, not with a whole-dataset
# column of the 5-/6-Keys panels.  --round 3 is the round count those two panels'
# reducing column was measured with (running_sat_reducer.sh).
#
# A finished policy that would have needed more than the cap gets no row either,
# so the extractor fills it with the sentinel as well; that is deliberate, the
# point of the cap being to bound the machine time of the tail.
#
# Usage (server, 64 cores, run sequentially - the whole point is a quiet box):
#   ROOT=/home/yjwang/exp/rq5sat07seq DATA=/home/yjwang/exp/BR/data/Scalability_07Keys \
#   JAR=/home/yjwang/exp/BR/refinery.jar \
#   nohup sh tools/accessrefinery/running_sat_reducer_07_perpolicy.sh > /dev/null 2>&1 &
#
# Outputs under $ROOT:
#   shard/<nn>/<nn>_allow.json  one policy per directory.  The tool derives its
#                               output path from the input path (it replaces the
#                               second-to-last element with `result`), so the
#                               per-policy summary lands in result/<nn>/.
#   result/<nn>/summary.txt     the tool's own summary for that policy: header
#                               plus one data row in the nine columns of
#                               ResultsAnalyzer.writeAveragesToFile
#   summary.txt                 those rows in policy order under one header, the
#                               file to copy to
#                               results/accessrefinery_sat_reducer_3rs/Scalability_07Keys/
#   progress.txt                one line per finished policy with its exit code,
#                               then either TIMEOUT or ALLDONE

set -u

ROOT=${ROOT:-$PWD/rq5sat07seq}
DATA=${DATA:-data/Scalability_07Keys}
JAR=${JAR:-target/accessrefinery-1.0.jar}
J=${JAVA:-java}
ROUNDS=${ROUNDS:-3}
TIMEOUT=${TIMEOUT:-3600}

mkdir -p "$ROOT/shard" "$ROOT/run" "$ROOT/result"
: > "$ROOT/progress.txt"
: > "$ROOT/summary.txt"

echo "START $(date '+%F %T') root=$ROOT data=$DATA jar=$JAR rounds=$ROUNDS timeout=$TIMEOUT" \
    >> "$ROOT/progress.txt"

for f in "$DATA"/*.json; do
    n=$(basename "$f" .json | cut -d_ -f1)          # 01_allow.json -> 01
    d="$ROOT/shard/$n"
    mkdir -p "$d" "$ROOT/run/$n"
    cp -f "$f" "$d/"

    ( cd "$ROOT/run/$n" && timeout "$TIMEOUT" "$J" -jar "$JAR" \
        -m -s -r --round "$ROUNDS" -f "$d" > run.log 2>&1 )
    rc=$?
    echo "$n rc=$rc $(date +%T)" >> "$ROOT/progress.txt"

    if [ "$rc" -eq 124 ]; then
        echo "TIMEOUT after ${TIMEOUT}s at policy $n: stopping, the policies after it are not run" \
            >> "$ROOT/progress.txt"
        break
    fi
done

# Roll-up, in policy order: the header of any finished policy, then its row.  A
# policy that timed out, died or was never reached contributes no row on purpose.
hdr=$(ls -1 "$ROOT"/result/*/summary.txt 2>/dev/null | head -1)
[ -n "$hdr" ] && head -1 "$hdr" > "$ROOT/summary.txt"
for d in "$ROOT"/result/*/; do
    [ -f "$d/summary.txt" ] && awk 'NR>1' "$d/summary.txt" >> "$ROOT/summary.txt"
done

echo "ALLDONE $(date '+%F %T') measured=$(awk 'NR>1' "$ROOT/summary.txt" | wc -l) policies" \
    >> "$ROOT/progress.txt"
