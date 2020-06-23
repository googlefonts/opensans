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
# fontmake --expand-features-to-instances -m OpenSans-Roman.designspace -i -o otf --output-dir ../fonts/otf/
# fontmake --expand-features-to-instances -m OpenSans-Italic.designspace -i -o otf --output-dir ../fonts/otf/

echo "Generating VFs"
mkdir -p ../fonts/variable
fontmake -m OpenSans-Roman.designspace -o variable --output-path "../fonts/variable/OpenSans[wdth,wght].ttf"
fontmake -m OpenSans-Italic.designspace -o variable --output-path "../fonts/variable/OpenSans-Italic[wdth,wght].ttf"

rm -rf master_ufo/ instance_ufo/ instance_ufos

echo "Discard Thin for now (extrapolated Hebrew)"
rm ../fonts/ttf/*Thin*.ttf
# rm ../fonts/otf/*Thin*.otf
fonttools varLib.instancer -o ../fonts/variable/OpenSans[wdth,wght].ttf ../fonts/variable/OpenSans[wdth,wght].ttf "wght=300:800"
fonttools varLib.instancer -o ../fonts/variable/OpenSans-Italic[wdth,wght].ttf ../fonts/variable/OpenSans-Italic[wdth,wght].ttf "wght=300:800"

echo "Instanciate single axis variable fonts"
fonttools varLib.instancer -o ../fonts/variable/OpenSans[wght].ttf ../fonts/variable/OpenSans[wdth,wght].ttf "wdth=drop"
fonttools varLib.instancer -o ../fonts/variable/OpenSans-Italic[wght].ttf ../fonts/variable/OpenSans-Italic[wdth,wght].ttf "wdth=drop"
fonttools varLib.instancer -o ../fonts/variable/OpenSans-Condensed[wght].ttf ../fonts/variable/OpenSans[wdth,wght].ttf "wdth=75"
fonttools varLib.instancer -o ../fonts/variable/OpenSans-CondensedItalic[wght].ttf ../fonts/variable/OpenSans-Italic[wdth,wght].ttf "wdth=75"
# Use this to not use Condensed ExtraBold Italic or its interpolations
# fonttools varLib.instancer -o ../fonts/variable/OpenSans-CondensedItalic[wght].ttf ../fonts/variable/OpenSans-Italic[wdth,wght].ttf "wdth=75" "wght=100"

# echo "Drop CondensedExtraBoldItalic and interpolated instances"
# rm ../fonts/otf/*Condensed{ExtraBold,Bold,SemiBold,,Light}Italic.otf
# rm ../fonts/ttf/*Condensed{ExtraBold,Bold,SemiBold,,Light}Italic.ttf
# rm ../fonts/variable/OpenSans[wdth,wght].ttf
# rm ../fonts/variable/OpenSans-Italic[wdth,wght].ttf
# echo "Drop CondensedExtraBold and interpolated instances"
# rm ../fonts/otf/*Condensed{ExtraBold,Bold,SemiBold,,Light}.otf
# rm ../fonts/ttf/*Condensed{ExtraBold,Bold,SemiBold,,Light}.ttf
# rm ../fonts/variable/OpenSans-Condensed[wght].ttf
# rm ../fonts/variable/OpenSans-CondensedItalic[wght].ttf


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
statmake --stylespace stat.stylespace --designspace OpenSans-Italic.designspace --output-path ../fonts/variable/OpenSans-Italic[wdth,wght].ttf ../fonts/variable/OpenSans-Italic[wdth,wght].ttf;
statmake --stylespace stat.stylespace --designspace OpenSans-Roman.designspace --output-path ../fonts/variable/OpenSans[wght].ttf ../fonts/variable/OpenSans[wght].ttf;
statmake --stylespace stat.stylespace --designspace OpenSans-Italic.designspace --output-path ../fonts/variable/OpenSans-Italic[wght].ttf ../fonts/variable/OpenSans-Italic[wght].ttf;
statmake --stylespace stat.stylespace --designspace OpenSans-Roman.designspace --output-path ../fonts/variable/OpenSans-Condensed[wght].ttf ../fonts/variable/OpenSans-Condensed[wght].ttf;
statmake --stylespace stat.stylespace --designspace OpenSans-Italic.designspace --output-path ../fonts/variable/OpenSans-CondensedItalic[wght].ttf ../fonts/variable/OpenSans-CondensedItalic[wght].ttf;

echo "Fixing Non-Hinting"
for vf in $vfs
do
	gftools fix-nonhinting $vf $vf;
done
rm -f ../fonts/variable/*gasp.ttf
# rm -f ../fonts/ttf/*gasp.ttf

echo "Subset fonts"
mkdir -p ../fonts/noto-set/variable
for vf in $vfs
	do pyftsubset $vf --drop-tables= --recalc-bounds --recalc-average-width --name-IDs='*' --name-legacy --glyph-names --glyphs-file=OpenSans-glyphset.txt --layout-features="aalt,rvrn,ccmp,dnom,frac,liga,lnum,locl,mark,mkmk,numr,onum,ordn,pnum,rtlm,salt,ss01,ss02,ss03,ss04,subs,sups,tnum,zero";
	mv $vf ../fonts/noto-set/variable/
	mv ${vf%.*}.subset.ttf $vf
done
mkdir -p ../fonts/noto-set/ttf
for ttf in $ttfs
	do pyftsubset $ttf --drop-tables= --recalc-bounds --recalc-average-width --name-IDs='*' --name-legacy --glyph-names --glyphs-file=OpenSans-glyphset.txt --layout-features="aalt,rvrn,ccmp,dnom,frac,liga,lnum,locl,mark,mkmk,numr,onum,ordn,pnum,rtlm,salt,ss01,ss02,ss03,ss04,subs,sups,tnum,zero";
	mv $ttf ../fonts/noto-set/ttf/
	mv ${ttf%.*}.subset.ttf $ttf
	# recalculate hhea.advanceWidthMax
	python -c "from fontTools.ttLib import TTFont; import sys; filename=sys.argv[-1]; font=TTFont(filename); max_adv_width = max(adv for adv, lsb in font['hmtx'].metrics.values()); font['hhea'].advanceWidthMax = max_adv_width; font.save(filename)" $ttf
done
