#!/usr/bin/env bash

module load wsclean
module load apptainer

MS="scienceData.EMU_1141-55.SB47138.EMU_1141-55.beam00_averaged_cal.leakage.ms"
AEGEAN="/scratch3/gal16b/containers/aegean.sif"
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
   -niter 50000000 \
   -gridder wgridder \
   -auto-threshold 0.25 \
   -parallel-gridding 129 \
   -auto-mask 3.5 \
   -data-column "${DATA}" \
   -no-update-model-required \
   -channel-range 4 9 \
   -local-rms \
   -local-rms-window 80 \
   -intervals-out 3 \
   -name "all_${DATA}_column_subchan" \
   "${MS}"


wsclean \
   -j 32 \
   -size 7128 7128 \
   -scale 2.5asec \
   -weight briggs -0.5 \
   -pol I \
   -mgain 0.9 \
   -nmiter 15 \
   -niter 50000000 \
   -gridder wgridder \
   -parallel-gridding 129 \
   -auto-threshold 0.25 \
   -auto-mask 3.5 \
   -no-update-model-required \
   -data-column "${CORRECT}" \
   -channel-range 4 9 \
   -local-rms \
   -local-rms-window  80 \
   -intervals-out 3 \
   -name "all_${CORRECT}_column_subchan" \
   "${MS}"

for i in *image.fits
do 
	apptainer run $AEGEAN BANE --cores 4 --stripes 3 $i
	apptainer run $AEGEAN aegean --maxsummit 5 --nocov --autoload "$i"; donfor i in *image.fits; do BANE --cores 4 --stripes 3 $i ;  aegean --maxsummit 5 --nocov --autoload "$i" 
done


