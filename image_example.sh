#!/usr/bin/env bash

MS="scienceData.EMU_1141-55.SB47138.EMU_1141-55.beam00_averaged_cal.leakage.ms"

DATA="DATA"
CORRECT="TEST"

echo "Will attempt wscleani, will use $DATA as column"

wsclean \
   -j 32 \
   -size 7128 7128 \
   -scale 2.5asec \
   -weight briggs -0.5 \
   -pol I \
   -mgain 0.9 \
   -nmiter 15 \
   -channels-out 4 \
   -join-channels \
   -niter 50000000 \
   -gridder wgridder \
   -auto-threshold 2 \
   -parallel-gridding 129 \
   -auto-mask 4 \
   -data-column "${DATA}" \
   -no-update-model-required \
   -name "all_${DATA}_column" \
   "${MS}"


wsclean \
   -j 32 \
   -size 7128 7128 \
   -scale 2.5asec \
   -weight briggs -0.5 \
   -channels-out 4 \
   -join-channels \
   -pol I \
   -mgain 0.9 \
   -nmiter 15 \
   -niter 50000000 \
   -gridder wgridder \
   -parallel-gridding 129 \
   -auto-threshold 2 \
   -auto-mask 4 \
   -no-update-model-required \
   -data-column "${CORRECT}" \
   -name "all_${CORRECT}_column" \
   "${MS}"


wsclean \
   -j 32 \
   -size 7128 7128 \
   -scale 2.5asec \
   -weight briggs -0.5 \
   -pol I \
   -mgain 0.9 \
   -nmiter 15 \
   -channels-out 4 \
   -join-channels \
   -niter 50000000 \
   -gridder wgridder \
   -auto-threshold 2 \
   -parallel-gridding 129 \
   -auto-mask 4 \
   -intervals-out 3 \
   -no-update-model-required \
   -data-column "${DATA}" \
   -name "all_intervals_${DATA}_column" \
   "${MS}"

wsclean \
   -j 32 \
   -size 7128 7128 \
   -scale 2.5asec \
   -weight briggs -0.5 \
   -channels-out 4 \
   -join-channels \
   -pol I \
   -mgain 0.9 \
   -nmiter 15 \
   -niter 50000000 \
   -gridder wgridder \
   -parallel-gridding 129 \
   -auto-threshold 2 \
   -auto-mask 4 \
   -intervals-out 3 \
   -no-update-model-required \
   -data-column "${CORRECT}" \
   -name "all_interval_${CORRECT}_column" \
   "${MS}"

