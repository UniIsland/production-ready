#!/usr/bin/python
# -*- coding: utf-8 -*-

import os.path
import sys
from pyPdf import PdfFileWriter, PdfFileReader

argV = sys.argv

if (len(argV) < 4):
	print "Usage: pypdf_merge infile1 infile2 [...] outfile"
	sys.exit()

inputFiles = argV[1:-1]
outputFile = argV[-1]
pdfOutput = PdfFileWriter()

if os.path.exists(outputFile):
	print outputFile+" already exists... aborting."
	sys.exit(1)

for i in inputFiles:
	pdf = PdfFileReader(file(i, "rb"))
	if pdf.getIsEncrypted():
		pdf.decrypt('')
	print i + ": " + str(pdf.getNumPages()) + " pages"
	for pageNum in range(pdf.getNumPages()):
		pdfOutput.addPage(pdf.getPage(pageNum))

try:
	outputStream = file(outputFile, "wb")
	pdfOutput.write(outputStream)
	outputStream.close()
except:
	print "error: writing ouput file."
	sys.exit(3)


