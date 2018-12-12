# ————————————————————————————————————————————— Build Roman —————————————————————————————————————————————
cp "Open Sans V.glyphs" OpenSansBuild.glyphs

# Add bracket layers to build version
python2 $(dirname ${BASH_SOURCE[0]})/fixBrackets.py OpenSansBuild.glyphs

rm -rf addFeatureVars.py

fontmake -o variable -g OpenSansBuild.glyphs --keep-direction

mv variable_ttf/OpenSans-VF.ttf OpenSans-VF.ttf

rm -rf OpenSansBuild.glyphs
rm -rf master_ufo
rm -rf variable_ttf

gftools fix-dsig --autofix OpenSans-VF.ttf

python2 $(dirname ${BASH_SOURCE[0]})/corrected-addFeatureVars.py OpenSans-VF.ttf

ttx OpenSans-VF.ttf
rm -rf OpenSans-VF.ttf

cat OpenSans-VF.ttx | tr '\n' '\r' | sed -e "s~<name>.*<\/name>~$(cat $(dirname ${BASH_SOURCE[0]})/patchRoman-name.xml | tr '\n' '\r')~" | tr '\r' '\n' > OpenSans-VF-name.ttx
cat OpenSans-VF-name.ttx | tr '\n' '\r' | sed -e "s,<STAT>.*<\/STAT>,$(cat $(dirname ${BASH_SOURCE[0]})/patchRoman-STAT.xml | tr '\n' '\r')," | tr '\r' '\n' > OpenSans-VF-STAT.ttx

rm -rf OpenSans-VF.ttx
rm -rf OpenSans-VF-name.ttx

ttx OpenSans-VF-STAT.ttx

rm -rf OpenSans-VF-STAT.ttx

mv OpenSans-VF-STAT.ttf OpenSans-VF.ttf


# ————————————————————————————————————————————— Build Italic —————————————————————————————————————————————
cp "Open Sans Italic V.glyphs" OpenSansItalicBuild.glyphs

# Add bracket layers to build version
python2 $(dirname ${BASH_SOURCE[0]})/fixBrackets.py OpenSansItalicBuild.glyphs

fontmake -o variable -g OpenSansItalicBuild.glyphs

mv variable_ttf/OpenSans-VF.ttf OpenSansItalic-VF.ttf

rm -rf OpenSansItalicBuild.glyphs
rm -rf master_ufo
rm -rf variable_ttf

gftools fix-dsig --autofix OpenSansItalic-VF.ttf

python2 addFeatureVars.py OpenSansItalic-VF.ttf

rm -rf addFeatureVars.py

ttx OpenSansItalic-VF.ttf
rm -rf OpenSansItalic-VF.ttf

cat OpenSansItalic-VF.ttx | tr '\n' '\r' | sed -e "s~<name>.*<\/name>~$(cat $(dirname ${BASH_SOURCE[0]})/patchItalic-name.xml | tr '\n' '\r')~" | tr '\r' '\n' > OpenSansItalic-VF-name.ttx
cat OpenSansItalic-VF-name.ttx | tr '\n' '\r' | sed -e "s,<STAT>.*<\/STAT>,$(cat $(dirname ${BASH_SOURCE[0]})/patchItalic-STAT.xml | tr '\n' '\r')," | tr '\r' '\n' > OpenSansItalic-VF-STAT.ttx

rm -rf OpenSansItalic-VF.ttx
rm -rf OpenSansItalic-VF-name.ttx

ttx OpenSansItalic-VF-STAT.ttx

rm -rf OpenSansItalic-VF-STAT.ttx

mv OpenSansItalic-VF-STAT.ttf OpenSansItalic-VF.ttf