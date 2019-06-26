weights=(300 400 600 700 800)
widths=(75 100)
for I in ${weights[@]};
	do python3 vf2s.py --width 100 --weight "$I" ../source/TTF\ VTT\ source/OpenSans-Roman.ttf
done