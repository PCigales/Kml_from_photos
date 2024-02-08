@echo off
setlocal enabledelayedexpansion
if "%~1"=="" (set kmlrepscan=%~dp0) else (for /F "delims=" %%i in ("%~1\") do set kmlrepscan=%%~dpi)
if "%~2"=="" (set kmlrepdest=%kmlrepscan%) else (for /F "delims=" %%i in ("%~2\") do set kmlrepdest=%%~dpi)
if not exist "%kmlrepdest%thumbs" mkdir "%kmlrepdest%thumbs"
chcp 1252 >nul
echo.
if exist "%~dp0kmlz-andro.ps1" (
  for %%p in (pwsh.exe) do set kmlps="%%~$PATH:p"
  if !kmlps!=="" (set kmlps=powershell) else (set DOTNET_SYSTEM_GLOBALIZATION_USENLS=1)
  !kmlps! -executionpolicy bypass -file "%~dp0kmlz-andro.ps1" "%kmlrepscan%\" "%kmlrepdest%\" z
  if !ERRORLEVEL! NEQ 0 (
    echo.
    pause
  )
  goto end
)
if exist "%~dp0kmlz-andro.py" (
  call "%~dp0kmlz-andro" "%kmlrepscan%\" "%kmlrepdest%\" z
  if !ERRORLEVEL! NEQ 0 (
    echo.
    pause
  )
  goto end
)
echo Scan de "%kmlrepscan%" pour cr�ation des miniatures dans "%kmlrepdest%thumbs\"
for /F "delims=/" %%i in ("%kmlrepscan:~0,-1%") do set kmlname=%%~ni
if exist "%kmlrepdest%%kmlname%.lst" del "%kmlrepdest%%kmlname%.lst"
set kmlerr=0
for %%i in ("%kmlrepscan%*.jp*g") do if not exist "%kmlrepdest%thumbs\%kmlname% - %%~ni.jpg" echo %%i >>"%kmlrepdest%%kmlname%.lst"
if exist "%kmlrepdest%%kmlname%.lst" (
  if exist "%~dp0resize.ps1" (
    powershell -executionpolicy bypass -file "%~dp0resize.ps1" "%kmlrepdest%%kmlname%.lst" "%kmlrepdest%thumbs\%kmlname%"
  ) else if exist "%~dp0resize.py" (
    call "%~dp0resize" "%kmlrepdest%%kmlname%.lst" "%kmlrepdest%thumbs\%kmlname%"
  ) else (
    "C:\Program Files (x86)\Irfanview\i_view32.exe" /filelist="%kmlrepdest%\%kmlname%.lst" /resize_long=150 /aspectratio /resample /ini="%~dp0" /convert="%kmlrepdest%thumbs\%kmlname% - $N.jpg"
  )
  if !ERRORLEVEL! NEQ 0 (
    set kmlerr=1
    echo Erreur lors de la cr�ation des miniatures
  )
  del "%kmlrepdest%%kmlname%.lst"
)
set kmzfic="%kmlrepdest%%kmlname% - andro.kmz"
set kmlfic="%kmlrepdest%%kmlname% - andro - kmz.kml"
set kmliconpref=thumbs/%kmlname% - 
echo. 2>"%kmlrepdest%%kmlname%.lst"
echo Scan de "%kmlrepscan%" pour cr�ation de %kmlfic%
echo %kmlname% - andro - kmz.kml>"%kmlrepdest%%kmlname% - kmz.lst"
for /F "delims=*" %%i in ('dir /b /o:n "%kmlrepscan%*.jp*g"') do (
echo %kmlrepscan%%%~nxi>>"%kmlrepdest%%kmlname%.lst"
echo thumbs\%kmlname% - %%~ni.jpg>>"%kmlrepdest%%kmlname% - kmz.lst")
chcp 65001 >nul
"C:\Program Files (x86)\ExifTool\exiftool.exe" -createdate -gpslatitude -gpslongitude -filename -d "%%d/%%m/%%Y %%H:%%M:%%S" -c "%%+.6f" -f -args -charset filename=Latin -charset EXIF=UTF8 -@ "%kmlrepdest%%kmlname%.lst" >"%kmlrepdest%%kmlname%.exif"
if !ERRORLEVEL! NEQ 0 (
  set kmlerr=1
  echo Erreur lors de la récupération des métadonnées
)
echo ^<?xml version="1.0" encoding="UTF-8"?^>>%kmlfic%
echo ^<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom"^>>>%kmlfic%
echo ^<Folder^>>>%kmlfic%
echo ^<name^>%kmlname%^</name^>>>%kmlfic%
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
echo ^<^^![CDATA[>>%kmlfic%
echo ^<div style="float:left;width:50%%;height:1.2em;overflow:auto hidden;white-space:nowrap;color:white;"^>^<b^>%kmlname%^</b^>^</div^>>>%kmlfic%
echo ^<div style="float:right;padding-top:0.2em;font-size:0.8em;color:#aaaaaa;"^>$[date]^</div^>^<br/^>^<hr/^>>>%kmlfic%
echo ^<b^>^<font color=#aaaaaa^>Lat: ^</b^>^<code^>$[lat]^</code^>^&nbsp;^&nbsp;^&nbsp;^<b^>Lon: ^</b^>^<code^>$[lon]^</code^>^<br/^>^<br/^>>>%kmlfic%
echo ^<div style="width:94vw;height:62vh;"^>^<a href="http://localhost:8080//Android/data/com.google.earth/files/viewer - andro.htm#$[url]"^>^<img src="$[url]" style="max-width:94vw;max-height:62vh;"/^>^</a^>^</div^>^<br/^>>>%kmlfic%
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
    for /F "delims=*" %%k in ("%%j") do set kmlimgnom=%%~nj
    if "!kmllatitude!"=="" (set kmllatitude=-)
    if "!kmllongitude!"=="" (set kmllongitude=-)
    if not "!kmllatitude!"=="-" (
      if not "!kmllongitude!"=="-" (
        if "!kmldate!"=="-" (
          set /A kmlnbimsdate=!kmlnbimsdate!+1
          echo Traitement de %%j -^> intégrée sans données de date de création
        ) else echo Traitement de %%j
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
        echo ^<Icon^>^<href^>%kmliconpref%!kmlimgnom!.jpg^</href^>^</Icon^>>>%kmlfic%
        echo ^</IconStyle^>>>%kmlfic%
        echo ^</Style^>>>%kmlfic%
        echo ^<Point^>>>%kmlfic%
        echo ^<coordinates^>!kmllongitude!,!kmllatitude!,0^</coordinates^>>>%kmlfic%
        echo ^</Point^>>>%kmlfic%
        echo ^</Placemark^>>>%kmlfic%
      ) else (
        set /A kmlnbimsgps=!kmlnbimsgps!+1
        echo Traitement de %%j -^> ignorée ^(pas de données de géolocalisation^)
      )
    ) else (
      set /A kmlnbimsgps=!kmlnbimsgps!+1
      echo Traitement de %%j -^> ignorée ^(pas de données de géolocalisation^)
    )
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
  pause
)
:end
chcp 850 >nul
endlocal
echo on
@if "%~3"=="exit" @exit