import ctypes, ctypes.wintypes
import struct
import sys
import msvcrt
import os, os.path
import locale
import io
import zipfile

kernel32 = ctypes.WinDLL('kernel32', use_last_error=True)
shl = ctypes.WinDLL('Shlwapi',  use_last_error=True)
wic = ctypes.WinDLL('windowscodecs',  use_last_error=True)
guid = struct.pack('@LHH8B', *struct.unpack('>LHH8B', int('19E4A5AA-5662-4FC5-A0C0-1758028E1057'.replace('-', ''), 16).to_bytes(16, 'big')))
class VARIANT_U(ctypes.Union):
    _fields_ = [('fltVal', ctypes.wintypes.FLOAT), ('uiVal', ctypes.wintypes.USHORT), ('pad', ctypes.c_char * 16)]
class VARIANT(ctypes.Structure):
  _anonymous_ = ("vn",)
  _fields_ = [('vt', ctypes.c_ushort), ('wReserved1', ctypes.wintypes.WORD), ('wReserved2', ctypes.wintypes.WORD), ('wReserved3', ctypes.wintypes.WORD), ('vn', VARIANT_U)]
class PROPBAG2(ctypes.Structure):
  _fields_ = [('dwType', ctypes.wintypes.DWORD), ('vt', ctypes.c_ushort), ('cfType', ctypes.wintypes.DWORD), ('dwHint', ctypes.wintypes.DWORD), ('pstrName', ctypes.wintypes.LPOLESTR), ('clsid', ctypes.c_char * 16)]
class CAUH(ctypes.Structure):
  _fields_ = [('vc', ctypes.wintypes.DWORD), ('_vp', ctypes.POINTER(ctypes.wintypes.ULARGE_INTEGER))]
  @property
  def vp(self):
    return ctypes.cast(self._vp, ctypes.POINTER(ctypes.wintypes.ULARGE_INTEGER * self.vc)).contents if self._vp else None
class PROPVARIANT_U(ctypes.Union):
  _fields_ = [('fltVal', ctypes.wintypes.FLOAT), ('uiVal', ctypes.wintypes.USHORT), ('cauh', CAUH), ('pszVal', ctypes.wintypes.LPSTR)]
class PROPVARIANT(ctypes.Structure):
  _anonymous_ = ("vn",)
  _fields_ = [('vt', ctypes.c_ushort), ('wReserved1', ctypes.wintypes.WORD), ('wReserved2', ctypes.wintypes.WORD), ('wReserved3', ctypes.wintypes.WORD), ('vn', PROPVARIANT_U)]

locale.setlocale(locale.LC_COLLATE, '')
VT100 = False
m = ctypes.wintypes.DWORD()
h = ctypes.wintypes.HANDLE(msvcrt.get_osfhandle(sys.stdout.fileno()))
if kernel32.GetConsoleMode(h, ctypes.byref(m)):
  if kernel32.SetConsoleMode(h, ctypes.wintypes.DWORD(m.value | 5)):
    VT100 = True

is_kml = len(sys.argv) < 4 or sys.argv[3] != 'z'
dir_scan = sys.argv[1]
dir_dest = sys.argv[2]
name = os.path.splitext(os.path.basename(dir_scan[:-1]))[0]
path_kml = (dir_dest + name + ' - andro.kml') if is_kml else (name + ' - andro - kmz.kml')
path_kmz = '' if is_kml else dir_dest + name + ' - andro.kmz'
dir_thumbs = dir_dest + 'thumbs\\'
print('Scan de "%s" pour création de "%s" et des miniatures dans "%s"' % (dir_scan, (path_kml if is_kml else path_kmz), dir_thumbs))
lst = sorted((f.path for f in os.scandir(dir_scan) if f.is_file() for e in (os.path.splitext(f.name)[1].lower(),) if (e[1:3] == 'jp' and e[-1] == 'g')), key=locale.strxfrm)
pref_thumbs = dir_thumbs + name + ' - '
base_thumbs = ('http://localhost:8080/Android/data/com.google.earth/files/thumbs/%s - ' % name) if is_kml else ('thumbs/%s - ' % name)

pFactory = ctypes.c_void_p()
if wic.WICCreateImagingFactory_Proxy(ctypes.wintypes.UINT(0x237), ctypes.byref(pFactory)):
  exit(1)
if not is_kml:
  k = zipfile.ZipFile(path_kmz, 'w', compression=zipfile.ZIP_DEFLATED)
kml = io.StringIO()
kml.write('<?xml version="1.0" encoding="UTF-8"?>\r\n')
kml.write('<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">\r\n')
kml.write('<Folder>\r\n')
kml.write('<name>%s</name>\r\n' % name)
kml.write('<description><![CDATA[Images du répertoire Carte SD/Picture/%s]]></description>\r\n' % name)
kml.write('<Style id="placemark">\r\n')
kml.write('<IconStyle>\r\n')
kml.write('<scale>2.2</scale>\r\n')
kml.write('</IconStyle>\r\n')
kml.write('<LabelStyle>\r\n')
kml.write('<scale>0.7</scale>\r\n')
kml.write('</LabelStyle>\r\n')
kml.write('<BalloonStyle>\r\n')
kml.write('<bgColor>ff000000</bgColor>\r\n')
kml.write('<textColor>ffaaaaaa</textColor>\r\n')
kml.write('<text>\r\n')
kml.write('<![CDATA[\r\n')
kml.write('<div style="float:left;width:50%%;height:1.2em;overflow:auto hidden;white-space:nowrap;color:white;"><b>%s</b></div>\r\n' % name)
kml.write('<div style="float:right;padding-top:0.2em;font-size:0.8em;color:#aaaaaa;">$[date]</div><br/><hr/>\r\n')
kml.write('<b><font color=#aaaaaa>Lat: </b><code>$[lat]</code>&nbsp;&nbsp;&nbsp;<b>Lon: </b><code>$[lon]</code><br/><br/>\r\n')
kml.write('<div style="width:94vw;height:62vh;"><a href="http://localhost:8080//Android/data/com.google.earth/files/viewer - andro.htm#$[url]"><img src="$[url]" style="max-width:94vw;max-height:62vh;"/></a></div><br/>\r\n')
kml.write('<b>Nom: </b><a href="$[url]">$[name]</a></font><hr/>]]>\r\n')
kml.write('</text>\r\n')
kml.write('</BalloonStyle>\r\n')
kml.write('</Style>\r\n')
nproc = 0
nskip = 0
nnodt = 0
for p in lst:
  nproc += 1
  name_p = os.path.splitext(os.path.basename(p))[0]
  path_t = pref_thumbs + name_p + '.jpg'
  exist_t = os.path.exists(path_t)
  pstm1 = ctypes.c_void_p()
  pIDecoder = ctypes.c_void_p()
  pIBitmapFrame = ctypes.c_void_p()
  pIMetadataQueryReader = ctypes.c_void_p()
  nogps = False
  try:
    if shl.SHCreateStreamOnFileEx(ctypes.wintypes.LPCWSTR(p), ctypes.wintypes.DWORD(0x00000030), ctypes.wintypes.DWORD(0x00000000), False, None, ctypes.byref(pstm1)):
      raise
    if wic.IWICImagingFactory_CreateDecoderFromStream_Proxy(pFactory, pstm1, ctypes.c_void_p(), ctypes.wintypes.DWORD(0), ctypes.byref(pIDecoder)):
      raise
    if wic.IWICBitmapDecoder_GetFrame_Proxy(pIDecoder, 0, ctypes.byref(pIBitmapFrame)):
      raise
    if wic.IWICBitmapFrameDecode_GetMetadataQueryReader_Proxy(pIBitmapFrame, ctypes.byref(pIMetadataQueryReader)):
      raise
    gps = [None, None]
    for l in range(2):
      varValue = PROPVARIANT()
      if not wic.IWICMetadataQueryReader_GetMetadataByName_Proxy(pIMetadataQueryReader, ctypes.wintypes.LPCWSTR('/app1/ifd/{ushort=34853}/{ushort=%d}' % ((l+1) << 1)), ctypes.byref(varValue)):
        if varValue.vt == 4117 and varValue.cauh.vc == 3:
          gps[l] = sum((v & 0xffffffff) / (v >> 32) / (60 ** i)  for i, v in enumerate(varValue.cauh.vp))
      if gps[l] is None:
        break
      varValue = PROPVARIANT()
      if not wic.IWICMetadataQueryReader_GetMetadataByName_Proxy(pIMetadataQueryReader, ctypes.wintypes.LPCWSTR('/app1/ifd/{ushort=34853}/{ushort=%d}' % ((l << 1) + 1)), ctypes.byref(varValue)):
        if varValue.vt == 30 and varValue.pszVal.upper() == (b'S' if l == 0 else b'W'):
          gps[l] = -gps[l]
      gps[l] = '%+.6f' % gps[l]
    if None in gps:
      nogps = True
      print('%sTraitement de "%s" -> ignoré (pas de données de géolocalisation)%s' % (('\033[31m' if VT100 else ''), os.path.basename(p), ('\033[0m' if VT100 else '')))
      raise
    if not exist_t:
      r = 0
      varValue = PROPVARIANT()
      if not wic.IWICMetadataQueryReader_GetMetadataByName_Proxy(pIMetadataQueryReader, ctypes.wintypes.LPCWSTR('/app1/ifd/exif:{ushort=274}'), ctypes.byref(varValue)):
        if varValue.vt == 18:
          r = varValue.uiVal
          if r < 2 or r > 8:
            r = 0
      pIColorContexts = None
      cActualCount = ctypes.wintypes.UINT()
      if not wic.IWICBitmapFrameDecode_GetColorContexts_Proxy(pIBitmapFrame, ctypes.wintypes.UINT(0), None, ctypes.byref(cActualCount)):
        if cActualCount.value:
          pIColorContexts = (ctypes.c_void_p * cActualCount.value)()
          for c in range(cActualCount.value):
            pIColorContext = ctypes.c_void_p()
            wic.WICCreateColorContext_Proxy(pFactory, ctypes.byref(pIColorContext))
            pIColorContexts[c] = pIColorContext
          if wic.IWICBitmapFrameDecode_GetColorContexts_Proxy(pIBitmapFrame, cActualCount.value, ctypes.byref(pIColorContexts), ctypes.byref(cActualCount)):
            for c in range(len(pIColorContexts)):
              ctypes.WINFUNCTYPE(ctypes.c_ulong)(2, 'Release')(ctypes.c_void_p(pIColorContexts[c]))
            pIColorContexts = None
      pIBitmap1 = ctypes.c_void_p()
      pIBitmapScaler = ctypes.c_void_p()
      pIBitmap2 = ctypes.c_void_p()
      pIBitmapFlipRotator = ctypes.c_void_p()
      pIEncoder =  ctypes.c_void_p()
      pIFrameEncode =  ctypes.c_void_p()
      pIEncoderOptions = ctypes.c_void_p()
      pstm2 = ctypes.c_void_p()
      try:
        if wic.IWICImagingFactory_CreateBitmapFromSource_Proxy(pFactory, pIBitmapFrame, ctypes.wintypes.DWORD(1), ctypes.byref(pIBitmap1)):
          raise
        uiWidth = ctypes.wintypes.UINT()
        uiHeight = ctypes.wintypes.UINT()
        if wic.IWICBitmapSource_GetSize_Proxy(pIBitmapFrame, ctypes.byref(uiWidth),  ctypes.byref(uiHeight)):
          raise
        if wic.IWICImagingFactory_CreateBitmapScaler_Proxy(pFactory, ctypes.byref(pIBitmapScaler)):
          raise
        w, h = (601, round(601 / uiWidth.value * uiHeight.value)) if uiWidth.value >= uiHeight.value else (round(601 / uiHeight.value * uiWidth.value), 601)
        if wic.IWICBitmapScaler_Initialize_Proxy(pIBitmapScaler, pIBitmap1, ctypes.wintypes.UINT(w), ctypes.wintypes.UINT(h), ctypes.wintypes.UINT(3)):
          raise
        pIBitmapTransformed = pIBitmapScaler
        if r != 0:
          if not wic.IWICImagingFactory_CreateBitmapFromSource_Proxy(pFactory, pIBitmapScaler, ctypes.wintypes.DWORD(1), ctypes.byref(pIBitmap2)):
            if not wic.IWICImagingFactory_CreateBitmapFlipRotator_Proxy(pFactory, ctypes.byref(pIBitmapFlipRotator)):
              if not wic.IWICBitmapFlipRotator_Initialize_Proxy(pIBitmapFlipRotator, pIBitmap2, ctypes.wintypes.DWORD({2: 8, 3: 2, 4: 16, 5: 11, 6: 1, 7: 9, 8: 3}.get(r, 0))):
                pIBitmapTransformed = pIBitmapFlipRotator
        if shl.SHCreateStreamOnFileEx(ctypes.wintypes.LPCWSTR(path_t), ctypes.wintypes.DWORD(0x00001021), None, True, None, ctypes.byref(pstm2)):
          raise
        if wic.IWICImagingFactory_CreateEncoder_Proxy(pFactory, ctypes.c_char_p(guid), ctypes.c_void_p(), ctypes.byref(pIEncoder)):
          raise
        if wic.IWICBitmapEncoder_Initialize_Proxy(pIEncoder, pstm2, ctypes.wintypes.DWORD(2)):
          raise
        if wic.IWICBitmapEncoder_CreateNewFrame_Proxy(pIEncoder, ctypes.byref(pIFrameEncode), ctypes.byref(pIEncoderOptions)):
          raise
        propBag = PROPBAG2()
        propBag.dwType = 0
        propBag.vt = 4
        propBag.pstrName = ctypes.wintypes.LPOLESTR('ImageQuality')
        varValue = VARIANT()
        varValue.vt = 4
        varValue.fltVal = ctypes.c_float(0.85)
        if wic.IPropertyBag2_Write_Proxy(pIEncoderOptions, 1, ctypes.byref(propBag),ctypes.byref(varValue)):
          raise
        if wic.IWICBitmapFrameEncode_Initialize_Proxy(pIFrameEncode, pIEncoderOptions):
          raise
        if pIColorContexts is not None:
          wic.IWICBitmapFrameEncode_SetColorContexts_Proxy(pIFrameEncode, cActualCount, ctypes.byref(pIColorContexts))
        if wic.IWICBitmapFrameEncode_WriteSource_Proxy(pIFrameEncode, pIBitmapTransformed, None):
          raise
        if wic.IWICBitmapFrameEncode_Commit_Proxy(pIFrameEncode):
          raise
        if wic.IWICBitmapEncoder_Commit_Proxy(pIEncoder):
          raise
      finally:
        if pIColorContexts is not None:
          for c in range(len(pIColorContexts)):
            ctypes.WINFUNCTYPE(ctypes.c_ulong)(2, 'Release')(ctypes.c_void_p(pIColorContexts[c]))
        if pIFrameEncode:
          ctypes.WINFUNCTYPE(ctypes.c_ulong)(2, 'Release')(pIFrameEncode)
        if pIEncoderOptions:
          ctypes.WINFUNCTYPE(ctypes.c_ulong)(2, 'Release')(pIEncoderOptions)
        if pIEncoder:
          ctypes.WINFUNCTYPE(ctypes.c_ulong)(2, 'Release')(pIEncoder)
        if pIBitmapFlipRotator:
          ctypes.WINFUNCTYPE(ctypes.c_ulong)(2, 'Release')(pIBitmapFlipRotator)
        if pIBitmap2:
          ctypes.WINFUNCTYPE(ctypes.c_ulong)(2, 'Release')(pIBitmap2)
        if pIBitmapScaler:
          ctypes.WINFUNCTYPE(ctypes.c_ulong)(2, 'Release')(pIBitmapScaler)
        if pIBitmap1:
          ctypes.WINFUNCTYPE(ctypes.c_ulong)(2, 'Release')(pIBitmap1)
        if pstm2:
          ctypes.WINFUNCTYPE(ctypes.c_ulong)(2, 'Release')(pstm2)
    dt = '-'
    varValue = PROPVARIANT()
    if not wic.IWICMetadataQueryReader_GetMetadataByName_Proxy(pIMetadataQueryReader, ctypes.wintypes.LPCWSTR('/app1/ifd/{ushort=34665}/{ushort=36868}'), ctypes.byref(varValue)):
      if varValue.vt == 30:
        d = varValue.pszVal.decode('utf-8').split(' ')
        if len(d) == 2:
          d[0] = '/'.join(d[0].split(':')[::-1])
          dt = ' '.join(d)
    if dt == '-':
      nnodt += 1
      print('%sTraitement %sde "%s" -> intégré sans données de date de création%s' % (('\033[33m' if VT100 else ''), ('' if exist_t else 'et création de miniature '), os.path.basename(p), ('\033[0m' if VT100 else '')))
    else:
      print('%sTraitement %sde "%s"%s' % (('\033[32m' if VT100 else ''), ('' if exist_t else 'et création de miniature '), os.path.basename(p), ('\033[0m' if VT100 else '')))
  except:
    nskip += 1
    if not nogps:
      print('%sTraitement de "%s" -> ignoré (format non reconnu)%s' % (('\033[31m' if VT100 else ''), os.path.basename(p), ('\033[0m' if VT100 else '')))
    continue
  finally:
    if pIMetadataQueryReader:
      ctypes.WINFUNCTYPE(ctypes.c_ulong)(2, 'Release')(pIMetadataQueryReader)
    if pIBitmapFrame:
      ctypes.WINFUNCTYPE(ctypes.c_ulong)(2, 'Release')(pIBitmapFrame)
    if pIDecoder:
      ctypes.WINFUNCTYPE(ctypes.c_ulong)(2, 'Release')(pIDecoder)
    if pstm1:
      ctypes.WINFUNCTYPE(ctypes.c_ulong)(2, 'Release')(pstm1)
  kml.write('<Placemark>\r\n')
  kml.write('<name>%s</name>\r\n' % name_p)
  kml.write('<ExtendedData>\r\n')
  kml.write('<Data name="date"><value>%s</value></Data>\r\n' % dt)
  kml.write('<Data name="lat"><value>%s</value></Data>\r\n' % gps[0])
  kml.write('<Data name="lon"><value>%s</value></Data>\r\n' % gps[1])
  kml.write('<Data name="url"><value>http://localhost:8080/Picture/%s/%s</value></Data>\r\n' % (name, os.path.basename(p)))
  kml.write('</ExtendedData>\r\n')
  kml.write('<styleUrl>#placemark</styleUrl>\r\n')
  kml.write('<Style>\r\n')
  kml.write('<IconStyle>\r\n')
  kml.write('<Icon><href>%s%s.jpg</href></Icon>\r\n' % (base_thumbs, name_p))
  kml.write('</IconStyle>\r\n')
  kml.write('</Style>\r\n')
  kml.write('<Point>\r\n')
  kml.write('<coordinates>%s,%s,0</coordinates>\r\n' % (gps[1], gps[0]))
  kml.write('</Point>\r\n')
  kml.write('</Placemark>\r\n')
  if not is_kml:
    k.write(path_t, base_thumbs + name_p + '.jpg')
kml.write('</Folder>\r\n')
kml.write('</kml>\r\n')
if is_kml:
  with open(path_kml, 'wb') as k:
    k.write(kml.getvalue().encode())
else:
  k.writestr(path_kml, kml.getvalue().encode())
  k.close()
kml.close()
ctypes.WINFUNCTYPE(ctypes.c_ulong)(2, 'Release')(pFactory)

if nskip or nnodt:
  print('%d image(s) traitée(s) dont' % nproc)
  if nnodt:
    print('  %d image(s) intégrée(s) sans données de date de création' % nnodt)
  if nskip:
    print('  %d image(s) ignorée(s)' % nskip)
  exit(1)
else:
  print('%d image(s) intégrée(s)' % nproc)
  exit(0)