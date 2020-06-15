#!/bin/sh
set -e
# Go the sources directory to run commands
SOURCE="${BASH_SOURCE[0]}"
DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
cd $DIR
echo $(pwd)

# glyphs2ufo --no-preserve-glyphsapp-metadata -m NotoSans/ -n ./ NotoSans/OpenSans-MM.glyphs
# glyphs2ufo --no-preserve-glyphsapp-metadata -m NotoSans/ -n ./ NotoSans/OpenSans-ItalicMM.glyphs
fontmake --round-instances -o ufo -i -m NotoSans/OpenSans-Roman.designspace
fontmake --round-instances -o ufo -i -m NotoSans/OpenSans-Italic.designspace
# Not using Thin for now
rm -rf OpenSans-*Thin*.ufo
# Not using SemiBold
rm -rf OpenSans-*SemiBold*.ufo

# echo "Generating Static fonts"
# mkdir -p ../fonts
# fontmake --expand-features-to-instances -m OpenSans-Roman.designspace -i -o ttf --output-dir ../fonts/ttf/
# fontmake --expand-features-to-instances -m OpenSans-Italic.designspace -i -o ttf --output-dir ../fonts/ttf/
# 
# echo "Generating VFs"
# mkdir -p ../fonts/variable
# fontmake -o variable -m OpenSans-Roman.designspace --output-path "../fonts/variable/OpenSans[wdth,wght].ttf"
# fontmake -o variable -m OpenSans-Italic.designspace --output-path "../fonts/variable/OpenSans-Italic[wdth,wght].ttf"
# 
# echo "Post processing Static fonts"
# ttfs=$(ls ../fonts/ttf/OpenSans*.ttf)
# for ttf in $ttfs
# do
# 	gftools fix-dsig -f $ttf;
# 	# python3 -m ttfautohint $ttf "$ttf.fix";
# 	# mv "$ttf.fix" $ttf;
# done
# 
# 
# vfs=$(ls ../fonts/variable/OpenSans*.ttf)
# echo "Post processing VFs"
# for vf in $vfs
# do
# 	gftools fix-dsig -f $vf;
# # 	./ttfautohint-vf --stem-width-mode nnn $vf "$vf.fix";
# # 
# # 	mv "$vf.fix" $vf;
# done
# 
# echo "Dropping MVAR"
# for vf in $vfs
# do
# 	# mv "$vf.fix" $vf;
# 	ttx -f -x "MVAR" $vf; # Drop MVAR. Table has issue in DW
# 	rtrip=$(basename -s .ttf $vf)
# 	new_file=../fonts/variable/$rtrip.ttx;
# 	rm $vf;
# 	ttx $new_file
# 	rm $new_file
# done
# 
# echo "Fixing Non-Hinting"
# for ttf in $ttfs
# do
# 	# gftools fix-hinting $ttf;
# 	# mv "$ttf.fix" $ttf;
# 	gftools fix-nonhinting $ttf $ttf;
# done
# for vf in $vfs
# do
# 	gftools fix-nonhinting $vf $vf;
# done
# rm ../fonts/variable/*gasp.ttf
# rm ../fonts/ttf/*gasp.ttf
