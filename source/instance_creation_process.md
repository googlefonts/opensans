# Making hinted instances

0. open the variable font in VTT
1. `Tools` ↦ `Autohint` ↦ `Light Latin`
2. clean up the hints
3. `Tools` ↦ `Recalc MAXP`
4. use `fonttools` `varLib` to make instances (`instance-[reg|cond].sh` in `/tools`)
5. open your new instance in VTT and autohint it again
6. **do not save it**
7. copy the `cpgm` into a text file and save that
8. close the instance and **do not save it**
9. open the `cpgm` in a text editor
10. add `GROUP Hebrew` to the top, right below the `/* ACT generated...` line
11. copy the Hebrew height CVT section from the source VF: it should be something very similar to the below

  ```
         Hebrew
           SquareHeight
         	106: 1290
         ASM("SVTCA[Y]")
         ASM("CALL[], 106, 89")
                108:     0 /* base line */
         ASM("SVTCA[Y]")
         ASM("CALL[], 108, 89")
           RoundHeight
         	107: 20 ~ 106 @ 42 /* overshoot height */
         	109: -4 ~ 108 @ 60 /* overshoot baseline */
         	110: -492 /* descender */
  ```

       

11. paste it into the new instance's `cpgm` between the `Figure ...` and `Other ...` sections

12. change each Hebrew CVT from 1xx to 3xx: in other words, add 200 to every occurrence of `[106...110]` in that section

13. dump the instance's `VTTTalk` to text

14. open the `VTTTalk` in a text editor

15. regex:
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
