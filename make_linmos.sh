#!/usr/bin/bash -l

module load apptainer

OUTPUT="Transform"
HOLOFILE="/scratch3/gal16b/emu_download/raw/47138/LinmosBeamImages/akpb.iquv.closepack36.54.943MHz.SB45636.cube.fits"

images=$(ls --format=commas "${OUTPUT}/all_beam"??"_DATA"*"-image.fits" | sed -e 's| ||g')


DATAPARSET="${OUTPUT}/image_data.parset"

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
echo "linmos.outname          = ${OUTPUT}/example_image.fits" >> "${DATAPARSET}"
echo "linmos.outweight        = ${OUTPUT}/example_weight.fits" >> "${DATAPARSET}"
echo "linmos.weighttype      = FromPrimaryBeamModel" >> ${DATAPARSET}
echo "linmos.primarybeam      = ASKAP_PB" >> "${DATAPARSET}"
echo "linmos.primarybeam.ASKAP_PB.image = ${HOLOFILE}" >>  "${DATAPARSET}"
    
cat "${DATAPARSET}"



