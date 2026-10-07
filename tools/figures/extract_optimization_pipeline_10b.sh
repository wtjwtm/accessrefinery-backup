#!/bin/bash
# Regenerate the plotting data of the three 10-round pipeline figures from the
# four-stage re-run `rerun10b` (2026-09-24, all four stages from one jar via the
# -Dopt.ar/am/ai switches, --round 10, 05/06/07-Keys).
#
# Input layout: results/rerun10b/<STAGE>/<dataset>/summary.txt, i.e. the same
# result/<dataset>/summary.txt shape the tool writes, with <STAGE> one of
# BR / AR / AM / AI, plus the fifth stage AM_only (see the enc_$k.dat entry
# below; only the Percentage figure reads it). The first twelve summary.txt are
# the ones the server run produced; the rest of that run's outputs
# (allow_result.json / allow_time.csv) stay on the server.
#
# This is the 10-round companion of extract_optimization_pipeline.sh, which
# reads the 20-round archives under results/accessrefinery_bdd_reducer_*_20rs/.
# The two scripts write to different directories on purpose, so neither can
# overwrite the other's inputs.
#
# summary.txt columns (1-based):
#   1 NumberStatement          2 NumberMCI                   3 NumberRRI
#   4 MCISolvingRoundAverage   5 TotalTimeAverage            6 MCILabelsTimeAverage
#   7 MCIOperationsTimeAverage 8 RRIOperationsTimeAverage    9 RRIILPSolvingTimeAverage
#
# Outputs, one set per key count k = 05 / 06 / 07:
#
#   bar3_$k.dat   Figure "Optimization-Overview-Bars-3Stage"
#                 idx BR AR AI - TotalTimeAverage (c5) of Original (BR),
#                 Pruning Reducer (AR) and Incremental MCP (AI), for the
#                 policies of 3/6/9/12/15 statements, numbered 0..4.
#
#   p2ai_$k.dat   Figure "RQ8-MiningPruning-AR-AI"
#                 Policy A B - the intent-mining cost with the two reduce/solve
#                 columns (c8 RRIOperationsTimeAverage, c9 RRIILPSolvingTimeAverage)
#                 taken out, i.e. c6+c7, of AR vs AI, one row per policy 1..15.
#
#   seg_$k.dat    Figure "Optimization-Overview-Bars-Segmented"
#                 idx BR_miner BR_total AR_miner AR_total AI_miner AI_total -
#                 how each stage's time splits between the intent miner (c6+c7)
#                 and the intent reducer (c8+c9), in milliseconds, for the same
#                 five policies as bar3.  BR_total is c5, the stage's whole run,
#                 so the bars of this figure and of bar3 have the same heights;
#                 the reducer segment is c5 - (c6+c7), which is c8+c9 up to the
#                 per-column rounding of summary.txt.
#
#   enc_$k.dat    Figure "Optimization-Overview-Bars-Percentage"
#                 idx Miner Reducer - the AM-only stage alone, and how much
#                 of each of its two stages goes to the encoding step that stage
#                 starts with, as a percentage of that stage's own pair:
#                 Miner = 100*c6/(c6+c7), the intent miner's window up to the end
#                 of the label tree (parse + ECs + label tree), i.e. everything
#                 before the mining BFS itself; Reducer = 100*c8/(c8+c9), the
#                 intent reducer's window up to the end of the EC encoding of the
#                 findings, i.e. everything before the ILP solve.  One row per
#                 policy 3/6/9/12/15, numbered 0..4.
#
#   rw_enc.dat    the RW panel of the same figure, the same two shares over the
#                 AM-only stage's 506 real-world policies, one row per policy,
#                 each column sorted on its own value ascending. Written only
#                 when results/rerun10b/AM_only/RW/summary.txt is present.
#
# AM-only, the fifth stage this script reads: -Dopt.ar=false -Dopt.am=true
# -Dopt.ai=false, i.e. the incremental miner without the essential-finding
# pre-filter and without the incremental EC engine. It is not the four-stage
# ladder's AM rung, which is ar=true am=true ai=false; the three switches are
# read independently, see Parameter.java. results/rerun10b/AM_only/ was taken
# 2026-09-26 on the same server as the four stages, with the same jar
# (exp/rerun10/refinery_sw.jar) and the same command line, so it differs from
# them in the switches alone. Only the Percentage figure reads it. Its real-world
# companion, results/rerun10b/AM_only/RW/summary.txt, is a later run of the same
# three switches and the same jar on the RW corpus, --round 10 as well, taken
# 2026-09-28; it exists only for the real-world panel of the Percentage figure.
#
# Real-world output. The synthetic re-run above covers the scalability datasets
# only; the RW panel of "RQ8-MiningPruning-AR-AI" needs the two real-world
# summaries of the same round, results/rerun10b/<STAGE>/RW/summary.txt, which
# this script then turns into
#
#   rw_p2ai.dat   the RW panel of Figure "RQ8-MiningPruning-AR-AI"
#                 Policy A B - c6+c7 of AR vs AI, i.e. the same quantity as the
#                 figure's synthetic panels, one row per RW policy. Each column is
#                 sorted on its own value, ascending, like rw_p1.dat of Figure
#                 "RQ7-ReducingPruning-BR-AR": the panel shows two sorted
#                 distributions, so a row is no longer one policy.
#
#   rw_bar3.dat   the RW panel of Figure "Optimization-Overview-Bars-3Stage",
#                 written into $OUT with the rest of this script's outputs, so
#                 that every file under $OUT comes from this one script
#                 Policy WO AR W - three total-time curves in milliseconds, the
#                 same three that the panel draws. AR and W/ All are the
#                 TotalTimeAverage (c5) of this re-run's own AR and AI stages,
#                 i.e. whole-run totals. W/O All is the original run's whole-run
#                 total as well, which is the two panels of the real-world
#                 baseline figure added back together: the fourth column of
#                 archive_data/Experiment-Scalability-MCI-RealWorld.dat (the
#                 mining phase) plus the fourth column of archive_data/
#                 Experiment-Scalability-RRI-RealWorld.dat (the reducing phase,
#                 the same 506 policies in the same order). Sorted like
#                 rw_p2ai.dat, each column on its own value.
#
# W/O All predates this re-run, so it is the one curve that does not come from the
# same run as the other two: it is the reference that the pipeline's stages are
# read against.
#
# and into the AI series of the real-world figure RQ4, which reads
# paper_figures/archive_data/ and is drawn as seconds:
#
#   archive_data/Experiment-Scalability-MCI-RealWorld-AI.dat   c6+c7, one column
#   archive_data/Experiment-Scalability-RRI-RealWorld-AI.dat   c8+c9, one column
#
# Both RW summaries are 10-round runs of the same round as the synthetic data
# (2026-09-25 for the RW pair, 2026-09-23 for the synthetic one). The AR columns of
# every summary this script reads - the three Scalability sets and RW - were re-taken
# on 2026-09-26, same flags and same corpus, with the jar built from the tree that
# times the reducer's single-finding shortcut; the BR, AM and AI columns are still
# the earlier run. The AI one was
# taken with -Dmcp.labelinc=true, so its c6 column times the single
# computeLabels() call that absorbs the synthesized label instead of the whole
# parse+preprocessing window the archives time. Measured against the AI 20-round
# archive (wide window), the two differ by 5-7% at the median — below this
# figure's resolution on a log axis, but the difference is real and is why c6 is
# the only column of the pair that this script's provenance differs on.

set -e

ROOT=results/rerun10b
OUT=paper_figures/archive_data_new/rerun10b
mkdir -p "$OUT"

for s in BR AR AM AI AM_only; do
    for k in 05 06 07; do
        f="$ROOT/$s/Scalability_${k}Keys/summary.txt"
        [ -f "$f" ] || echo "Warning: $f not found" >&2
    done
done

# readcol <summary.txt> <spec> : one value per policy, in file order.
# <spec> is a 1-based column number, or a "+" sum such as 6+7.
readcol() {
    awk -v spec="$2" 'NR>1 {
        n = split(spec, p, "+"); s = 0
        for (i = 1; i <= n; i++) s += $p[i]
        printf "%.2f\n", s
    }' "$1"
}

# The policies of 3/6/9/12/15 statements are rows 3/6/9/12/15 of the column
# stream below, which drops the summary.txt header line.
PICK='NR==3||NR==6||NR==9||NR==12||NR==15'

# --- Figure 3Stage: all three stages, c5 --------------------------------------
for k in 05 06 07; do
    ds="Scalability_${k}Keys"
    { printf 'idx\tBR\tAR\tAI\r\n'
      paste -d'\t' <(readcol "$ROOT/BR/$ds/summary.txt" 5) \
                   <(readcol "$ROOT/AR/$ds/summary.txt" 5) \
                   <(readcol "$ROOT/AI/$ds/summary.txt" 5) \
        | awk "$PICK"'{ printf "%d\t%s\t%s\t%s\r\n", n++, $1, $2, $3 }'
    } > "$OUT/bar3_$k.dat"
done

# --- Figure AR-AI: mining cost c6+c7 ------------------------------------------
for k in 05 06 07; do
    ds="Scalability_${k}Keys"
    { printf 'Policy\tA\tB\r\n'
      paste -d'\t' <(readcol "$ROOT/AR/$ds/summary.txt" 6+7) \
                   <(readcol "$ROOT/AI/$ds/summary.txt" 6+7) \
        | awk '{ printf "%d\t%s\t%s\r\n", NR, $1, $2 }'
    } > "$OUT/p2ai_$k.dat"
done

# --- Figure Segmented: miner (c6+c7) under reducer (c8+c9), in ms -------------
for k in 05 06 07; do
    ds="Scalability_${k}Keys"
    { printf 'idx\tBR_miner\tBR_total\tAR_miner\tAR_total\tAI_miner\tAI_total\r\n'
      for s in BR AR AI; do
          paste -d'\t' <(readcol "$ROOT/$s/$ds/summary.txt" 6+7) \
                       <(readcol "$ROOT/$s/$ds/summary.txt" 5) > "/tmp/seg_$s"
      done
      paste -d'\t' /tmp/seg_BR /tmp/seg_AR /tmp/seg_AI \
        | awk 'NR==3||NR==6||NR==9||NR==12||NR==15 {
              printf "%d\t%s\t%s\t%s\t%s\t%s\t%s\r\n",
                     n++, $1, $2, $3, $4, $5, $6
          }'
      rm -f /tmp/seg_BR /tmp/seg_AR /tmp/seg_AI
    } > "$OUT/seg_$k.dat"
done

# --- Figure Percentage: encoder share within each pair, AM-only stage ---------
# The two shares are of different denominators on purpose: the left bar of a pair
# says how much of the miner's window the label side takes, the right bar how much
# of the reducer's window the EC encoding takes.  A policy whose pair is entirely
# zero prints 0 rather than dividing by it.
for k in 05 06 07; do
    ds="Scalability_${k}Keys"
    { printf 'idx\tMiner\tReducer\r\n'
      awk 'NR>1 {
              m = $6 + $7; r = $8 + $9
              printf "%.2f\t%.2f\n", (m > 0 ? 100*$6/m : 0), (r > 0 ? 100*$8/r : 0)
           }' "$ROOT/AM_only/$ds/summary.txt" \
        | awk "$PICK"'{ printf "%d\t%s\t%s\r\n", n++, $1, $2 }'
    } > "$OUT/enc_$k.dat"
done

# The real-world panel of the same figure: the same two shares over the 506 RW
# policies, each column sorted on its own value ascending, like every other
# real-world panel of this family, so the panel reads as two sorted distributions
# rather than as one policy per row. The four policies that yield no finding have
# no reducer window to take a share of, so their encoding share prints 0, the same
# convention the synthetic file above uses.
if [ -f "$ROOT/AM_only/RW/summary.txt" ]; then
    TMPE=$(mktemp -d)
    awk 'NR>1 { m = $6 + $7
                printf "%.2f\n", (m > 0 ? 100*$6/m : 0) }' "$ROOT/AM_only/RW/summary.txt" \
        | LC_ALL=C sort -s -g > "$TMPE/m"
    awk 'NR>1 { r = $8 + $9
                printf "%.2f\n", (r > 0 ? 100*$8/r : 0) }' "$ROOT/AM_only/RW/summary.txt" \
        | LC_ALL=C sort -s -g > "$TMPE/r"
    { printf 'Policy\tMiner\tReducer\r\n'
      paste -d'\t' "$TMPE/m" "$TMPE/r" \
        | awk '{ printf "%d\t%s\t%s\r\n", NR-1, $1, $2 }'
    } > "$OUT/rw_enc.dat"
    rm -rf "$TMPE"
else
    echo "Note: skipping rw_enc.dat ($ROOT/AM_only/RW/summary.txt not found)." >&2
fi

# --- Figure AR-AI, RW panel, and the AI series of Figure RQ4 ------------------
# Only when both real-world summaries of this round are in place; the synthetic
# outputs above regenerate unconditionally.
HAVE_RW=1
for s in AR AI; do
    [ -f "$ROOT/$s/RW/summary.txt" ] || HAVE_RW=0
done

if [ "$HAVE_RW" = 1 ]; then
    TMPRW=$(mktemp -d)
    # Each column sorted on its own value, like rw_p1.dat in
    # extract_optimization_pipeline.sh.
    readcol "$ROOT/AR/RW/summary.txt" 6+7 | LC_ALL=C sort -s -g > "$TMPRW/a"
    readcol "$ROOT/AI/RW/summary.txt" 6+7 | LC_ALL=C sort -s -g > "$TMPRW/b"
    { printf 'Policy\tA\tB\r\n'
      paste -d'\t' "$TMPRW/a" "$TMPRW/b" \
        | awk '{ printf "%d\t%s\t%s\r\n", NR-1, $1, $2 }'
    } > "$OUT/rw_p2ai.dat"
    rm -rf "$TMPRW"

    # RW panel of Figure "Optimization-Overview-Bars-3Stage": three total-time
    # curves, each sorted on its own value. AR and W/ All are this re-run's AR and
    # AI stages; W/O All is the original run's whole-run total, so it is the mining
    # column and the reducing column of the real-world baseline figure added
    # together, not the mining column alone, see the note at the top.
    WO=paper_figures/archive_data/Experiment-Scalability-MCI-RealWorld.dat
    WR=paper_figures/archive_data/Experiment-Scalability-RRI-RealWorld.dat
    if [ -f "$WO" ] && [ -f "$WR" ]; then
        TMPB=$(mktemp -d)
        paste -d'\t' "$WO" "$WR" \
            | awk -F'\t' '{ printf "%.2f\n", ($4 + $8) * 1000 }' \
            | LC_ALL=C sort -s -g > "$TMPB/wo"
        readcol "$ROOT/AR/RW/summary.txt" 5 | LC_ALL=C sort -s -g > "$TMPB/ar"
        readcol "$ROOT/AI/RW/summary.txt" 5 | LC_ALL=C sort -s -g > "$TMPB/w"
        { printf 'Policy\tWO\tAR\tW\r\n'
          paste -d'\t' "$TMPB/wo" "$TMPB/ar" "$TMPB/w" \
            | awk '{ printf "%d\t%s\t%s\t%s\r\n", NR-1, $1, $2, $3 }'
        } > "$OUT/rw_bar3.dat"
        rm -rf "$TMPB"
    else
        echo "Note: skipping rw_bar3.dat ($WO or $WR not found)." >&2
    fi

    # RQ4 reads paper_figures/archive_data/ and scales its columns by 1000, so
    # these two are seconds, one column, sorted ascending like the file the AI
    # series replaced. One file per panel: mining cost in the MCI panel, reducing
    # cost in the RRI panel.
    OUT_RQ4=paper_figures/archive_data
    awk 'NR>1 { printf "%.6f\n", ($6+$7)/1000 }' "$ROOT/AI/RW/summary.txt" \
        | LC_ALL=C sort -g > "$OUT_RQ4/Experiment-Scalability-MCI-RealWorld-AI.dat"
    awk 'NR>1 { printf "%.6f\n", ($8+$9)/1000 }' "$ROOT/AI/RW/summary.txt" \
        | LC_ALL=C sort -g > "$OUT_RQ4/Experiment-Scalability-RRI-RealWorld-AI.dat"
else
    echo "Note: $ROOT/{AR,AI}/RW/summary.txt not found." >&2
    echo "      Skipping rw_p2ai.dat (RW panel of RQ8-MiningPruning-AR-AI)" >&2
    echo "      and the AI series of RQ4." >&2
fi

echo "Done extracting optimization-pipeline 10-round data into $OUT/"
ls -1 "$OUT"
