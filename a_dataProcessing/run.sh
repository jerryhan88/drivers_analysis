#!/usr/bin/env bash

#for i in 0{1..9} {10..12}; do
#    python -c "from a1_stateBlockByMonth import run; run('11$i')" &
#done


for i in {0..10}; do
    python -c "from a2_stateBlockByDriver import run; run($i)" &
done


#for i in {0..3}; do
#    python -c "from a2_stateBlockByDriver import arrange_files; arrange_files($i, 4)" &
#done


