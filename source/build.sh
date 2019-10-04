#!/usr/bin/env bash

set -e

generate_vf () {
	# arg1: input.glyphs file, arg2: out.ttf

	fontmake -g $1 -o ufo --no-production-names
	cu2qu $(ls -d ./master_ufo/*.ufo) -i
	fontmake -m ./master_ufo/*.designspace -o variable --output-path $2
}


postprocess_vf () {
	# arg1: input.ttf, arg2: patchfile.ttx

	# Patch in STAT table
	ttx -m $1 $2
	mv "${2%.*}.ttf" $1

	# Drop MVAR
	ttx -x "MVAR" $1
	ttx -f "${1%.*}.ttx"
	rm "${1%.*}.ttx"

	postprocess_ttf $1
}


postprocess_ttf () {
	# arg 1: input.ttf

	gftools fix-dsig -f $1
	gftools fix-nonhinting $1 $1.fix
	mv $1.fix $1
	rm $(dirname "$1")/*gasp.ttf
}


instantiate_instance () {
	# arg 1: input.ttf arg2: wght_axis arg3: wdth_axis arg4: out
	fontTools varLib.mutator $1 wght=$2 wdth=$3
	mv "${1%.*}-instance.ttf" $4
	postprocess_ttf $1
}


# --------------


VF_ROMAN_SRC="./OpenSans-Roman.glyphs"
VF_ITALIC_SRC="./OpenSans-Italic.glyphs"

VF_ROMAN_OUT="../fonts/vf/OpenSans[wdth,wght].ttf"
VF_ITALIC_OUT="../fonts/vf/OpenSans-Italic[wdth,wght].ttf"

rm -rf ../fonts
mkdir -p ../fonts ../fonts/vf ../fonts/ttf

echo "Generating VFs"
generate_vf $VF_ROMAN_SRC $VF_ROMAN_OUT
rm -rf ./master_ufo ./instance_ufo
generate_vf $VF_ITALIC_SRC $VF_ITALIC_OUT
rm -rf ./master_ufo ./instance_ufo

echo "Post processing VFs"
postprocess_vf $VF_ROMAN_OUT OpenSans-Roman-patch.ttx
postprocess_vf $VF_ITALIC_OUT OpenSans-Italic-patch.ttx

echo "Instantiating Instances"
# Roman
instantiate_instance $VF_ROMAN_OUT 300 100 ../fonts/ttf/OpenSans-Light.ttf
instantiate_instance $VF_ROMAN_OUT 400 100 ../fonts/ttf/OpenSans-Regular.ttf
instantiate_instance $VF_ROMAN_OUT 600 100 ../fonts/ttf/OpenSans-SemiBold.ttf
instantiate_instance $VF_ROMAN_OUT 700 100 ../fonts/ttf/OpenSans-Bold.ttf
instantiate_instance $VF_ROMAN_OUT 800 100 ../fonts/ttf/OpenSans-ExtraBold.ttf
# Italic
instantiate_instance $VF_ITALIC_OUT 300 100 ../fonts/ttf/OpenSans-LightItalic.ttf
instantiate_instance $VF_ITALIC_OUT 400 100 ../fonts/ttf/OpenSans-Italic.ttf
instantiate_instance $VF_ITALIC_OUT 600 100 ../fonts/ttf/OpenSans-SemiBoldItalic.ttf
instantiate_instance $VF_ITALIC_OUT 700 100 ../fonts/ttf/OpenSans-BoldItalic.ttf
instantiate_instance $VF_ITALIC_OUT 800 100 ../fonts/ttf/OpenSans-ExtraBoldItalic.ttf
# Condensed Roman
instantiate_instance $VF_ROMAN_OUT 300 75 ../fonts/ttf/OpenSansCondensed-Light.ttf
instantiate_instance $VF_ROMAN_OUT 400 75 ../fonts/ttf/OpenSansCondensed-Regular.ttf
instantiate_instance $VF_ROMAN_OUT 600 75 ../fonts/ttf/OpenSansCondensed-SemiBold.ttf
instantiate_instance $VF_ROMAN_OUT 700 75 ../fonts/ttf/OpenSansCondensed-Bold.ttf
instantiate_instance $VF_ROMAN_OUT 800 75 ../fonts/ttf/OpenSansCondensed-ExtraBold.ttf
# Condensed Italic
instantiate_instance $VF_ITALIC_OUT 300 75 ../fonts/ttf/OpenSansCondensed-LightItalic.ttf
instantiate_instance $VF_ITALIC_OUT 400 75 ../fonts/ttf/OpenSansCondensed-Italic.ttf
instantiate_instance $VF_ITALIC_OUT 600 75 ../fonts/ttf/OpenSansCondensed-SemiBoldItalic.ttf
instantiate_instance $VF_ITALIC_OUT 700 75 ../fonts/ttf/OpenSansCondensed-BoldItalic.ttf
instantiate_instance $VF_ITALIC_OUT 800 75 ../fonts/ttf/OpenSansCondensed-ExtraBoldItalic.ttf
