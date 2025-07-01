#!/usr/bin/bash -l
#SBATCH --job-name=flint
#SBATCH --export=NONE
#SBATCH --ntasks-per-node=4
#SBATCH --ntasks=1
#SBATCH --mem=32GB
#SBATCH --time=1-23:00:00
#SBATCH -A OD-207757
#SBATCH --array=0-36%36

module load wsclean
module load apptainer
conda activate flint_main

RAW="/scratch3/gal16b/emu_download/raw/47138"
OUTPUT="Transform"

if [[ ! -e "${OUTPUT}" ]]
then
   mkdir "${OUTPUT}"
fi

BEAM=$(printf "%02d" "${SLURM_ARRAY_TASK_ID}")
ORIGMS="${RAW}/scienceData.EMU_1141-55.SB47138.EMU_1141-55.beam${BEAM}_averaged_cal.leakage.ms"
MS="${OUTPUT}/scienceData.EMU_1141-55.SB47138.EMU_1141-55.beam${BEAM}_averaged_cal.leakage.ms"
AEGEAN="/scratch3/gal16b/containers/aegean.sif"
CASA="/scratch3/gal16b/containers/casa_ks9-5.8.0.sif"
DATA="DATA"
CORRECT="TEST"

apptainer run "${CASA}" casa --nogui -c "mstransform(vis='${ORIGMS}',outputvis='${MS}',datacolumn='all')"

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


