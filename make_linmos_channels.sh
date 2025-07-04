#!/usr/bin/bash -l
#SBATCH --job-name=flint
#SBATCH --export=NONE
#SBATCH --cpus-per-task=4
#SBATCH --ntasks=1
#SBATCH --mem=32GB
#SBATCH --time=1-23:00:00
#SBATCH -A OD-207757
#SBATCH --array=0-73%73

export OMP_NUM_THREADS=4
export OMP_NUM_THREADS="${SLURM_CPUS_ON_NODE}"

module load apptainer

OUTPUT="Transform"
HOLOFILE="/scratch3/gal16b/emu_download/raw/47138/LinmosBeamImages/akpb.iquv.closepack36.54.943MHz.SB45636.cube.fits"
YANDA="/scratch3/gal16b/containers/yanda/yandasoft_development_20240819.sif"
AEGEAN="/scratch3/gal16b/containers/aegean.sif"

images=$(ls --format=commas "${OUTPUT}/all_beam"??"_DATA"*"-image.fits" | sed -e 's| ||g')


CHAN=$(printf "%04d" "${SLURM_ARRAY_TASK_ID}")
DATAPARSET="${OUTPUT}/image_data_${CHAN}.parset"

names="["
beamorder="["
for i in {0..35}
do
    beam=$(printf "%02d" "$i")
    names="${names}${OUTPUT}/all_beam${beam}_DATA_column_subchan-t0001-${CHAN}-image "
    beamorder="${beamorder}$i "
done
names=$(echo $names | sed -e 's| |,|g')
names="${names}]"

beamorder=$(echo $beamorder | sed -e 's| |,|g')
beamorder="${beamorder}]"


echo "linmos.names = ${names}" > "${DATAPARSET}"
echo "linmos.beams = ${beamorder}" >> "${DATAPARSET}"
echo "linmos.imagetype        = fits" >> "${DATAPARSET}"
echo "linmos.outname          = ${OUTPUT}/example_datacolumn_${CHAN}_image" >> "${DATAPARSET}"
echo "linmos.outweight        = ${OUTPUT}/example_datacolumn_${CHAN}_weight" >> "${DATAPARSET}"
echo "linmos.weighttype      = FromPrimaryBeamModel" >> ${DATAPARSET}
echo "linmos.primarybeam      = ASKAP_PB" >> "${DATAPARSET}"
echo "linmos.primarybeam.ASKAP_PB.image = ${HOLOFILE}" >>  "${DATAPARSET}"
    
cat "${DATAPARSET}"

apptainer run "${YANDA}" linmos -c "${DATAPARSET}"
apptainer run "${AEGEAN}" BANE --cores 4 --stripes 3 "${OUTPUT}/example_datacolumn_${CHAN}_image.fits"
	apptainer run $AEGEAN aegean --maxsummit 5 --nocov --autoload "${OUTPUT}/example_datacolumn_${CHAN}_image.fits"


# -----------------------------------------------------------
# And here is the one for the test data column
# -----------------------------------------------------------

DATAPARSET="${OUTPUT}/image_test_${CHAN}.parset"

names="["
beamorder="["
for i in {0..35}
do
    beam=$(printf "%02d" "$i")
    names="${names}${OUTPUT}/all_beam${beam}_TEST_column_subchan-t0001-${CHAN}-image "
    beamorder="${beamorder}$i "
done
names=$(echo $names | sed -e 's| |,|g')
names="${names}]"

beamorder=$(echo $beamorder | sed -e 's| |,|g')
beamorder="${beamorder}]"


echo "linmos.names = ${names}" > "${DATAPARSET}"
echo "linmos.beams = ${beamorder}" >> "${DATAPARSET}"
echo "linmos.imagetype        = fits" >> "${DATAPARSET}"
echo "linmos.outname          = ${OUTPUT}/example_testcolumn_${CHAN}_image" >> "${DATAPARSET}"
echo "linmos.outweight        = ${OUTPUT}/example_testcolumn_${CHAN}_weight" >> "${DATAPARSET}"
echo "linmos.weighttype      = FromPrimaryBeamModel" >> ${DATAPARSET}
echo "linmos.primarybeam      = ASKAP_PB" >> "${DATAPARSET}"
echo "linmos.primarybeam.ASKAP_PB.image = ${HOLOFILE}" >>  "${DATAPARSET}"
    
cat "${DATAPARSET}"

apptainer run "${YANDA}" linmos -c "${DATAPARSET}"
apptainer run "${AEGEAN}" BANE --cores 4 --stripes 3 "${OUTPUT}/example_testcolumn_${CHAN}_image.fits"
apptainer run $AEGEAN aegean --maxsummit 5 --nocov --autoload "${OUTPUT}/example_testcolumn_${CHAN}_image.fits"
