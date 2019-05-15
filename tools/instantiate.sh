weights=(300 400 600 700 800)
widths=(60 100)
for I in ${weights[@]};
	do python3 vf2s.py --width 100 --weight "$I" ../source/quadratic/variable_ttf/OpenSans-Roman-quadratic-VF.ttf
done