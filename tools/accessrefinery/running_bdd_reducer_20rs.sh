#!/bin/bash

# Intent mining and reduction with the BDD backend, 20 rounds, for the three
# stages of the optimization pipeline: Original, +Pruning Reducer, +Incremental MCP.
#
# Each stage is selected with cumulative switches, all of which default to
# true (i.e. no switches at all is the fully optimized Incremental MCP stage):
#
#   -Dopt.ar=false   disable the essential-finding pre-filter in the reducer
#   -Dopt.am=false   disable the miner's BFS early-exit and refinement DAG
#   -Dopt.ai=false   disable the incremental EC engine + cross-policy factory
#
# The -D flags must precede -jar. Every stage runs the same four datasets and
# writes its `result/` tree to results/<stage>/, the working directory that
# tools/figures/extract_optimization_pipeline.sh reads.
#
# The shipped copies of these three folders live in archive_results_new/, which
# this script never touches; check the regenerated results/ against them.
#
# The real-world corpus (data/RW/) is the labeled version of the corpus, in which
# the synthesized label s3:::886499mir is added to every statement; it is stored
# under the folder name "RW" inside each stage's results directory. The corpus
# itself is not public, for commercial reasons, so data/RW/ ships empty and the
# RW run below is skipped unless the folder has been restored locally.

run_stage() {
  local name=$1; shift
  if [ -d data/RW/ ]; then
    java "$@" -jar target/accessrefinery-1.0.jar -m -r --round 20 -f data/RW/
  fi
  java "$@" -jar target/accessrefinery-1.0.jar -m -r --round 20 -f data/Scalability_05Keys/
  java "$@" -jar target/accessrefinery-1.0.jar -m -r --round 20 -f data/Scalability_06Keys/
  java "$@" -jar target/accessrefinery-1.0.jar -m -r --round 20 -f data/Scalability_05Keys∗/
  # Replace the previous working copy; the pristine one stays in
  # archive_results_new/. `mv result dst` would nest the tree inside dst.
  rm -rf "results/$name"
  mv result "results/$name"
}

# Original - batch engine, no optimization
run_stage accessrefinery_bdd_reducer_Original_20rs -Dopt.ar=false -Dopt.am=false -Dopt.ai=false

# Pruning Reducer - Original + essential-finding pre-filter
run_stage accessrefinery_bdd_reducer_PruningReducer_20rs -Dopt.am=false -Dopt.ai=false

# Incremental MCP - Pruning Reducer + incremental EC engine and cross-policy
# shared factory (all defaults)
run_stage accessrefinery_bdd_reducer_IncrementalMCP_20rs
