@echo off
setlocal enabledelayedexpansion
if "%~1"=="" (set kmlrepscan="%~dp0") else (for /F "delims=" %%i in ("%~1\") do set kmlrepscan=%%~dpi)
if "%~2"=="" (set kmlrepdest=%kmlrepscan%) else (for /F "delims=" %%i in ("%~2\") do set kmlrepdest=%%~dpi)
if not exist "%kmlrepdest%thumbs" mkdir "%kmlrepdest%thumbs"
chcp 1252 >nul
echo.
echo Scan de "%kmlrepscan%" pour cr�ation des miniatures dans "%kmlrepdest%thumbs\"
for /F "delims=/" %%i in ("%kmlrepscan:~0,-1%") do set kmlname=%%~ni
if exist "%kmlrepdest%%kmlname%.lst" del "%kmlrepdest%%kmlname%.lst"
set kmltherr=0
for %%i in ("%kmlrepscan%*.jp*g") do if not exist "%kmlrepdest%thumbs\%kmlname% - %%~ni.jpg" echo %%i >>"%kmlrepdest%%kmlname%.lst"
if exist "%kmlrepdest%%kmlname%.lst" (
if exist "%~dp0resize.py" (
"%~dp0resize" "%kmlrepdest%%kmlname%.lst" "%kmlrepdest%thumbs\%kmlname%"
if !ERRORLEVEL! NEQ 0 set kmltherr=1
) else (
"C:\Program Files (x86)\Irfanview\i_view32.exe" /filelist="%kmlrepdest%\%kmlname%.lst" /resize_long=150 /aspectratio /resample /ini="%~dp0" /convert="%kmlrepdest%thumbs\%kmlname% - $N.jpg")
del "%kmlrepdest%%kmlname%.lst")
set kmlfic="%kmlrepdest%%kmlname% - andro.kml"
echo.
echo Scan de "%kmlrepscan%" pour cr�ation de %kmlfic%
for /F "delims=*" %%i in ('dir /b /o:n "%kmlrepscan%*.jp*g"') do echo %kmlrepscan%%%~nxi>>"%kmlrepdest%%kmlname%.lst"
chcp 65001 >nul
echo ^<?xml version="1.0" encoding="UTF-8"?^>>%kmlfic%
echo ^<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom"^>>>%kmlfic%
echo ^<Folder^>>>%kmlfic%
echo ^<name^>%kmlname%^</name^>>>%kmlfic%
"C:\Program Files (x86)\ExifTool\exiftool.exe" -createdate -gpslatitude -gpslongitude -filename -d "%%d/%%m/%%Y %%H:%%M:%%S" -c "%%+.6f" -f -args -charset filename=Latin -charset EXIF=UTF8 -@ "%kmlrepdest%%kmlname%.lst" >"%kmlrepdest%%kmlname%.exif"
echo ^<description^>^<^^![CDATA[Images du répertoire Carte SD/Picture/%kmlname%]]^>^</description^>>>%kmlfic%
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
echo ^<^^![CDATA[^<div style="float:left;width:50%%;height:1.2em;overflow:hidden;color:white;"^>^<b^>%kmlname%^</b^>^</div^>^<div style="float:right;padding-top:0.2em;font-size:0.8em;color:#aaaaaa"^>$[date]^</div^>^<br/^>^<hr/^>>>%kmlfic%
echo ^<b^>^<font color=#aaaaaa^>Lat: ^</b^>^<code^>$[lat]^</code^>^&nbsp;^&nbsp;^&nbsp;^<b^>Lon: ^</b^>^<code^>$[lon]^</code^>^<br/^>^<br/^>>>%kmlfic%
echo ^<div style="width:96vw;height:64vh;"^>^<img src="$[url]" style="max-width:96vw;max-height:64vh;"/^>^</div^>^<br/^>>>%kmlfic%
echo ^<b^>Nom: ^</b^>^<a href="$[url]"^>$[name]^</a^>^</font^>^<hr/^>]]^>>>%kmlfic%
echo ^</text^>>>%kmlfic%
echo ^</BalloonStyle^>>>%kmlfic%
echo ^</Style^>>>%kmlfic%
set kmlnbim=0
set kmlnbimsgps=0
set kmlnbimsdate=0
for /F "usebackq tokens=1,2 delims==" %%i in ("%kmlrepdest%%kmlname%.exif") do (
if /I "%%i"=="-CreateDate" set kmldate=%%j
if /I "%%i"=="-GPSLatitude" set kmllatitude=%%j
if /I "%%i"=="-GPSLongitude" set kmllongitude=%%j
if /I "%%i"=="-Filename" (
set /A kmlnbim=!kmlnbim!+1
set kmldate=!kmlDate:~0,19!
set kmllatitude=!kmllatitude:~0,-2!
set kmllongitude=!kmllongitude:~0,-2!
for /F "delims=*" %%k in ("%%j") do set kmlimgnom=%%~nj
if not "!kmllatitude!"=="" (
if not "!kmllongitude!"=="" (
if "!kmldate!"=="-" (
set /A kmlnbimsdate=!kmlnbimsdate!+1
echo Traitement de %%j -^> intégrée sans données de date de création) else echo Traitement de %%j
set kmlurl=http://localhost:8080/Picture/%kmlname%/%%j
echo ^<Placemark^>>>%kmlfic%
echo ^<name^>!kmlimgnom!^</name^>>>%kmlfic%
echo ^<ExtendedData^>>>%kmlfic%
echo ^<Data name="date"^>^<value^>!kmldate!^</value^>^</Data^>>>%kmlfic%
echo ^<Data name="lat"^>^<value^>!kmllatitude!^</value^>^</Data^>>>%kmlfic%
echo ^<Data name="lon"^>^<value^>!kmllongitude!^</value^>^</Data^>>>%kmlfic%
echo ^<Data name="url"^>^<value^>!kmlurl!^</value^>^</Data^>>>%kmlfic%
echo ^</ExtendedData^>>>%kmlfic%
echo ^<styleUrl^>#placemark^</styleUrl^>>>%kmlfic%
echo ^<Style^>>>%kmlfic%
echo ^<IconStyle^>>>%kmlfic%
echo ^<Icon^>^<href^>http://localhost:8080/Android/data/com.google.earth/files/thumbs/%kmlname% - !kmlimgnom!.jpg^</href^>^</Icon^>>>%kmlfic%
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
if %kmlnbimsgps%==0 (
if %kmlnbimsdate%==0 (
echo %kmlnbim% image^(s^) traitée^(s^)
if "%~3"=="exit" if %kmltherr%==0 (
chcp 850 >nul
endlocal
echo on
@exit)) else (
echo %kmlnbim% image^(s^) traitée^(s^) dont
echo   %kmlnbimsdate% image^(s^) intégrée^(s^) sans données de date de création
)) else (
echo %kmlnbim% image^(s^) traitée^(s^) dont
if not %kmlnbimsdate%==0 echo   %kmlnbimsdate% image^(s^) intégrée^(s^) sans données de date de création
echo   %kmlnbimsgps% image^(s^) ignorée^(s^) ^(pas de données de géolocalisation^))
chcp 850 >nul
endlocal
echo on