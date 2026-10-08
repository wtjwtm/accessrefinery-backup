#!/bin/bash
mkdir -p paper_figures/archive_data/
process_dir() {
    local dir_name=$1
    local out_file=$2
    local f2="results/accessanalyzer_z3_reducer_1rs/${dir_name}/summary.csv"
    local f3="results/accessanalyzer_cvc5_reducer_1rs/${dir_name}/summary.csv"
    local f4="results/accessrefinery_sat_reducer_3rs/${dir_name}/summary.txt"
    local f5="results/accessrefinery_bdd_reducer_10rs/${dir_name}/summary.txt"
    local val2=()
    local val3=()
    local val4=()
    local val5=()
    # A missing input falls back to the 3600000 s timeout sentinel below, so a
    # run without the `cp -r archive_results/... results/` step would silently
    # produce a plausible-looking but entirely fake column. Warn instead.
    for f in "$f2" "$f3" "$f4" "$f5"; do
        [ -f "$f" ] || echo "Warning: $f not found; its column will be all timeout values" >&2
    done
    # Read f2 (CSV, 5th col = Total Time (s), needs * 1000)
    if [ -f "$f2" ]; then
        mapfile -t val2 < <(awk -F',' 'NR>1 {printf "%.1f\n", $5 * 1000}' "$f2")
    fi
    # Read f3 (CSV, 5th col = Total Time (s), needs * 1000)
    if [ -f "$f3" ]; then
        mapfile -t val3 < <(awk -F',' 'NR>1 {printf "%.1f\n", $5 * 1000}' "$f3")
    fi
    # Read f4 (TXT, whitespace delimited, 5th col = TotalTimeAverage)
    if [ -f "$f4" ]; then
        mapfile -t val4 < <(awk 'NR>1 {printf "%.2f\n", $5}' "$f4")
    fi
    # Read f5 (TXT, whitespace delimited, 5th col = TotalTimeAverage)
    if [ -f "$f5" ]; then
        mapfile -t val5 < <(awk 'NR>1 {printf "%.2f\n", $5}' "$f5")
    fi
    > "$out_file"
    for i in {0..14}; do
        local v2=${val2[$i]:-3600000}
        local v3=${val3[$i]:-3600000}
        local v4=${val4[$i]:-3600000}
        local v5=${val5[$i]:-3600000}

        v2=$(awk -v v="$v2" 'BEGIN{printf "%.1f", (v>3600000 ? 3600000 : v)}')
        v3=$(awk -v v="$v3" 'BEGIN{printf "%.1f", (v>3600000 ? 3600000 : v)}')
        v4=$(awk -v v="$v4" 'BEGIN{printf "%.2f", (v>3600000 ? 3600000 : v)}')
        v5=$(awk -v v="$v5" 'BEGIN{printf "%.2f", (v>3600000 ? 3600000 : v)}')

        echo "$v2 $v3 $v4 $v5" >> "$out_file"
    done
}

# The `AccessRefinery(W/ All)` series of Figure 13: the same reduction work with
# all three optimizations on, from the Incremental MCP stage of the pipeline. The
# Incremental MCP stage's TotalTimeAverage is the whole run (mine plus reduce), which is the
# same quantity as the `accessrefinery_bdd_reducer_10rs` column above.
#
# This is written to its own single-column file rather than appended as another
# column of the `.dat` above, so that the columns of that file stay as they are.
wall_series() {
    local dir_name=$1
    local out_file=$2
    local spec=$3
    local src="results/accessrefinery_bdd_reducer_IncrementalMCP_20rs/${dir_name}/summary.txt"
    local vals=()
    [ -f "$src" ] || echo "Warning: $src not found; the W/ All series will be all timeout values" >&2
    if [ -f "$src" ]; then
        mapfile -t vals < <(awk -v spec="$spec" 'NR>1 {
            n = split(spec, p, "+"); s = 0
            for (i = 1; i <= n; i++) s += $p[i]
            printf "%.2f\n", s
        }' "$src")
    fi
    > "$out_file"
    for i in {0..14}; do
        echo "${vals[$i]:-3600000.00}" >> "$out_file"
    done
}

process_dir "Scalability_05Keys" "paper_figures/archive_data/Experiment-Scalability-RRI-K2.dat"
process_dir "Scalability_06Keys" "paper_figures/archive_data/Experiment-Scalability-RRI-K3.dat"
# 5-Key*. The two reducer baselines were run on this dataset on 2026-09-28, one
# round per policy and one hour per policy: Z3 measured the first three and timed
# out on the fourth, CVC5 the first five and timed out on the sixth. The reducer
# writes a row only for a policy it finishes, so those two columns hold the
# measured prefix and the sentinel from the first timeout on - the same shape the
# 05/06-Keys baselines have. Keep the four-column layout so the column numbers
# mean the same thing in every K file.
process_dir "Scalability_05Keys∗" "paper_figures/archive_data/Experiment-Scalability-RRI-K4.dat"
wall_series "Scalability_05Keys" "paper_figures/archive_data/Experiment-Scalability-RRI-K2-WAll.dat" "5"
wall_series "Scalability_06Keys" "paper_figures/archive_data/Experiment-Scalability-RRI-K3-WAll.dat" "5"
wall_series "Scalability_05Keys∗" "paper_figures/archive_data/Experiment-Scalability-RRI-K4-WAll.dat" "5"
echo "Done extracting scalability RRI data."
