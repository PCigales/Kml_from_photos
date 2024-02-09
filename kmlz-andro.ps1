Add-Type -AssemblyName 'PresentationCore'
$y = $args[2] -ne 'z'
$h = [io.path]::GetFileNameWithoutExtension($args[0].Remove($args[0].Length - 1))
if ($y) {
  $o = $args[1] + $h + ' - andro.kml'
  Write-Host ('Scan de "' + $args[0] + '" pour création de "' + $o + '" et des miniatures dans "' + $args[1] + 'thumbs\"')
} else {
  $o = $args[1] + $h + ' - andro - kmz.kml'
  Write-Host ('Scan de "' + $args[0] + '" pour création de "' + $args[1] + $h + ' - andro.kmz' + '" et des miniatures dans "' + $args[1] + 'thumbs\"')
  Add-Type -AssemblyName 'System.IO.Compression'
  Add-Type -AssemblyName 'System.IO.Compression.FileSystem'
  $z = [System.IO.Compression.ZipArchive]::new([System.IO.FileStream]::new($args[1] + $h + ' - andro.kmz', [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write), [System.IO.Compression.ZipArchiveMode]::Create, $False, [System.Text.UTF8Encoding]::UTF8)
}
$k = [System.IO.StringWriter]::new()
$k.WriteLine('<?xml version="1.0" encoding="UTF-8"?>')
$k.WriteLine('<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">')
$k.WriteLine('<Folder>')
$k.WriteLine('<name>' + $h + '</name>')
$k.WriteLine('<description><![CDATA[Images du répertoire Carte SD/Picture/' + $h + ']]></description>')
$k.WriteLine('<Style id="placemark">')
$k.WriteLine('<IconStyle>')
$k.WriteLine('<scale>2.2</scale>')
$k.WriteLine('</IconStyle>')
$k.WriteLine('<LabelStyle>')
$k.WriteLine('<scale>0.7</scale>')
$k.WriteLine('</LabelStyle>')
$k.WriteLine('<BalloonStyle>')
$k.WriteLine('<bgColor>ff000000</bgColor>')
$k.WriteLine('<textColor>ffaaaaaa</textColor>')
$k.WriteLine('<text>')
$k.WriteLine('<![CDATA[')
$k.WriteLine('<div style="float:left;width:50%;height:1.2em;overflow:auto hidden;white-space:nowrap;color:white;"><b>' + $h + '</b></div>')
$k.WriteLine('<div style="float:right;padding-top:0.2em;font-size:0.8em;color:#aaaaaa;">$[date]</div><br/><hr/>')
$k.WriteLine('<b><font color=#aaaaaa>Lat: </b><code>$[lat]</code>&nbsp;&nbsp;&nbsp;<b>Lon: </b><code>$[lon]</code><br/><br/>')
$k.WriteLine('<div style="width:94vw;height:62vh;"><a href="http://localhost:8080//Android/data/com.google.earth/files/viewer - andro.htm#$[url]"><img src="$[url]" style="max-width:94vw;max-height:62vh;"/></a></div><br/>')
$k.WriteLine('<b>Nom: </b><a href="$[url]">$[name]</a></font><hr/>]]>')
$k.WriteLine('</text>')
$k.WriteLine('</BalloonStyle>')
$k.WriteLine('</Style>')
$l = [System.IO.Directory]::EnumerateFiles($args[0], '*.jp*g', [System.IO.SearchOption]::TopDirectoryOnly) | Sort-Object
$a = $args[1] + 'thumbs\' + $h + ' - '
if ($y) {$u = 'http://localhost:8080/Android/data/com.google.earth/files/thumbs/' + $h + ' - '} else {$u = 'thumbs/' + $h + ' - '}
$n = 0
$c = 0
$j = 0
foreach ($p in $l) {
  $b = [io.path]::GetFileNameWithoutExtension($p)
  $n++
  $x = [System.IO.File]::Exists($a + $b + '.jpg')
  try {
    $s = [System.IO.FileStream]::new($p, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read)
    $d = [System.Windows.Media.Imaging.JpegBitmapDecoder]::new($s, [System.Windows.Media.Imaging.BitmapCreateOptions]::DelayCreation, [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad)
    $i = $d.Frames[0]
    $g = $i.Metadata.GetQuery('/app1/ifd/{ushort=34853}/{ushort=2}'), $i.Metadata.GetQuery('/app1/ifd/{ushort=34853}/{ushort=4}')
    if (($g[0].Length -ne 3) -or ($g[1].Length -ne 3)) {
      $c++
      [Console]::ForegroundColor=[ConsoleColor]::DarkRed
      [Console]::WriteLine('Traitement de "' + [io.path]::GetFileName($p) + '" -> ignoré (pas de données de géolocalisation)')
      continue
    }
    $w = (0, 0);
    $g[0][-1 .. -3].ForEach({$v = [System.Bitconverter]::GetBytes($_); $w[0] = $w[0] / 60 + [System.Bitconverter]::ToUInt32($v, 0) / [System.Bitconverter]::ToUInt32($v, 4)});
    if ($i.Metadata.GetQuery('/app1/ifd/{ushort=34853}/{ushort=1}') -in 'S', 's') {$w[0] = -$w[0];}
    $g[1][-1 .. -3].ForEach({$v = [System.Bitconverter]::GetBytes($_); $w[1] = $w[1] / 60 + [System.Bitconverter]::ToUInt32($v, 0) / [System.Bitconverter]::ToUInt32($v, 4)});
    if ($i.Metadata.GetQuery('/app1/ifd/{ushort=34853}/{ushort=3}') -in 'W', 'w') {$w[1] = -$w[1];}
    $w = $w.ForEach({$_.toString($(if ($_ -ge 0) {'+'} else {''}) + '0.000000', [cultureinfo]::InvariantCulture)})
    if (-not $x) {
      $r = $i.Metadata.GetQuery('/app1/ifd/{ushort=274}') -bor 0
      $m = 150 / [math]::Max($i.PixelWidth, $i.PixelHeight)
      $g = [System.Windows.Media.TransformGroup]::new()
      $g.Children.Add([System.Windows.Media.ScaleTransform]::new($m, $m))
      Switch ($r) {{$_ -in 3, 4} {$g.Children.Add([System.Windows.Media.RotateTransform]::new(180)); break} {$_ -in 5, 6} {$g.Children.Add([System.Windows.Media.RotateTransform]::new(90)); break} {$_ -in 7, 8} {$g.Children.Add([System.Windows.Media.RotateTransform]::new(270)); break}}
      $t = [System.Windows.Media.Imaging.TransformedBitmap]::new($i, $g)
      $f = [System.Windows.Media.Imaging.BitmapFrame]::Create($t)
      $e = [System.Windows.Media.Imaging.JpegBitmapEncoder]::new()
      $e.QualityLevel = 85
      $e.Frames.Add($f)
      try {$s.Close()} catch {}
      $s = [System.IO.FileStream]::new($a + $b + '.jpg', [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)
      $e.Save($s)
    }
  } catch {
    $c++
    [Console]::ForegroundColor=[ConsoleColor]::DarkRed
    [Console]::WriteLine('Traitement de "' + [io.path]::GetFileName($p) + '" -> ignoré (format non reconnu)')
    try {$s.Close()} catch {}
    continue
  }
  $d = $i.Metadata.GetQuery('/app1/ifd/{ushort=34665}/{ushort=36868}') -split ' '
  if ($d.Length -eq 2) {
    $d[0] = ($d[0] -split ':')[-1 .. -3] -join '/'
    $d = $d -join ' '
    [Console]::ForegroundColor=[ConsoleColor]::DarkGreen
    if ($x) {[Console]::WriteLine('Traitement de "' + [io.path]::GetFileName($p) + '"')} else {[Console]::WriteLine('Traitement et création de miniature de "' + [io.path]::GetFileName($p) + '"')}
  } else {
    $j++
    $d = '-'
    [Console]::ForegroundColor=[ConsoleColor]::DarkYellow
    if ($x) {[Console]::WriteLine('Traitement de "' + [io.path]::GetFileName($p) + '" -> intégré sans données de date de création')} else {[Console]::WriteLine('Traitement et création de miniature de "' + [io.path]::GetFileName($p) + '" -> intégré sans données de date de création')}
  }
  try {$s.Close()} catch {}
  $k.WriteLine('<Placemark>')
  $k.WriteLine('<name>' + $b + '</name>')
  $k.WriteLine('<ExtendedData>')
  $k.WriteLine('<Data name="date"><value>' + $d + '</value></Data>')
  $k.WriteLine('<Data name="lat"><value>' + $w[0] + '</value></Data>')
  $k.WriteLine('<Data name="lon"><value>' + $w[1] + '</value></Data>')
  $k.WriteLine('<Data name="url"><value>http://localhost:8080/Picture/' + $h + '/' + [io.path]::GetFileName($p) + '</value></Data>')
  $k.WriteLine('</ExtendedData>')
  $k.WriteLine('<styleUrl>#placemark</styleUrl>')
  $k.WriteLine('<Style>')
  $k.WriteLine('<IconStyle>')
  $k.WriteLine('<Icon><href>' + $u + $b + '.jpg</href></Icon>')
  $k.WriteLine('</IconStyle>')
  $k.WriteLine('</Style>')
  $k.WriteLine('<Point>')
  $k.WriteLine('<coordinates>' + $w[1] + ',' + $w[0] + ',0</coordinates>')
  $k.WriteLine('</Point>')
  $k.WriteLine('</Placemark>')
  if (-not $y) {[void][System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($z, $a + $b + '.jpg', $u + $b + '.jpg')}
}
[Console]::ResetColor()
$k.WriteLine('</Folder>')
$k.WriteLine('</kml>')
[System.IO.File]::WriteAllText($o, $k, [System.Text.UTF8Encoding]::new($False))
if (-not $y) {
  [void][System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($z, $o, $h + ' - andro - kmz.kml')
  $z.Dispose()
  [System.IO.File]::Delete($o)
  }
if (($c -eq 0) -and ($j -eq 0)) {
  Write-Host ($n.ToString() + ' image(s) intégrée(s)')
  exit 0
} else {
  Write-Host ($n.ToString() + ' image(s) traitée(s) dont')
  if ($j -ne 0) {Write-Host ('  ' + $j.ToString() + ' image(s) intégrée(s) sans données de date de création')}
  if ($c -ne 0) {Write-Host ('  ' + $c.ToString() + ' image(s) ignorée(s)')}
  exit 1
}