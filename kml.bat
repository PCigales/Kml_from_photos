@echo off
setlocal enabledelayedexpansion
if "%~1"=="" (set kmlrepscan=%~dp0) else (for /F "delims=" %%i in ("%~1\") do set kmlrepscan=%%~dpi)
if "%~2"=="" (set kmlrepdest=%kmlrepscan%) else (for /F "delims=" %%i in ("%~2\") do set kmlrepdest=%%~dpi)
if not exist "%kmlrepdest%thumbs" mkdir "%kmlrepdest%thumbs"
chcp 1252 >nul
echo.
echo Scan de "%kmlrepscan%" pour création des miniatures dans "%kmlrepdest%thumbs\"
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
set kmlfic="%kmlrepdest%%kmlname%.kml"
echo.
echo Scan de "%kmlrepscan%" pour création de %kmlfic%
for /F "delims=*" %%i in ('dir /b /o:n "%kmlrepscan%*.jp*g"') do echo %kmlrepscan%%%~nxi>>"%kmlrepdest%%kmlname%.lst"
chcp 65001 >nul
echo ^<?xml version="1.0" encoding="UTF-8"?^>>%kmlfic%
echo ^<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom"^>>>%kmlfic%
echo ^<Folder^>>>%kmlfic%
echo ^<name^>%kmlname%^</name^>>>%kmlfic%
"C:\Program Files (x86)\ExifTool\exiftool.exe" -createdate -gpslatitude -gpslongitude -ifd0:orientation -filename -d "%%d/%%m/%%Y %%H:%%M:%%S" -c "%%+.6f" -f -args -charset filename=Latin -charset EXIF=UTF8 -@ "%kmlrepdest%%kmlname%.lst" >"%kmlrepdest%%kmlname%.exif"
echo ^<description^>^<^^![CDATA[Images du rÃ©pertoire %kmlrepscan%]]^>^</description^>>>%kmlfic%
set kmlnbim=0
set kmlnbimsgps=0
set kmlnbimsdate=0
set kmlviewer=%kmlrepdest%viewer.htm
if not exist "%kmlviewer%" copy "%~dp0viewer.htm" "%kmlviewer%">nul
set kmlviewer=%kmlviewer:\=/%
for /F "usebackq tokens=1,2 delims==" %%i in ("%kmlrepdest%%kmlname%.exif") do (
if /I "%%i"=="-CreateDate" set kmldate=%%j
if /I "%%i"=="-GPSLatitude" set kmllatitude=%%j
if /I "%%i"=="-GPSLongitude" set kmllongitude=%%j
if /I "%%i"=="-Orientation" set kmlorientation=%%j
if /I "%%i"=="-Filename" (
set /A kmlnbim=!kmlnbim!+1
set kmldate=!kmlDate:~0,19!
set kmlorientation=!kmlorientation:~0,-1!
if /I "!kmlorientation!"=="Rotate 18" (set kmlorientation=!kmlorientation!0) else (set kmlorientation=!kmlorientation:~0,-2!)
for /F "delims=*" %%k in ("%%j") do set kmlimgnom=%%~nj
if not "!kmllatitude!"=="" (
if not "!kmllongitude!"=="" (
if "!kmldate!"=="-" (
set /A kmlnbimsdate=!kmlnbimsdate!+1
echo Traitement de %%j -^> intÃ©grÃ©e sans donnÃ©es de date de crÃ©ation) else echo Traitement de %%j
set kmlurl=file:///%kmlrepscan%%%j
set kmlurl=!kmlurl:\=/!
echo ^<Placemark^>>>%kmlfic%
echo ^<name^>!kmlimgnom!^</name^>>>%kmlfic%
echo ^<description^>>>%kmlfic%
echo ^<^^![CDATA[^<div style="float:left;width:200px;height:1.2em;overflow:hidden;"^>^<b^>%kmlname%^</b^>^</div^>^<div style="float:right;padding-top:0.2em;font-size:0.8em;"^>!kmldate!^</div^>^<br/^>^<hr/^>>>%kmlfic%
echo ^<b^>Lat: ^</b^>^<code^>!kmllatitude!^</code^>, ^<b^>Lon: ^</b^>^<code^>!kmllongitude!^</code^>^<br/^>^<br/^>>>%kmlfic%
echo ^<div style="width:308px;height:200px;"^>>>%kmlfic%
if /I "!kmlorientation!"=="Rotate 90" (
echo ^<img src="!kmlurl!" style="max-width:200px;max-height:300px;-webkit-transform:rotate(90deg) translate(0px,-100%%);-webkit-transform-origin:top left;"/^>^</div^>^<br/^>>>%kmlfic%
) else if "!kmlorientation!"=="Rotate 270" (
echo ^<img src="!kmlurl!" style="max-width:200px;max-height:300px;-webkit-transform:rotate(270deg) translate(-100%%,0px);-webkit-transform-origin:top left;"/^>^</div^>^<br/^>>>%kmlfic%
) else if "!kmlorientation!"=="Rotate 180" (
echo ^<img src="!kmlurl!" style="max-width:300px;max-height:200px;-webkit-transform:rotate(180deg) translate(-100%%,-100%%);-webkit-transform-origin:top left;"/^>^</div^>^<br/^>>>%kmlfic%
) else (echo ^<img src="!kmlurl!" style="max-width:300px;max-height:200px;"/^>^</div^>^<br/^>>>%kmlfic%)
echo ^<div style="width:300px;"^>^<b^>Nom: ^</b^>^<a href="" id="lien"^>!kmlimgnom!^</a^>^</div^>^<hr/^>>>%kmlfic%
echo ^<script^>>>%kmlfic%
echo var p="!kmlurl!";>>%kmlfic%
echo p=encodeURIComponent^(p^);>>%kmlfic%
echo p=p.replace^(/%%/g,"*"^);>>%kmlfic%
if /I "!kmlorientation!"=="Rotate 90" (
echo p="1"+p;>>%kmlfic%) else if "!kmlorientation!"=="Rotate 270" (
echo p="2"+p;>>%kmlfic%) else if "!kmlorientation!"=="Rotate 180" (
echo p="3"+p;>>%kmlfic%) else (echo p="0"+p;>>%kmlfic%)
echo document.getElementById^("lien"^).href="file:///%kmlviewer%#"+p;>>%kmlfic%
echo ^</script^>]]^>>>%kmlfic%
echo ^</description^>>>%kmlfic%
echo ^<Style^>>>%kmlfic%
echo ^<IconStyle^>>>%kmlfic%
echo ^<scale^>2.2^</scale^>>>%kmlfic%
echo ^<Icon^>^<href^>file:///%kmlrepdest%thumbs/%kmlname% - !kmlimgnom!.jpg^</href^>^</Icon^>>>%kmlfic%
echo ^</IconStyle^>>>%kmlfic%
echo ^<LabelStyle^>>>%kmlfic%
echo ^<scale^>0.7^</scale^>>>%kmlfic%
echo ^</LabelStyle^>>>%kmlfic%
echo ^<BalloonStyle^>>>%kmlfic%
echo ^<bgColor^>ff000000^</bgColor^>>>%kmlfic%
echo ^<textColor^>ffaaaaaa^</textColor^>>>%kmlfic%
echo ^<text^>^<^^![CDATA[$[description]^<br/^>$[geDirections]]]^>^</text^>>>%kmlfic%
echo ^</BalloonStyle^>>>%kmlfic%
echo ^</Style^>>>%kmlfic%
echo ^<Point^>>>%kmlfic%
echo ^<coordinates^>!kmllongitude!,!kmllatitude!,0^</coordinates^>>>%kmlfic%
echo ^</Point^>>>%kmlfic%
echo ^</Placemark^>>>%kmlfic%
) else (
set /A kmlnbimsgps=!kmlnbimsgps!+1
echo Traitement de %%j -^> ignorÃ©e ^(pas de donnÃ©es de gÃ©olocalisation^))) else (
set /A kmlnbimsgps=!kmlnbimsgps!+1
echo Traitement de %%j -^> ignorÃ©e ^(pas de donnÃ©es de gÃ©olocalisation^))
)
)
echo ^</Folder^>>>%kmlfic%
echo ^</kml^>>>%kmlfic%
del "%kmlrepdest%%kmlname%.lst"
del "%kmlrepdest%%kmlname%.exif"
if %kmlnbimsgps%==0 (
if %kmlnbimsdate%==0 (
echo %kmlnbim% image^(s^) traitÃ©e^(s^)
if "%~3"=="exit" if %kmltherr%==0 (
chcp 850 >nul
endlocal
echo on
@exit)) else (
echo %kmlnbim% image^(s^) traitÃ©e^(s^) dont
echo   %kmlnbimsdate% image^(s^) intÃ©grÃ©e^(s^) sans donnÃ©es de date de crÃ©ation
)) else (
echo %kmlnbim% image^(s^) traitÃ©e^(s^) dont
if not %kmlnbimsdate%==0 echo   %kmlnbimsdate% image^(s^) intÃ©grÃ©e^(s^) sans donnÃ©es de date de crÃ©ation
echo   %kmlnbimsgps% image^(s^) ignorÃ©e^(s^) ^(pas de donnÃ©es de gÃ©olocalisation^))
chcp 850 >nul
endlocal
echo on
