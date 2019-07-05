import sys
from fontTools.ttLib import TTFont
filename = sys.argv[1]
ttFont = TTFont(filename)

modified = []
for glyphname in ttFont['glyf'].keys():
  try:
    asm = ttFont['TSI1'].glyphPrograms[glyphname]
    if "OFFSET" in asm:
      asm = "USEMYMETRICS[]\r" + '\r'.join([line for line in asm.split('\r') if 'OFFSET' in line])
      ttFont['TSI1'].glyphPrograms[glyphname] = asm
      modified.append(glyphname)
    else:
      print(f"Skip '{glyphname}'")
  except:
    print(f"No program for '{glyphname}'")
ttFont.save(filename.split('.ttf')[0] + "-alt.ttf")
print(f"These glyphs were modified by the script:\n{', '.join(modified)}")


