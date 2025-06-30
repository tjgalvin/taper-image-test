#!/usr/bin/bash -l

module load wsclean
module load apptainer
conda activate flint_main

BEAM=35
ORIGMS="/scratch3/gal16b/emu_download/uvw_test/scienceData.EMU_1141-55.SB47138.EMU_1141-55.beam${BEAM}_averaged_cal.leakage.ms_trans"
MS="scienceData.EMU_1141-55.SB47138.EMU_1141-55.beam${BEAM}_averaged_cal.leakage.ms"
AEGEAN="/scratch3/gal16b/containers/aegean.sif"
DATA="DATA"
CORRECT="TEST"


echo "Making fresh copy of the data"
rm -r "${MS}"
cp -r "${ORIGMS}" "${MS}"

fix_ms_dir "${MS}"

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
   -intervals-out 2 \
   -name "all_beam${BEAM}_${DATA}_column_subchan" \
   "${MS}"

echo "Imaging finished. Running jolly, including modification ot flags"

jolly_tractor \
        tukey \
        --chunk-size 2500 \
        --data-column DATA \
        --output-column TEST \
        --overwrite \
        --target-object sun \
        --apply-towards-object \
        --outer-width 0.5 \
        --ignore-nyquist-zone 1 \
        "${MS}"


echo "Running wsclean on modified data and flags"
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
   -intervals-out 2 \
   -name "all_beam${BEAM}_${CORRECT}_column_subchan" \
   "${MS}"

for i in *image.fits
do 
	apptainer run $AEGEAN BANE --cores 4 --stripes 3 $i
	apptainer run $AEGEAN aegean --maxsummit 5 --nocov --autoload "$i"
done


