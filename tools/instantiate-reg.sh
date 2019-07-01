weights=(300 400 600 700 800)
widths=(75 100)
for I in ${weights[@]}; do
	fonttools varLib.mutator ../source/TTF\ VTT\ source/OpenSans-Italic.ttf wght="$I" wdth=100;
	mv  ../source/TTF\ VTT\ source/OpenSans-Italic-instance.ttf  ../source/TTF\ VTT\ source/OpenSans-Italic-"$I"-100.ttf
done