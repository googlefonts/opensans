# Script to build feature variation fonts using fontmake
## This script converts the input .glyphs file into a form with bracket layers converted to suffixed glyphs so that fontmake can generate the VF
## It uses the parsed bracket values to then generate a script to run on the final ttf using fonttools to enable the GSUB feature

# TODO
## Use unicode values as per fonttools
## Number the suffixes when a glyph has more than one substitution

import sys
import os
import re
import copy
import time
from glyphsLib import GSFont
from glyphsLib import GSGlyph
from glyphsLib import GSLayer
from glyphsLib.glyphdata import get_glyph

start = time.time()

filename = sys.argv[-1]
font = GSFont(filename)

needsDup = []
logged = {}
noComponents = {}

suffix = ".rvrn"

fontAxes = {}
weightMap = []
weightMapDict = {}

doNotSave = False

weightAxis = None

weightDict = {
            "Thin" : 100,
            "ExtraLight" : 200,
            "UltraLight" : 200,
            "Light" : 300,
            "Normal" : 400,
            "Regular" : 400,
            "Medium" : 500,
            "DemiBold" : 600,
            "SemiBold" : 600,
            "Bold" : 700,
            "UltraBold" : 800,
            "ExtraBold" : 800,
            "Black" : 900,
            "Heavy" : 900,
            }

def getVfOrigin():
    if font.customParameters["Variation Font Origin"] != None:
        VfOrigin = font.customParameters["Variation Font Origin"]
    else:
        VfOrigin = font.masters[0].id
    
    print "Variable Font Origin is:", font.masters[VfOrigin].name, "\n"
    return VfOrigin

def getAxes():
    try:
        axisNum = 1
        for axis in font.customParameters["Axes"]:
            fontAxes.update({'axis%s' % str(axisNum) : {'min': 100000, 'max': -1000000, 'tag': axis['Tag']}})
            if axis['Tag'] == 'wght':
                weightAxis = 'axis%s' % str(axisNum)
            axisNum = axisNum + 1
    except:
        print "Could't detect axes. Font lacks custom parameter \'Axes\'\n"
        doNotSave = True


def getMasterRanges():
    for axisIndex in range(len(fontAxes)):
        thisAxis = fontAxes['axis%s' % str(axisIndex + 1)]
        for master in font.masters:
            if axisIndex == 0:
                axisValue = master.weightValue
            elif axisIndex == 1:
                axisValue = master.widthValue
            elif axisIndex == 2:
                axisValue = master.customValue
            elif axisIndex == 3:
                axisValue = master.customValue1
            elif axisIndex == 4:
                axisValue = master.customValue2
            elif axisIndex == 5:
                axisValue = master.customValue3

            if master.id == VfOrigin:
                thisAxis.update({'def': axisValue})

            if axisValue > fontAxes['axis%s' % str(axisIndex + 1)]['max']:
                thisAxis.update({'max': axisValue})
            if axisValue < fontAxes['axis%s' % str(axisIndex + 1)]['min']:
                thisAxis.update({'min': axisValue})

        prevInstance = None
        prevValue = None
        prevScaledVal = None
        for instance in font.instances:
            if instance.active == True:
                if axisIndex == 0:
                    axisValue = instance.weightValue
                elif axisIndex == 1:
                    axisValue = instance.widthValue
                elif axisIndex == 2:
                    axisValue = instance.customValue
                elif axisIndex == 3:
                    axisValue = instance.customValue1
                elif axisIndex == 4:
                    axisValue = instance.customValue2
                elif axisIndex == 5:
                    axisValue = instance.customValue3

                if fontAxes['axis%s' % str(axisIndex + 1)]['tag'] == 'wght':
                    if instance.customParameters["weightClass"] != None:
                        scaledValue = instance.customParameters["weightClass"]
                    else:
                        scaledValue = weightDict[instance.weight]
                    weightMap.append([axisValue, scaledValue])
                    weightMapDict.update({axisValue : scaledValue})
                else:
                    scaledValue = axisValue

                if axisValue == fontAxes['axis%s' % str(axisIndex + 1)]['min']:
                    fontAxes['axis%s' % str(axisIndex + 1)].update({'sMin': scaledValue})
                elif axisValue == fontAxes['axis%s' % str(axisIndex + 1)]['max']:
                    fontAxes['axis%s' % str(axisIndex + 1)].update({'sMax': scaledValue})
                if axisValue == fontAxes['axis%s' % str(axisIndex + 1)]['def']:
                    fontAxes['axis%s' % str(axisIndex + 1)].update({'mDef': scaledValue})

                # If no default can be mapped, then calculate mapping based on surrounding values
                if fontAxes['axis%s' % str(axisIndex + 1)].get('mDef') == None and axisValue > fontAxes['axis%s' % str(axisIndex + 1)]['def'] and prevValue < fontAxes['axis%s' % str(axisIndex + 1)]['def']:
                    defVal = fontAxes['axis%s' % str(axisIndex + 1)]['def']

                    mappedDefault = ((defVal - prevValue) / (axisValue - prevValue)) * (scaledValue - prevScaledVal) + prevScaledVal

                    fontAxes['axis%s' % str(axisIndex + 1)].update({'mDef': mappedDefault})

                # Store previous instance and axis value
                prevInstance = instance
                prevValue = axisValue
                prevScaledVal = scaledValue

        axisDef = fontAxes['axis%s' % str(axisIndex + 1)]['def']
        axisMin = fontAxes['axis%s' % str(axisIndex + 1)]['min']
        axisMax = fontAxes['axis%s' % str(axisIndex + 1)]['max']
        sMax = fontAxes['axis%s' % str(axisIndex + 1)]['sMax']
        sMin = fontAxes['axis%s' % str(axisIndex + 1)]['sMin']
        percent = (axisDef - axisMin) / (axisMax - axisMin)
        sDef = ((sMax - sMin) * percent) + sMin
        fontAxes['axis%s' % str(axisIndex + 1)].update({'sDef': sDef})


    if axisIndex + 1 > 1:
        print "Detected %s Axes" % (axisIndex + 1)
        print "Parsed Axes values:"
    else:
        print "Detected %s Axis" % (axisIndex + 1)
        print "Parsed Axis values:"
    for axis in fontAxes.keys():
        print fontAxes[axis]['tag'], "   Minimum:", fontAxes[axis]['min'], "   Default:", fontAxes[axis]['def'], "   Max:", fontAxes[axis]['max']
    print "\n"


def getBracketGlyphs():
    # No glyphs are marked for duplication yet
    newAddition = False
    # Go through all glyphs in font
    for glyph in font.glyphs:
        # If the glyphs has NOT been marked for duplication check layers
        if logged.get(glyph.name) == None and noComponents.get(glyph.name) == None:
            # Iterate through all layers
            for layer in glyph.layers:
                # If glyph has been marked for duplication break the loop **might be redundant** else proceed
                if logged.get(glyph.name) != None:
                    break
                else:
                    # If active bracket layer mark for duplication and move to next glyph
                    if re.match('.*\d\]$', layer.name) != None:
                        needsDup.append(glyph.name)
                        logged.update({glyph.name: True})
                        newAddition = True
                        break
                    else:
                        if len(layer.components) == 0:
                            noComponents.update({glyph.name : True})
                        else:
                            # Check components
                            for component in layer.components:
                                # If component is not logged proceed
                                if logged.get(component.name) == None:
                                    pass
                                # If component references a glyph marked for duplication then mark this glyph as well
                                else:
                                    needsDup.append(glyph.name)
                                    logged.update({glyph.name: True})
                                    newAddition = True
                                    break
        # Skip glyph if it has already been marked for duplication
        else:
            pass
    # If a new glyph was marked check all glyphs and components again
    if newAddition == True:
        getBracketGlyphs()
    else:
        # When finished print glyphs duplicated
        print "Duplicated %s glyphs for GSUB rvrn feature:" % str(len(needsDup))
        print re.sub( '[\[\]]', '', re.sub('[\[|, ]u\'', '\'', str(needsDup))) 

# WIP needs to reference post avar mapped values
def normalizeValues(location):
    for value in range(len(location) - 2):
        if location[value] > fontAxes['axis' + str(value + 1)]['max'] or location[value] < fontAxes['axis' + str(value + 1)]['min']:
            location[value] = None
        if location[value] != None:
            axisValue = location[value]
            sMax = fontAxes['axis' + str(value + 1)]['sMax']
            sMin = fontAxes['axis' + str(value + 1)]['sMin']
            mDef = fontAxes['axis' + str(value + 1)]['mDef']
            sDef = fontAxes['axis' + str(value + 1)]['sDef']

            if fontAxes['axis' + str(value + 1)]['tag'] == 'wght':
                if weightMapDict.get(axisValue) != None:
                    mappedValue = weightMapDict[axisValue]
                else:
                    for mapIndex in range(len(weightMap)):
                        if axisValue > weightMap[mapIndex][0]:
                            pass
                        else:
                            thisMap = weightMap[mapIndex]
                            prevMap = weightMap[mapIndex - 1]
                            mappedValue = ((axisValue - prevMap[0]) / (thisMap[0] - prevMap[0])) * (thisMap[1] - prevMap[1]) + prevMap[1]
                            break
            else:
                mappedValue = axisValue

            if mappedValue <= mDef and sMin != sDef:
                normValue = ((mappedValue - sMin) / (mDef - sMin)) - 1
            elif mappedValue >= mDef:
                normValue = (mappedValue - mDef) / (sMax - mDef)
            else:
                print "ERROR Normalizing value %s on %s axis" % (axisValue, fontAxes['axis' + str(value + 1)]['tag'])

            location[value] = normValue



            #### ((axisValue - prevValue) / (axisValue - prevValue)) * (scaledValue - prevScaledVal) + prevScaledVal

def duplicateGlyph(glyphName):
    # Duplicated glyph
    dupGlyph = GSGlyph(copy.copy(font.glyphs[glyphName]))
    # Add suffix
    dupGlyph.name = glyphName + suffix

    # Add layers to duplicate glyph (now a true duplicate)
    for layer in font.glyphs[glyphName].layers:
        dupGlyph.layers.append(copy.copy(layer))

    # Remove any unicode value since these are suffixed glyphs
    dupGlyph.unicode = None

    # Add dupglyph to font
    font.glyphs.append(dupGlyph)
    return dupGlyph


# Gets number of axes and stores in a dictionary
getAxes()

# Set origin master to determine which layers to use in the duplicate glyph
VfOrigin = getVfOrigin()

# Checks all masters and updates fontAxes dictionary min/max values
# TODO add funtion to check virtual master ranges
getMasterRanges() 

# Recursively goes through all glyphs and determines if they will need a duplicate glyph
getBracketGlyphs()
  

locations = {}  

substitution = "import os\nimport sys\nimport fontTools\nfrom fontTools.ttLib import TTFont\nfrom fontTools.varLib.featureVars import addFeatureVariations\n\nfontPath = sys.argv[-1]\n\nf = TTFont(fontPath)\n\ncondSubst = [\n"
firstGlyph = True
# Iterate through glyphs marked for duplication
for i in range(len(needsDup)):
    # Duplicated glyph
    dupGlyph = duplicateGlyph(needsDup[i])


    delLayer = []
    glyphLocations = []
    copiedLocations = False
    bracketDefault = False

    # Determine which type of layer becomes master layer in original glyph and which one becomes master layer for the duplicate glyph
    for layer in font.glyphs[dupGlyph.name].layers:
        if layer.associatedMasterId == VfOrigin:
            if re.match(".*\[.*\d\]$", layer.name) != None:
                bracketDefulat = False
                break
            elif layer.associatedMasterId == VfOrigin and re.match(".*\].*\d\]$", layer.name) != None:
                bracketDefault = True
                break

    for layer in font.glyphs[dupGlyph.name].layers:      
        if re.match(".*\[.*\d\]$", layer.name) != None:
            location = map(float, re.sub('(^[^][]*(\[|\]))|\]| ', '', layer.name).split(","))
            location.append(layer.associatedMasterId)

            if bracketDefault == False:
                location.append(False)
                dupGlyph.layers[layer.associatedMasterId].paths = layer.paths
                dupGlyph.layers[layer.associatedMasterId].components = layer.components
                dupGlyph.layers[layer.associatedMasterId].anchors = layer.anchors
                dupGlyph.layers[layer.associatedMasterId].width = layer.width
            else:
                location.append(True)
                font.glyphs[needsDup[i]].layers[layer.associatedMasterId].paths = layer.paths
                font.glyphs[needsDup[i]].layers[layer.associatedMasterId].components = layer.components
                font.glyphs[needsDup[i]].layers[layer.associatedMasterId].anchors = layer.anchors
                font.glyphs[needsDup[i]].layers[layer.associatedMasterId].width = layer.width

            normalizeValues(location)
            glyphLocations.append(location)

            # Mark layer for deletion
            delLayer.append(layer.layerId)
        elif re.match(".*\].*\d\]$", layer.name) != None:
            location = map(float, re.sub('(^[^][]*(\[|\]))|\]| ', '', layer.name).split(","))
            location.append(layer.associatedMasterId)

            if bracketDefault == False:
                location.append(False)
                font.glyphs[needsDup[i]].layers[layer.associatedMasterId].paths = layer.paths
                font.glyphs[needsDup[i]].layers[layer.associatedMasterId].components = layer.components
                font.glyphs[needsDup[i]].layers[layer.associatedMasterId].anchors = layer.anchors
                font.glyphs[needsDup[i]].layers[layer.associatedMasterId].width = layer.width
            else:
                location.append(True)
                dupGlyph.layers[layer.associatedMasterId].paths = layer.paths
                dupGlyph.layers[layer.associatedMasterId].components = layer.components
                dupGlyph.layers[layer.associatedMasterId].anchors = layer.anchors
                dupGlyph.layers[layer.associatedMasterId].width = layer.width

            normalizeValues(location)
            glyphLocations.append(location)

            # Mark layer for deletion
            delLayer.append(layer.layerId)
        else:
            for component in layer.components:
                if logged.get(component.name) == None:
                    pass
                else:
                    locations.update({needsDup[i] : locations[component.name]})
                    glyphLocations = locations[component.name]
                    copiedLocations = True
                    for location in locations[component.name]:
                        if layer.layerId == location[-2]:
                            bracketDefault = location[-1]

# Move this to function?

    checkValues = []
    for location in glyphLocations:
        for value in range(len(location) - 2):
            try:
                checkValues[value].update({location[value] : value + 1})
            except:
                checkValues.append({location[value] : value + 1})


    # Verify that the glyph only has one substitution
    # Glyphs App does not appear to support more though this script could serve as a workaround for that. Might add in the future
    glyphString = ""
    firstRegion = True
    for value in checkValues:
        if len(value) > 1:
            print "ERROR: More than 1 substitution detected for glyph \'%s\'" % needsDup[i]
            doNotSave = True
        else:
            axis = fontAxes["axis" + str(value.values()[0])]['tag']

            # if value.keys()[0] != None and bracketDefault == False:
            #     print axis, value.keys()[0], fontAxes["axis" + str(value.values()[0])]['nMax'], glyphSub
            # elif value.keys()[0] != None and bracketDefault == True:
            #     print axis, fontAxes["axis" + str(value.values()[0])]['nMin'], value.keys()[0], glyphSub
            if value.keys()[0] != None and bracketDefault == False:
                if firstRegion == False:
                    glyphString = glyphString + ", "
                glyphString = glyphString + "{\"" + axis + "\" : (" + str(value.keys()[0]) + ", " +  str(1.0) + ")}"
                firstRegion = False
            elif value.keys()[0] != None and bracketDefault == True:
                if firstRegion == False:
                    glyphString = glyphString + ", "
                glyphString = glyphString + "{\"" + axis + "\" : (" + str(-1.0) + ", " + str(value.keys()[0]) + ")}"
                firstRegion = False
    glyphSub = "{\"" + get_glyph(needsDup[i])[1] + "\"" + " : " + "\"" + get_glyph(needsDup[i])[1] + suffix + "\"}"
    print "([" + glyphString + "], " + glyphSub + ")"
    if firstGlyph == True:
        glyphString = "\t([" + glyphString + "], " + glyphSub + "),"
    else:
        glyphString = " \n\t([" + glyphString + "], " + glyphSub + "),"
    substitution = substitution + glyphString
    firstGlyph = False

# Move this to function?

    # Delete bracket layers now that they have been made master layers
    for layerId in delLayer:
        del font.glyphs[dupGlyph.name].layers[layerId]
        origGlyph = re.sub(suffix, "", dupGlyph.name)
        del font.glyphs[origGlyph].layers[layerId]

    # If glyph does not get locations from referenced component then add the parsed locations
    if copiedLocations == False:
        locations.update({needsDup[i] : glyphLocations})

    
if doNotSave == True:
    pass
else: 
    mid = time.time()
    font.save(filename)
    print "File Saved\n"

    substitution = substitution + " \n] \n\naddFeatureVariations(f, condSubst)\n\nf.save(fontPath)"
    
    file = open("addFeatureVars.py", "w") 
    file.write(substitution) 
    file.close()

    end = time.time()

    print "\n\n\n"
    print "Total Time: %s seconds + %s seconds to save" % (str(mid - start), str(end - mid))

