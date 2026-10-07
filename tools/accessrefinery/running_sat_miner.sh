#!/bin/bash

java -jar target/accessrefinery-1.0.jar -m -s --round 10 -f data/Correctness/
# The real-world corpus (data/RW/) is not public, for commercial reasons; run it
# only when it is present locally.
if [ -d data/RW/ ]; then
  java -jar target/accessrefinery-1.0.jar -m -s --round 10 -f data/RW/
fi
java -jar target/accessrefinery-1.0.jar -m -s --round 10 -f data/Scalability_05Keys/
java -jar target/accessrefinery-1.0.jar -m -s --round 10 -f data/Scalability_06Keys/

mv result/ accessrefinery_sat_miner_10rs/
