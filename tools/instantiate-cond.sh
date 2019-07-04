weights=(300 400 600 700 800)
widths=(75 100)
for I in ${weights[@]}; do
	fonttools varLib.mutator ../source/TTF\ VTT\ source/OpenSans-Roman.ttf wght="$I" wdth=75;
	mv  ../source/TTF\ VTT\ source/OpenSans-Roman-instance.ttf  ../source/TTF\ VTT\ source/OpenSans-Roman-wg"$I"wd75.ttf
done