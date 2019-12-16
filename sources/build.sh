#!/bin/sh
set -e

rm -rf master_ufo/ instance_ufo/ instance_ufos/*

echo "Generating Static fonts"
mkdir -p ../fonts
fontmake -m OpenSans-Roman.designspace -i -o ttf --output-dir ../fonts/ttf/

fontmake -m OpenSans-Roman.designspace -i -o otf --output-dir ../fonts/otf/

echo "Generating VFs"
fontmake -m OpenSans-Roman.designspace -o variable --output-path ../fonts/vf/OpenSans[wght].ttf

rm -rf master_ufo/ instance_ufo/ instance_ufos/*


echo "Post processing"
ttfs=$(ls ../fonts/ttf/*.ttf)
for ttf in $ttfs
do
	gftools fix-dsig -f $ttf;
	ttfautohint $ttf "$ttf.fix";
	mv "$ttf.fix" $ttf;
done

for ttf in $ttfs
do
	gftools fix-hinting $ttf;
	mv "$ttf.fix" $ttf;
done


vfs=$(ls ../fonts/vf/*\[wght\].ttf)

echo "Post processing VFs"
for vf in $vfs
do
	gftools fix-dsig -f $vf;
	# ttfautohint-vf --stem-width-mode nnn $vf "$vf.fix";
	ttfautohint --stem-width-mode nnn $vf "$vf.fix";

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
gftools fix-vf-meta $vfs;

echo "Fixing Hinting"
for vf in $vfs
do
	gftools fix-hinting $vf;
	mv "$vf.fix" $vf;
done


