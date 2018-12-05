import os
import sys
import fontTools
from fontTools.ttLib import TTFont
from fontTools.varLib.featureVars import addFeatureVariations

fontPath = sys.argv[-1]

f = TTFont(fontPath)

condSubst = [
	([{"wght" : (0.977777777778, 1.0)}], {"Aringacute" : "Aringacute.rvrn"}), 
	([{"wght" : (0.977777777778, 1.0), "wdth" : (-1.0, -0.5)}], {"uniFB30" : "uniFB30.rvrn"}), 
	([{"wght" : (0.977777777778, 1.0), "wdth" : (-1.0, -0.5)}], {"uniFB34" : "uniFB34.rvrn"}), 
	([{"wght" : (0.977777777778, 1.0), "wdth" : (-1.0, -0.5)}], {"uniFB43" : "uniFB43.rvrn"}), 
	([{"wght" : (0.977777777778, 1.0), "wdth" : (-1.0, -0.5)}], {"uniFB44" : "uniFB44.rvrn"}), 
	([{"wght" : (0.977777777778, 1.0), "wdth" : (-1.0, -0.5)}], {"uniFB47" : "uniFB47.rvrn"}), 
	([{"wght" : (0.977777777778, 1.0)}], {"uniFB2C" : "uniFB2C.rvrn"}), 
	([{"wght" : (0.977777777778, 1.0)}], {"uniFB2D" : "uniFB2D.rvrn"}), 
	([{"wght" : (0.977777777778, 1.0)}], {"uniFB49" : "uniFB49.rvrn"}), 
	([{"wght" : (0.977777777778, 1.0), "wdth" : (-1.0, -0.5)}], {"uniFB4A" : "uniFB4A.rvrn"}), 
	([{"wght" : (0.977777777778, 1.0)}], {"dollar" : "dollar.rvrn"}), 
	([{"wght" : (0.977777777778, 1.0), "wdth" : (-0.5, 1.0)}], {"uni047C" : "uni047C.rvrn"}), 
] 

addFeatureVariations(f, condSubst)

f.save(fontPath)