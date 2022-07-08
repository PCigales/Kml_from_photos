@echo off
setlocal enabledelayedexpansion
if "%~1"=="" (set kmlrepscan=%~dp0) else (for /F "delims=" %%i in ("%~1\") do set kmlrepscan=%%~dpi)
if "%~2"=="" (set kmlrepdest=%kmlrepscan%) else (for /F "delims=" %%i in ("%~2\") do set kmlrepdest=%%~dpi)
if not exist "%kmlrepdest%thumbs" mkdir "%kmlrepdest%thumbs"
chcp 1252 >nul
echo.
echo Scan de "%kmlrepscan%" pour cr�ation des miniatures dans "%kmlrepdest%thumbs\"
for /F "delims=/" %%i in ("%kmlrepscan:~0,-1%") do set kmlname=%%~ni
if exist "%kmlrepdest%%kmlname%.lst" del "%kmlrepdest%%kmlname%.lst"
set kmlerr=0
for %%i in ("%kmlrepscan%*.jp*g") do if not exist "%kmlrepdest%thumbs\%kmlname% - %%~ni.jpg" echo %%i >>"%kmlrepdest%%kmlname%.lst"
if exist "%kmlrepdest%%kmlname%.lst" (
if exist "%~dp0resize.py" (
"%~dp0resize" "%kmlrepdest%%kmlname%.lst" "%kmlrepdest%thumbs\%kmlname%"
) else (
"C:\Program Files (x86)\Irfanview\i_view32.exe" /filelist="%kmlrepdest%\%kmlname%.lst" /resize_long=150 /aspectratio /resample /ini="%~dp0" /convert="%kmlrepdest%thumbs\%kmlname% - $N.jpg")
if !ERRORLEVEL! NEQ 0 (
set kmlerr=1
echo Erreur lors de la cr�ation des miniatures)
del "%kmlrepdest%%kmlname%.lst")
set kmzfic="%kmlrepdest%%kmlname%.kmz"
set kmlfic="%kmlrepdest%%kmlname% - kmz.kml"
set kmlviewer=%kmlrepdest%viewer.htm
if not exist "%kmlviewer%" copy "%~dp0viewer.htm" "%kmlviewer%">nul
set kmliconpref=thumbs/%kmlname% - 
echo. 2>"%kmlrepdest%%kmlname%.lst"
echo Scan de "%kmlrepscan%" pour cr�ation de %kmlfic%
echo %kmlname% - kmz.kml>"%kmlrepdest%%kmlname% - kmz.lst"
for /F "delims=*" %%i in ('dir /b /o:n "%kmlrepscan%*.jp*g"') do (
echo %kmlrepscan%%%~nxi>>"%kmlrepdest%%kmlname%.lst"
echo thumbs\%kmlname% - %%~ni.jpg>>"%kmlrepdest%%kmlname% - kmz.lst")
chcp 65001 >nul
"C:\Program Files (x86)\ExifTool\exiftool.exe" -createdate -gpslatitude -gpslongitude -ifd0:orientation# -filename -d "%%d/%%m/%%Y %%H:%%M:%%S" -c "%%+.6f" -f -args -charset filename=Latin -charset EXIF=UTF8 -@ "%kmlrepdest%%kmlname%.lst" >"%kmlrepdest%%kmlname%.exif"
if !ERRORLEVEL! NEQ 0 (
set kmlerr=1
echo Erreur lors de la récupération des métadonnées)
echo ^<?xml version="1.0" encoding="UTF-8"?^>>%kmlfic%
echo ^<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom"^>>>%kmlfic%
echo ^<Folder^>>>%kmlfic%
echo ^<name^>%kmlname%^</name^>>>%kmlfic%
echo ^<description^>^<^^![CDATA[Images du répertoire %kmlrepscan:~0,-1%]]^>^</description^>>>%kmlfic%
echo ^<Style id="placemark"^>>>%kmlfic%
echo ^<IconStyle^>>>%kmlfic%
echo ^<scale^>2.2^</scale^>>>%kmlfic%
echo ^</IconStyle^>>>%kmlfic%
echo ^<LabelStyle^>>>%kmlfic%
echo ^<scale^>0.7^</scale^>>>%kmlfic%
echo ^</LabelStyle^>>>%kmlfic%
echo ^<BalloonStyle^>>>%kmlfic%
echo ^<bgColor^>ff000000^</bgColor^>>>%kmlfic%
echo ^<textColor^>ffaaaaaa^</textColor^>>>%kmlfic%
echo ^<text^>>>%kmlfic%
echo ^<^^![CDATA[>>%kmlfic%
echo ^<style type="text/css"^>>>%kmlfic%
echo .ori0 {max-width:300px;max-height:200px;}>>%kmlfic%
echo .ori1 {max-width:200px;max-height:300px;-webkit-transform:rotate^(90deg^) translate^(0px,-100%%^);-webkit-transform-origin:top left;}>>%kmlfic%
echo .ori2 {max-width:200px;max-height:300px;-webkit-transform:rotate^(270deg^) translate^(-100%%,0px^);-webkit-transform-origin:top left;}>>%kmlfic%
echo .ori3 {max-width:300px;max-height:200px;-webkit-transform:rotate^(180deg^) translate^(-100%%,-100%%^);-webkit-transform-origin:top left;}>>%kmlfic%
echo ^</style^>>>%kmlfic%
echo ^<div style="float:left;width:200px;height:1.2em;overflow:hidden;"^>^<b^>%kmlname%^</b^>^</div^>>>%kmlfic%
echo ^<div style="float:right;padding-top:0.2em;font-size:0.8em;"^>$[date]^</div^>^<br/^>^<hr/^>>>%kmlfic%
echo ^<b^>Lat: ^</b^>^<code^>$[lat]^</code^>^&nbsp;^&nbsp;^&nbsp;^<b^>Lon: ^</b^>^<code^>$[lon]^</code^>^<br/^>^<br/^>>>%kmlfic%
echo ^<div style="width:308px;height:200px;"^>^<img src="$[url]" class="ori$[ori]" onerror="if (this.getAttribute(&quot;src&quot;).substring(0,1)&excl;=&quot;.&quot;) {this.src=(window.location.href.split(&quot;.&quot;).pop().slice(0, 3).toLowerCase()==&quot;kmz&quot;?&quot;../&quot;:&quot;./&quot;)+this.src.split(&quot;/&quot;).pop();} else {this.src=&quot;$[urlt]&quot;;this.className=&quot;ori0&quot;;this.onerror=null;}"/^>^</div^>^<br/^>>>%kmlfic%
echo ^<div style="width:300px;"^>^<b^>Nom: ^</b^>^<a href="" id="lien"^>$[name]^</a^>^</div^>^<hr/^>>>%kmlfic%
echo ^<script^>>>%kmlfic%
echo var p="$[ori]"+encodeURIComponent^("$[url]"^).replace^(/%%/g,"*"^);>>%kmlfic%
echo document.getElementById^("lien"^).href=(window.location.href.split(".").pop().slice(0, 3).toLowerCase()=="kmz"?"..":".")+"/viewer.htm#"+p;>>%kmlfic%
echo ^</script^>>>%kmlfic%
echo ^<br/^>$[geDirections]]]^>>>%kmlfic%
echo ^</text^>>>%kmlfic%
echo ^</BalloonStyle^>>>%kmlfic%
echo ^</Style^>>>%kmlfic%
echo ^<Style^>>>%kmlfic%
echo ^<BalloonStyle^>>>%kmlfic%
echo ^<bgColor^>ff000000^</bgColor^>>>%kmlfic%
echo ^<textColor^>ffaaaaaa^</textColor^>>>%kmlfic%
echo ^</BalloonStyle^>>>%kmlfic%
echo ^</Style^>>>%kmlfic%
set kmlnbim=0
set kmlnbimsgps=0
set kmlnbimsdate=0
for /F "usebackq tokens=1,2 delims==" %%i in ("%kmlrepdest%%kmlname%.exif") do (
if /I "%%i"=="-CreateDate" set kmldate=%%j
if /I "%%i"=="-GPSLatitude" set kmllatitude=%%j
if /I "%%i"=="-GPSLongitude" set kmllongitude=%%j
if /I "%%i"=="-Orientation#" set kmlorientation=%%j
if /I "%%i"=="-Filename" (
set /A kmlnbim=!kmlnbim!+1
set kmldate=!kmlDate:~0,19!
if !kmlorientation!==6 (set kmlorientation=1) else if !kmlorientation!==8 (set kmlorientation=2) else if not !kmlorientation!==3 (set kmlorientation=0)
for /F "delims=*" %%k in ("%%j") do set kmlimgnom=%%~nj
if not "!kmllatitude!"=="" (
if not "!kmllongitude!"=="" (
if "!kmldate!"=="-" (
set /A kmlnbimsdate=!kmlnbimsdate!+1
echo Traitement de %%j -^> intégrée sans données de date de création) else echo Traitement de %%j
set kmlurl=file:///%kmlrepscan%%%j
set kmlurl=!kmlurl:\=/!
echo ^<Placemark^>>>%kmlfic%
echo ^<name^>!kmlimgnom!^</name^>>>%kmlfic%
echo ^<ExtendedData^>>>%kmlfic%
echo ^<Data name="date"^>^<value^>!kmldate!^</value^>^</Data^>>>%kmlfic%
echo ^<Data name="lat"^>^<value^>!kmllatitude!^</value^>^</Data^>>>%kmlfic%
echo ^<Data name="lon"^>^<value^>!kmllongitude!^</value^>^</Data^>>>%kmlfic%
echo ^<Data name="url"^>^<value^>!kmlurl!^</value^>^</Data^>>>%kmlfic%
echo ^<Data name="ori"^>^<value^>!kmlorientation!^</value^>^</Data^>>>%kmlfic%
echo ^<Data name="urlt"^>^<value^>%kmliconpref%!kmlimgnom!.jpg^</value^>^</Data^>>>%kmlfic%
echo ^</ExtendedData^>>>%kmlfic%
echo ^<styleUrl^>#placemark^</styleUrl^>>>%kmlfic%
echo ^<Style^>>>%kmlfic%
echo ^<IconStyle^>>>%kmlfic%
echo ^<Icon^>^<href^>%kmliconpref%!kmlimgnom!.jpg^</href^>^</Icon^>>>%kmlfic%
echo ^</IconStyle^>>>%kmlfic%
echo ^</Style^>>>%kmlfic%
echo ^<Point^>>>%kmlfic%
echo ^<coordinates^>!kmllongitude!,!kmllatitude!,0^</coordinates^>>>%kmlfic%
echo ^</Point^>>>%kmlfic%
echo ^</Placemark^>>>%kmlfic%
) else (
set /A kmlnbimsgps=!kmlnbimsgps!+1
echo Traitement de %%j -^> ignorée ^(pas de données de géolocalisation^))) else (
set /A kmlnbimsgps=!kmlnbimsgps!+1
echo Traitement de %%j -^> ignorée ^(pas de données de géolocalisation^))
)
)
echo ^</Folder^>>>%kmlfic%
echo ^</kml^>>>%kmlfic%
del "%kmlrepdest%%kmlname%.lst"
del "%kmlrepdest%%kmlname%.exif"
echo Génération de %kmzfic%
tar  -c -a --options hdrcharset=UTF-8 -f %kmzfic%.zip -C "%kmlrepdest:~0,-1%" -T "%kmlrepdest%%kmlname% - kmz.lst"
move /Y %kmzfic%.zip %kmzfic% >nul
del "%kmlrepdest%%kmlname% - kmz.lst"
del %kmlfic%
echo %kmlnbim% image^(s^) traitée^(s^)
if not %kmlnbimsgps%%kmlnbimsdate%%kmlerr%==000 (
if not %kmlnbimsdate%==0 echo dont %kmlnbimsdate% image^(s^) intégrée^(s^) sans données de date de création
if not %kmlnbimsgps%==0 echo dont %kmlnbimsgps% image^(s^) ignorée^(s^) ^(pas de données de géolocalisation^)
echo.
pause)
chcp 850 >nul
endlocal
echo on
@if "%~3"=="exit" @exit