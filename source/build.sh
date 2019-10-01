#!/usr/bin/env bash

set -e

echo "Converting .glyphs to .ufo"
fontmake -g ./OpenSans-Roman.glyphs -o ufo
fontmake -g ./OpenSans-Italic.glyphs -o ufo

echo "Converting cubic curves to quadratic"
cu2qu ./master_ufo/OpenSans-Light.ufo/ ./master_ufo/OpenSans-Bold.ufo/ ./master_ufo/OpenSans-ExtraBold.ufo/ ./master_ufo/OpenSans-CondensedLight.ufo/ ./master_ufo/OpenSans-CondensedBold.ufo/ ./master_ufo/OpenSans-CondensedExtraBold.ufo/ -i
cu2qu ./master_ufo/OpenSans-LightItalic.ufo/ ./master_ufo/OpenSans-ExtraBoldItalic.ufo/ ./master_ufo/OpenSans-CondensedLightItalic.ufo/ ./master_ufo/OpenSans-CondensedExtraBoldItalic.ufo/ -i

echo "Generating VFs"
VF_FILENAME_ROMAN="../fonts/vf/OpenSans[wdth,wght].ttf"
VF_FILENAME_ITALIC="../fonts/vf/OpenSans-Italic[wdth,wght].ttf"
fontmake -m OpenSans-Roman.designspace -o variable --output-path $VF_FILENAME_ROMAN
fontmake -m OpenSans-Italic.designspace -o variable --output-path $VF_FILENAME_ITALIC


rm -rf ./master_ufo ./instance_ufo/

# Drop MVAR and patch name and stat tables
ttx -m $VF_FILENAME_ROMAN OpenSans-Roman-patch.ttx
mv OpenSans-Roman-patch.ttf $VF_FILENAME_ROMAN

ttx -x "MVAR" $VF_FILENAME_ROMAN
rm $VF_FILENAME_ROMAN
ttx "${VF_FILENAME_ROMAN%.*}.ttx"


ttx -m $VF_FILENAME_ITALIC OpenSans-Italic-patch.ttx
mv OpenSans-Italic-patch.ttf $VF_FILENAME_ITALIC

ttx -x "MVAR" $VF_FILENAME_ITALIC
rm $VF_FILENAME_ITALIC
ttx "${VF_FILENAME_ITALIC%.*}.ttx"

rm ../fonts/vf/*.ttx

echo "Post processing VFs"
gftools fix-dsig -f $VF_FILENAME_ROMAN
gftools fix-dsig -f $VF_FILENAME_ITALIC

gftools fix-nonhinting $VF_FILENAME_ROMAN $VF_FILENAME_ROMAN.fix
gftools fix-nonhinting $VF_FILENAME_ITALIC $VF_FILENAME_ITALIC.fix
mv $VF_FILENAME_ROMAN.fix $VF_FILENAME_ROMAN
mv $VF_FILENAME_ITALIC.fix $VF_FILENAME_ITALIC
rm ../fonts/vf/*gasp.ttf
