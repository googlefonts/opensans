1. fontmake .glyphs to UFO

	`fontmake -g source/OpenSans-[Roman|Italic].glyphs -o ufo --no-production-names`
2. convert UFOs to quadratic

	`python3 -m cu2qu -i $allUFOs`
~~3. manually copy `features.fea` from `/opensans` to overwrite the one inside each UFO~~ appears unnecessary
4. fontmake UFO to ttf with designspace

	`fontmake -m OpenSans-[Roman|Italic]-quadratic.designspace -o variable`

5. edit default `wght` in `fvar` to be 400 and not 300
