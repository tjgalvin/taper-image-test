#!/usr/bin/bash -l
#SBATCH --job-name=flint
#SBATCH --export=NONE
#SBATCH --ntasks-per-node=4
#SBATCH --ntasks=1
#SBATCH --mem=32GB
#SBATCH --time=1-23:00:00
#SBATCH -A OD-207757

export OMP_NUM_THREADS=4

module load apptainer

OUTPUT="Transform"
HOLOFILE="/scratch3/gal16b/emu_download/raw/47138/LinmosBeamImages/akpb.iquv.closepack36.54.943MHz.SB45636.cube.fits"
YANDA="/scratch3/gal16b/containers/yanda/yandasoft_development_20240819.sif"

images=$(ls --format=commas "${OUTPUT}/all_beam"??"_DATA"*"-image.fits" | sed -e 's| ||g')


DATAPARSET="${OUTPUT}/image_data.parset"

names="["
beamorder="["
for i in {0..35}
do
    beam=$(printf "%02d" "$i")
    names="${names}${OUTPUT}/all_beam${beam}_DATA_column_subchan-t0001-image "
    beamorder="${beamorder}$i "
done
names=$(echo $names | sed -e 's| |,|g')
names="${names}]"

beamorder=$(echo $beamorder | sed -e 's| |,|g')
beamorder="${beamorder}]"


echo "linmos.names = ${names}" > "${DATAPARSET}"
echo "linmos.beams = ${beamorder}" >> "${DATAPARSET}"
echo "linmos.imagetype        = fits" >> "${DATAPARSET}"
echo "linmos.outname          = ${OUTPUT}/example_datacolumn_image.fits" >> "${DATAPARSET}"
echo "linmos.outweight        = ${OUTPUT}/example_datacolumn_weight.fits" >> "${DATAPARSET}"
echo "linmos.weighttype      = FromPrimaryBeamModel" >> ${DATAPARSET}
echo "linmos.primarybeam      = ASKAP_PB" >> "${DATAPARSET}"
echo "linmos.primarybeam.ASKAP_PB.image = ${HOLOFILE}" >>  "${DATAPARSET}"
    
cat "${DATAPARSET}"

apptainer run "${YANDA}" linmos -c "${DATAPARSET}"



# -----------------------------------------------------------
# And here is the one for the test data column
# -----------------------------------------------------------


DATAPARSET="${OUTPUT}/image_test.parset"

names="["
beamorder="["
for i in {0..35}
do
    beam=$(printf "%02d" "$i")
    names="${names}${OUTPUT}/all_beam${beam}_TEST_column_subchan-t0001-image "
    beamorder="${beamorder}$i "
done
names=$(echo $names | sed -e 's| |,|g')
names="${names}]"

beamorder=$(echo $beamorder | sed -e 's| |,|g')
beamorder="${beamorder}]"


echo "linmos.names = ${names}" > "${DATAPARSET}"
echo "linmos.beams = ${beamorder}" >> "${DATAPARSET}"
echo "linmos.imagetype        = fits" >> "${DATAPARSET}"
echo "linmos.outname          = ${OUTPUT}/example_testcolumn_image.fits" >> "${DATAPARSET}"
echo "linmos.outweight        = ${OUTPUT}/example_testcolumn_weight.fits" >> "${DATAPARSET}"
echo "linmos.weighttype      = FromPrimaryBeamModel" >> ${DATAPARSET}
echo "linmos.primarybeam      = ASKAP_PB" >> "${DATAPARSET}"
echo "linmos.primarybeam.ASKAP_PB.image = ${HOLOFILE}" >>  "${DATAPARSET}"
    
cat "${DATAPARSET}"

apptainer run "${YANDA}" linmos -c "${DATAPARSET
