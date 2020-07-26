#!/usr/bin/env python

import sys, ntpath
from PIL import Image, ImageEnhance

fic_l = open(sys.argv[1],'rt')
liste=fic_l.readlines()
fic_l.close()
nbim = 0
nbimnr = 0
for fic in liste:
 nbim += 1
 fic = fic[:-1]
 try:
  im = Image.open(fic)
 except:
  nbimnr +=1
  print ("Traitement de " + ntpath.basename(fic) + "-> ignoré (format non reconnu)")
  continue
 print ("Traitement de " + ntpath.basename(fic))
 if im._getexif()!=None:
  o = im._getexif().get(274)
 else:
  o = 0
 if o in (1,2):
  im_rotated = im
 elif o in (3, 4):
  im_rotated = im.transpose(Image.ROTATE_180)
 elif o in (5, 6):
  im_rotated = im.transpose(Image.ROTATE_270)
 elif o in (7, 8):
  im_rotated = im.transpose(Image.ROTATE_90)
 else:
  im_rotated = im
 w = im_rotated.width
 h = im_rotated.height
 if w>=h:
  h = round(150 / w * h)
  w = 150
 else:
  w = round(150 / h * w)
  h = 150
 im_resized=im_rotated.resize((w,h),Image.LANCZOS)
 im_final = ImageEnhance.Sharpness(im_resized).enhance(1.2)
 im_final.save(sys.argv[2] + " - " + ntpath.splitext(ntpath.basename(fic))[0] + ".jpg","JPEG",quality=85)
 im.close()
if nbimnr == 0:
 print (str(nbim) + " image(s) traitée(s)")
 exit(0)
else:
 print (str(nbim) + " image(s) traitée(s) dont")
 print ("  " + str(nbimnr) + " image(s) non reconnue(s)")
 exit(1)