Add-Type -AssemblyName 'PresentationCore'
$l = Get-Content $args[0]
$n = 0
$c = 0
foreach ($p in $l) {
  $b = [io.path]::GetFileNameWithoutExtension($p)
  $n++
  try {
    $s = [System.IO.FileStream]::new($p, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read)
    $d = [System.Windows.Media.Imaging.JpegBitmapDecoder]::new($s, [System.Windows.Media.Imaging.BitmapCreateOptions]::PreservePixelFormat, [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad)
  } catch {
    $c++
    Write-Host ("Traitement de " + [io.path]::GetFileName($p) + " -> ignoré (format non reconnu)")
    continue
  } finally {
    try {$s.Close()} catch {}
  }
  Write-Host ("Traitement de " + [io.path]::GetFileName($p))
  $i = $d.Frames[0]
  $m = 150 / [math]::Max($i.PixelWidth, $i.PixelHeight)
  $r = $i.Metadata.GetQuery("/app1/ifd/exif:{ushort=274}") -bor 0
  $g = [System.Windows.Media.TransformGroup]::new()
  $g.Children.Add([System.Windows.Media.ScaleTransform]::new($m, $m))
  Switch ($r) {{3, 4 -eq $_} {$g.Children.Add([System.Windows.Media.RotateTransform]::new(180)); break} {5, 6 -eq $_} {$g.Children.Add([System.Windows.Media.RotateTransform]::new(90)); break} {7, 8 -eq $_} {$g.Children.Add([System.Windows.Media.RotateTransform]::new(270)); break}}
  $t = [System.Windows.Media.Imaging.TransformedBitmap]::new($i, $g)
  $f = [System.Windows.Media.Imaging.BitmapFrame]::Create($t)
  $e = [System.Windows.Media.Imaging.JpegBitmapEncoder]::new()
  if ($d.ColorContexts -ne $null) {$e.ColorContexts = $d.ColorContexts}
  $e.QualityLevel = 85
  $e.Frames.Add($f)
  $s = [System.IO.FileStream]::new($args[1] + " - " + $b + ".jpg", [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)
  $e.Save($s)
  $s.Close()
}
if ($c -eq 0) {
  Write-Host ($n.ToString() + " image(s) traitée(s)")
  exit 0
} else {
  Write-Host ($n.ToString() + " image(s) traitée(s) dont")
  Write-Host ("  " + $c.ToString() + " image(s) non reconnue(s)")
  exit 1
}