#!/usr/bin/env bash

set -e

echo "Converting .glyphs to .ufo"
fontmake -g ./OpenSans-Roman.glyphs -o ufo --no-production-names
fontmake -g ./OpenSans-Italic.glyphs -o ufo --no-production-names

echo "Converting cubic curves to quadratic"
ufos=$(find *_ufo -name *.ufo -type d -maxdepth 1)
for ufo in $ufos
do
	cu2qu -i $ufo
done

echo "Generating VFs"
fontmake -m OpenSans-Roman.designspace -o variable --output-path ../fonts/variable_ttf/OpenSans-Roman-VF.ttf
fontmake -m OpenSans-Italic.designspace -o variable --output-path ../fonts/variable_ttf/OpenSans-Italic-VF.ttf

rm -rf master_ufo/ instance_ufo/

