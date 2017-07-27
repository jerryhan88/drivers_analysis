#!/usr/bin/env bash

for i in 0{1..9} {10..12}; do
    python -c "from a1_stateBlockByMonth import run; run('11$i')" &
done

