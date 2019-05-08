1. fontmake .glyphs to UFO
	`fontmake -g source/OpenSans-Roman-no_brackets.glyphs -o ufo`
2. convert UFOs to quadratic
	`:; for I in *.ufo; do python3 -m cu2qu -i "${I}"; done`
3. manually copy `features.fea` into the UFOs
4. fontmake UFO to ttf with designspace
	`fontmake -m ../../../OpenSans-Roman-quadratic.designspace -o variable`