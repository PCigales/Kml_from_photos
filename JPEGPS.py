import struct
import os
import time
import argparse
from functools import partial

def read_gps(image):
  try:
    f = open(image, 'rb')
  except:
    return
  if f.read(2) != b'\xff\xd8':
    f.close()
    return
  try:
    t = f.read(2)
    if t == b'\xff\xe0':
      len = struct.unpack('!H', f.read(2))[0]
      f.read(len - 2)
      t = f.read(2)
    if t != b'\xff\xe1':
      raise
    len = struct.unpack('!H', f.read(2))[0]
    if f.read(6) != b'Exif\x00\x00':
      raise
    ref = f.tell()
    ba = {b'MM': '>', b'II': '<'}.get(f.read(2),'')
    if ba == '':
      raise
    if f.read(2) != (b'\x00\x2a' if ba == '>' else b'\x2a\x00') :
      raise
    f.read(struct.unpack(ba + 'I', f.read(4))[0] - 8)
    ne = struct.unpack(ba + 'H', f.read(2))[0]
    if ne == 0:
      raise
    for i in range(ne):
      e = f.read(12)
      if struct.unpack(ba + 'H', e[0:2])[0] == 0x8825:
        if struct.unpack(ba + 'H', e[2:4])[0] != 4 or struct.unpack(ba + 'I', e[4:8])[0] != 1:
          raise
        f.seek(ref + struct.unpack(ba + 'I', e[8:12])[0])
        break
    if struct.unpack(ba + 'H', e[0:2])[0] != 0x8825:
      raise
    ne = struct.unpack(ba + 'H', f.read(2))[0]
    if ne == 0:
      raise
    pos = [None] * 4
    for i in range(ne):
      e = f.read(12)
      if struct.unpack(ba + 'H', e[0:2])[0] in (0x0001, 0x0003):
        if struct.unpack(ba + 'H', e[2:4])[0] != 2 or struct.unpack(ba + 'I', e[4:8])[0] != 2:
          raise
        pos[struct.unpack(ba + 'H', e[0:2])[0] - 1] = f.tell() - 4
      if struct.unpack(ba + 'H', e[0:2])[0] in (0x0002, 0x0004):
        if struct.unpack(ba + 'H', e[2:4])[0] != 5 or struct.unpack(ba + 'I', e[4:8])[0] != 3:
          raise
        pos[struct.unpack(ba + 'H', e[0:2])[0] - 1] = struct.unpack(ba + 'I', e[8:12])[0] + ref
    if None in pos:
      raise
    geotag = {'byte_align': ba}
    for i in range(2):
      tag = {0:'latitude_ref', 1:'longitude_ref'}.get(i)
      f.seek(pos[2 * i])
      geotag[tag] = {'pos': pos[2 * i], 'val': f.read(2).strip(b'\x00').upper().decode()}
      tag = {0:'latitude', 1:'longitude'}.get(i)
      f.seek(pos[2 * i + 1])
      d = f.read(24)
      geotag[tag] = {'pos': pos[2 * i + 1], 'val': struct.unpack(ba + 'IIIIII', d)}
  except:
    return
  finally:
    f.close()
  try:
    lat = round((-1 if geotag['latitude_ref']['val'] == 'S' else 1) * sum(n / d * u for n, d, u in zip(geotag['latitude']['val'][::2], geotag['latitude']['val'][1::2], (3600, 60, 1))), 3)
    if lat < -90 * 3600 or lat > 90 * 3600:
      raise
    lon = 180 * 3600 - (180 * 3600 - round((-1 if geotag['longitude_ref']['val'] == 'W' else 1) * sum(n / d * u for n, d, u in zip(geotag['longitude']['val'][::2], geotag['longitude']['val'][1::2], (3600, 60, 1))), 3)) % (360 * 3600)
    geotag['dec'] = '%.6f,%.6f' % (lat / 3600, lon / 3600)
    geotag['dms'] = '%.0f°%02.0f\'%06.3f"%s %.0f°%02.0f\'%06.3f"%s' % (abs(lat) // 3600, (abs(lat) % 3600) // 60, abs(lat) % 60, ('N' if lat >= 0 else 'S'), abs(lon) // 3600, (abs(lon) % 3600) // 60, abs(lon) % 60, ('E' if lon >= 0 else 'W'))
  except:
    return
  return geotag

def write_gps(image, new_coord, cur_geotag=None):
  if cur_geotag == None:
    new_geotag = read_gps(image)
    if new_geotag == None:
      return
  else:
    try:
      new_geotag = {**cur_geotag}
    except:
      return
  nd = new_coord.count('°')
  if nd == 0:
    try:
      lat, lon = map(float, new_coord.replace(',', ' ').split())
      lat = round(lat * 3600, 3)
      if lat < -90 * 3600 or lat > 90 * 3600:
        raise
      lon = 180 * 3600 - (180 * 3600 - round(lon * 3600, 3)) % (360 * 3600)
    except:
      return
  elif nd == 2:
    if '-' in new_coord:
      return
    try:
      lat_s, lon_s = new_coord.replace(',', ' ').rsplit('°', 1)
      lat_s = lat_s.strip().replace('\'\'', '"')
      lon_s = lon_s.strip().replace('\'\'', '"')
      lon_s = '°' + lon_s
      while lat_s[-1].isdecimal():
        lon_s = lat_s[-1] + lon_s
        lat_s = lat_s[:-1]
      lat_s = lat_s.strip()
      if lat_s[-1].upper() in ('S', 'N'):
        lat = -1 if lat_s[-1].upper() == 'S' else 1
        lat_s = lat_s[:-1].strip()
      else:
        lat = 1
      if lon_s[-1].upper() in ('W', 'E'):
        lon = -1 if lon_s[-1].upper() == 'W' else 1
        lon_s = lon_s[:-1].strip()
      else:
        lon = 1
      if lat_s[-1] == '"':
        lat_s, lat_sec = lat_s[:-1].split('\'')
        lat_sec = float(lat_sec.strip())
        lat_s = lat_s.strip() + '\''
      else:
        lat_sec = 0
      if lat_s[-1] == '\'':
        lat_s, lat_min = lat_s[:-1].split('°')
        lat_min = int(lat_min.strip())
        lat_s = lat_s.strip() + '°'
      else:
        lat_min = 0
      if lat_s[-1] == '°':
        lat_deg = int(lat_s[:-1].strip())
      else:
        raise
      lat = round(lat * (lat_sec + lat_min * 60 + lat_deg * 3600), 3)
      if lat < -90 * 3600 or lat > 90 * 3600:
        raise
      if lon_s[-1] == '"':
        lon_s, lon_sec = lon_s[:-1].split('\'')
        lon_sec = float(lon_sec.strip())
        lon_s = lon_s.strip() + '\''
      else:
        lon_sec = 0
      if lon_s[-1] == '\'':
        lon_s, lon_min = lon_s[:-1].split('°')
        lon_min = int(lon_min.strip())
        lon_s = lon_s.strip() + '°'
      else:
        lon_min = 0
      if lon_s[-1] == '°':
        lon_deg = int(lon_s[:-1].strip())
      else:
        raise
      lon = 180 * 3600 - (180 * 3600 - round(lon * (lon_sec + lon_min * 60 + lon_deg * 3600), 3)) % (360 * 3600)
    except:
      return
  else:
    return
  try:
    if lat < 0:
      lat = -lat
      new_geotag['latitude_ref']['val'] = 'S'
    else:
      new_geotag['latitude_ref']['val'] = 'N'
    if lon < 0:
      lon = -lon
      new_geotag['longitude_ref']['val'] = 'W'
    else:
      new_geotag['longitude_ref']['val'] = 'E'
    new_geotag['latitude']['val'] = (int(lat) // 3600, 1, (int(lat) % 3600) // 60, 1, round((lat % 60) * 1000), 1000)
    new_geotag['longitude']['val'] = (int(lon) // 3600, 1, (int(lon) % 3600) // 60, 1, round((lon % 60) * 1000), 1000)
    new_geotag['dec'] = '%s%.6f,%s%.6f' % (('-' if new_geotag['latitude_ref']['val'] == 'S' else ''), lat / 3600, ('-' if new_geotag['longitude_ref']['val'] == 'W' else ''), lon / 3600)
    new_geotag['dms'] = '%.0f°%02.0f\'%06.3f"%s %.0f°%02.0f\'%06.3f"%s' % (lat // 3600, (lat % 3600) // 60, lat % 60, new_geotag['latitude_ref']['val'], lon // 3600, (lon % 3600) // 60, lon % 60, new_geotag['longitude_ref']['val'])
  except:
    return
  try:
    mt = os.stat(image).st_mtime
    f = open(image, 'r+b')
  except:
    return
  try:
    for i in range(2):
      tag = {0:'latitude_ref', 1:'longitude_ref'}.get(i)
      f.seek(new_geotag[tag]['pos'])
      f.write(new_geotag[tag]['val'].encode() + b'\x00' * 3)
      tag = {0:'latitude', 1:'longitude'}.get(i)
      f.seek(new_geotag[tag]['pos'])
      f.write(struct.pack(new_geotag['byte_align'] + 'IIIIII', *new_geotag[tag]['val']))
  except:
    return
  finally:
    f.close()
    try:
      os.utime(image, (time.time(), mt))
    except:
      pass
  return new_geotag


if __name__ == '__main__':
  formatter = lambda prog: argparse.HelpFormatter(prog, max_help_position=50, width=119)
  CustomArgumentParser = partial(argparse.ArgumentParser, formatter_class=formatter)
  parser = CustomArgumentParser()
  parser.add_argument('file', metavar='FILE', help='chemin du fichier')
  parser.add_argument('coord', metavar='COORD', help='nouvelles coordonnées (laisser vide pour uniquement afficher les informations de localisation présentes) au format {"[ -]XX.XXX,[-]YYY.YYY"} ou {XX°XX\'XX.X\\"[N|S] YYY°YY\'YY.Y\\"[E|W]}', nargs='*')
  parser.add_argument('--details', '-d', help='affiche les détails du géotag', action='store_true')
  args = parser.parse_args()
  if args.coord == []:
    geotag = read_gps(args.file)
  else:
    geotag = write_gps(args.file, ' '.join(args.coord))
  if geotag == None:
    print('erreur')
  else:
    print(geotag['dec'] + '\r\n' + geotag['dms'])
    if args.details:
      print(geotag)
