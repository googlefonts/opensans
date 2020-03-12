#!/bin/sh
set -e

# Go the sources directory to run commands
SOURCE="${BASH_SOURCE[0]}"
DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
cd $DIR
echo $(pwd)

rm -rf master_ufo/ instance_ufo/ instance_ufos/*

echo "Generating Static fonts"
mkdir -p ../fonts
fontmake --expand-features-to-instances -m OpenSans-Roman.designspace -i -o ttf --output-dir ../fonts/ttf/
fontmake --expand-features-to-instances -m OpenSans-Italic.designspace -i -o ttf --output-dir ../fonts/ttf/
fontmake --expand-features-to-instances -m OpenSans-Roman.designspace -i -o otf --output-dir ../fonts/otf/
fontmake --expand-features-to-instances -m OpenSans-Italic.designspace -i -o otf --output-dir ../fonts/otf/

echo "Generating VFs"
mkdir -p ../fonts/vf
fontmake -m OpenSans-Roman.designspace -o variable --output-path "../fonts/vf/OpenSans[wdth,wght].ttf"
fontmake -m OpenSans-Italic.designspace -o variable --output-path "../fonts/vf/OpenSans-Italic[wdth,wght].ttf"

rm -rf master_ufo/ instance_ufo/ instance_ufos


echo "Instanciate single axis VFs"
fonttools varLib.instancer -o ../fonts/vf/OpenSans[wght].ttf ../fonts/vf/OpenSans[wdth,wght].ttf "wdth=drop"
fonttools varLib.instancer -o ../fonts/vf/OpenSans-Condensed[wght].ttf ../fonts/vf/OpenSans[wdth,wght].ttf "wdth=75"
fonttools varLib.instancer -o ../fonts/vf/OpenSans-Italic[wght].ttf ../fonts/vf/OpenSans-Italic[wdth,wght].ttf "wdth=drop"
fonttools varLib.instancer -o ../fonts/vf/OpenSans-CondensedItalic[wght].ttf ../fonts/vf/OpenSans-Italic[wdth,wght].ttf "wdth=75"

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


vfs=$(ls ../fonts/vf/*.ttf)

echo "Post processing VFs"
for vf in $vfs
do
	gftools fix-dsig -f $vf;
	./ttfautohint-vf --stem-width-mode nnn $vf "$vf.fix";

	mv "$vf.fix" $vf;
	# rm "$vf.fix";
done

echo "Dropping MVAR"
for vf in $vfs
do
	# mv "$vf.fix" $vf;
	ttx -f -x "MVAR" $vf; # Drop MVAR. Table has issue in DW
	rtrip=$(basename -s .ttf $vf)
	new_file=../fonts/vf/$rtrip.ttx;
	rm $vf;
	ttx $new_file
	rm $new_file
done

echo "Fixing VF Meta"
# gftools fix-vf-meta $vfs;
statmake --stylespace OpenSans.stylespace --designspace OpenSans-Roman.designspace --output-path ../fonts/vf/OpenSans[wdth,wght].ttf ../fonts/vf/OpenSans[wdth,wght].ttf;
statmake --stylespace OpenSans-Italic.stylespace --designspace OpenSans-Italic.designspace --output-path ../fonts/vf/OpenSans-Italic[wdth,wght].ttf ../fonts/vf/OpenSans-Italic[wdth,wght].ttf;
statmake --stylespace OpenSans.stylespace --designspace OpenSans-Roman.designspace --output-path ../fonts/vf/OpenSans[wght].ttf ../fonts/vf/OpenSans[wght].ttf;
statmake --stylespace OpenSans-Italic.stylespace --designspace OpenSans-Italic.designspace --output-path ../fonts/vf/OpenSans-Italic[wght].ttf ../fonts/vf/OpenSans-Italic[wght].ttf;
statmake --stylespace OpenSans.stylespace --designspace OpenSans-Roman.designspace --output-path ../fonts/vf/OpenSans-Condensed[wght].ttf ../fonts/vf/OpenSans-Condensed[wght].ttf;
statmake --stylespace OpenSans-Italic.stylespace --designspace OpenSans-Italic.designspace --output-path ../fonts/vf/OpenSans-CondensedItalic[wght].ttf ../fonts/vf/OpenSans-CondensedItalic[wght].ttf;

echo "Fixing Hinting"
for vf in $vfs
do
	gftools fix-hinting $vf;
	if [ -e $vf.fix ];
		then mv "$vf.fix" $vf;
	fi;
done
