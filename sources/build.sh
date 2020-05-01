#!/bin/sh
set -e

# Go the sources directory to run commands
SOURCE="${BASH_SOURCE[0]}"
DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
cd $DIR
echo $(pwd)

rm -rf master_ufo/ instance_ufo/ instance_ufos/*
rm -rf ../fonts

echo "Generating Static fonts"
mkdir -p ../fonts
fontmake --expand-features-to-instances -m OpenSans-Roman.designspace -i -o ttf --output-dir ../fonts/ttf/
fontmake --expand-features-to-instances -m OpenSans-Italic.designspace -i -o ttf --output-dir ../fonts/ttf/
fontmake --expand-features-to-instances -m OpenSans-Roman.designspace -i -o otf --output-dir ../fonts/otf/
fontmake --expand-features-to-instances -m OpenSans-Italic.designspace -i -o otf --output-dir ../fonts/otf/

echo "Generating VFs"
mkdir -p ../fonts/variable
fontmake -m OpenSans-Roman.designspace -o variable --output-path "../fonts/variable/OpenSans[wdth,wght].ttf"
fontmake -m OpenSans-Italic.designspace -o variable --output-path "../fonts/variable/OpenSans-Italic[wdth,wght].ttf"

rm -rf master_ufo/ instance_ufo/ instance_ufos

echo "Instanciate Condensed Light Italic"
# fonttools varLib.instancer -o ../fonts/variable/OpenSans-CondensedItalic[wght].ttf ../fonts/variable/OpenSans-Italic[wdth,wght].ttf "wdth=75"
# fonttools varLib.instancer -o ../fonts/variable/OpenSans[wght].ttf ../fonts/variable/OpenSans[wdth,wght].ttf "wdth=drop"
fonttools varLib.instancer -o ../fonts/variable/OpenSans-Italic[wght].ttf ../fonts/variable/OpenSans-Italic[wdth,wght].ttf "wdth=drop"
# fonttools varLib.instancer -o ../fonts/variable/OpenSans-Condensed[wght].ttf ../fonts/variable/OpenSans[wdth,wght].ttf "wdth=75"
# fonttools varLib.instancer -o ../fonts/variable/OpenSans-CondensedItalic[wght].ttf ../fonts/variable/OpenSans-Italic[wdth,wght].ttf "wdth=75"
fonttools varLib.instancer -o ../fonts/variable/OpenSans-CondensedItalic[wght].ttf ../fonts/variable/OpenSans-Italic[wdth,wght].ttf "wdth=75" "wght=100"

echo "Drop CondensedExtraBoldItalic and interpolated instances"
rm ../fonts/otf/*Condensed{ExtraBold,Bold,SemiBold,Italic}.otf
rm ../fonts/ttf/*Condensed{ExtraBold,Bold,SemiBold,Italic}.ttf
rm ../fonts/variable/OpenSans-Italic[wdth,wght].ttf


echo "Post processing Static fonts"
ttfs=$(ls ../fonts/ttf/*.ttf)
for ttf in $ttfs
do
	gftools fix-dsig -f $ttf;
	python3 -m ttfautohint $ttf "$ttf.fix";
	mv "$ttf.fix" $ttf;
	gftools fix-hinting $ttf;
	mv "$ttf.fix" $ttf;
done


vfs=$(ls ../fonts/variable/*.ttf)

echo "Post processing VFs"
for vf in $vfs
do
	gftools fix-dsig -f $vf;
# 	./ttfautohint-vf --stem-width-mode nnn $vf "$vf.fix";
# 
# 	mv "$vf.fix" $vf;
done

echo "Dropping MVAR"
for vf in $vfs
do
	# mv "$vf.fix" $vf;
	ttx -f -x "MVAR" $vf; # Drop MVAR. Table has issue in DW
	rtrip=$(basename -s .ttf $vf)
	new_file=../fonts/variable/$rtrip.ttx;
	rm $vf;
	ttx $new_file
	rm $new_file
done

echo "Fixing VF Meta"
# gftools fix-vf-meta $vfs;
statmake --stylespace stat.stylespace --designspace OpenSans-Roman.designspace --output-path ../fonts/variable/OpenSans[wdth,wght].ttf ../fonts/variable/OpenSans[wdth,wght].ttf;
# statmake --stylespace stat.stylespace --designspace OpenSans-Italic.designspace --output-path ../fonts/variable/OpenSans-Italic[wdth,wght].ttf ../fonts/variable/OpenSans-Italic[wdth,wght].ttf;
# statmake --stylespace stat.stylespace --designspace OpenSans-Roman.designspace --output-path ../fonts/variable/OpenSans[wght].ttf ../fonts/variable/OpenSans[wght].ttf;
statmake --stylespace stat.stylespace --designspace OpenSans-Italic.designspace --output-path ../fonts/variable/OpenSans-Italic[wght].ttf ../fonts/variable/OpenSans-Italic[wght].ttf;
# statmake --stylespace stat.stylespace --designspace OpenSans-Roman.designspace --output-path ../fonts/variable/OpenSans-Condensed[wght].ttf ../fonts/variable/OpenSans-Condensed[wght].ttf;
# statmake --stylespace stat.stylespace --designspace OpenSans-Italic.designspace --output-path ../fonts/variable/OpenSans-CondensedItalic[wght].ttf ../fonts/variable/OpenSans-CondensedItalic[wght].ttf;

echo "Fixing Non-Hinting"
for vf in $vfs
do
	gftools fix-nonhinting $vf $vf;
done
rm ../fonts/variable/*gasp.ttf
