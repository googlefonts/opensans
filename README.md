# Open Sans
variable font

![Open Sans sample](/docs/sample.png)

Originally designed by Steve Matteson of Ascender
Hebrew by Yanek Iontef
Weight expansion by Micah Stupak
Help and advice from Meir Sadan and Marc Foley


## Building fonts

```
# Create a new virtual env and install dependencies
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt


# Change to source dir and generate fonts
cd source
sh build.sh
```

# Relation with Noto Sans
The Open Sans styles have been updated from Noto Sans sources.
Noto Sans has 4 masters in each width and slant.
The lightest Noto Sans master is lighter than the lightest Open Sans master.
The two boldest master match exactly.

Mapping between Open Sans weights and Noto Sans master values:
Open Sans (GF) | wght | Noto Sans (master) | wght 
---------------|------|--------------------|-----
–              |      |               Thin | 26
Light          |   50 |               –    |     
Regular        |   83 |               –    |     
–              |      |            Regular | 90
SemiBold       |  117 |               –    |     
Bold           |  151 |               Bold |   151
ExtraBold      |  151 |              Black |   190

To generate then Open Sans masters, the following was done to Noto Sans sources:
- scale Noto Sans from 1000 units-per-em to 2048 units-per-em.
- rename Noto Sans as Open Sans
- rename g as g.alt, add double-storey g from Open Sans
- swap I and I.alt, and apply to composite glyphs
- change IJ to have J with descender
- swap florin and florin.ss03, rename as florin.salt
- add math symbols to Roman, that are in Italic, from Open Sans

The Noto Sans sources are kept in the folder sources/NotoSans.

UFO that match the Open Sans masters have been generated with sources/build_masters_from_noto.sh.
They are the sources used to generate TTFs with sources/build.sh.

The Hebrew glyphs and their features are not in the NotoSans UFOs.
