# Making hinted instances

0. open the variable font in VTT
1. `Tools` ↦ `Autohint` ↦ `Light Latin`
2. clean up the hints
3. `Tools` ↦ `Recalc MAXP`
4. use `fonttools` `varLib` to make instances  
	`fonttools varLib.mutator OpenSans-[Roman|Italic].ttf wght=$wght wdth=$wdth`
5. open your new instance in VTT and autohint it again
6. **do not save it**
7. copy the `cpgm` into a text file and save that
8. close the instance and **do not save it**
9. open the `cpgm` in a text editor
10. take note of the Hebrew height CVTs (should be 106-110)
11. change each Hebrew CVT from 1xx to 3xx (i.e. 106 becomes 306, 107 becomes 307, etc)
12. dump the `VTTTalk` to text
13. open the `VTTTalk` in a text editor
14. regex:
  * search for `ResYAnchor\((\d+),106\)`
  * replace with `ResYAnchor\(\1,306\)`
  * repeat for `107` & `307` and so on
  * finally, save
15. import the `cpgm` and `VTTTalk` into the instance
16. open the instance in VTT
17. `Tools` ↦ `Compile` ↦ `Control values`
18. `Tools` ↦ `Compile everything for all glyphs`
19. **you will probably have errors**: this is expected
20. `ctrl+3` to open the pre-program
21. compile it with `ctrl+r`
22. `ctrl+7` to open the font program
23. compile it with `ctrl+r`
24. compile everything for all again
  * if still errors, try to debug
  * check your Hebrew CVTs
25. `ctrl+9` to open the glyph palette
  * proof them
  * make sure the Hebrew heights in particular look good
26. `Tools` ↦ `Recalc MAXP`
27. you did it, yay
