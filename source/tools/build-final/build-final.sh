cp "Open Sans V.glyphs" OpenSansBuild.glyphs

# Add bracket layers to build version
python2 $(dirname ${BASH_SOURCE[0]})/fixBrackets.py OpenSansBuild.glyphs

rm -rf addFeatureVars.py

fontmake -o variable -g OpenSansBuild.glyphs

mv variable_ttf/OpenSansV-VF.ttf OpenSansV-VF.ttf

rm -rf OpenSansBuild.glyphs
rm -rf master_ufo
rm -rf variable_ttf

python2 $(dirname ${BASH_SOURCE[0]})/corrected-addFeatureVars.py OpenSansV-VF.ttf