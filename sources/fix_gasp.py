"""Add gasp table which has same gasp ranges as previous static fonts"""
from fontTools.ttLib import TTFont, newTable
import sys

font = TTFont(sys.argv[1])

gasp = newTable("gasp")
gasp.gaspRange = {8: 10, 13: 7, 65535: 15}
font['gasp'] = gasp
font.save(font.reader.file.name)