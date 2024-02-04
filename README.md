# Kml_from_photos
Batches to generate a kml or a kmz file to display geotagged photos in Google Earth on Windows or Android

It is a set of batches that can be run under Windows to generate a kml file and thumbnails, or a kmz file embedding the thumbnails, from a folder of geotagged photos, with placemarks and descriptive balloons, that can be imported in Google Earth in order to display the pictures at their respective location on the map. It is possible to open the photo in a bigger window from the balloon by, in Windows, clicking the link with its name under the small view of the photo (or if the option is disabled in settings, by right-clicking the link and clicking "open link"), and in Android, by touching either the link or, to open the viewer with more interaction features (such as fullscreen through double-tap), the photo.

Installation:
- for use in Google Earth Desktop, copy "kml.bat" (generation of kml file) and/or "kmz.bat" (generation of kmz file) and "viewer.htm" (and only these files at this stage) in "C:\Users\\...\AppData\LocalLow\Google\GoogleEarth" where "..." must be replaced by the name of the account
- for use in Google Earth Android, copy "kml-andro.bat" (generation of kml file) and/or "kmz-andro.bat" (generation of kmz file) (and only these files at this stage) in "C:\Users\\...\AppData\LocalLow\Google\GoogleEarth" where "..." must be replaced by the name of the account
- option 1 = use Windows Presentation Foundation for thumbnail generation and metadata extraction (recommended, requires Windows Powershell 5 installed by default with Windows >=7, or, a bit faster, Powershell >=7 that needs to be installed through amongst several ways "winget install --id Microsoft.Powershell --source winget"): copy "kmlz.ps1" (for use in Google Earth Desktop) and/or "kmlz-andro.ps1" (for use in Google Earth Android) in "C:\Users\\...\AppData\LocalLow\Google\GoogleEarth"
- option 2 = use Windows Presentation Foundation for thumbnail generation and ExifTool for metadata extraction:
  * copy "resize.ps1" in "C:\Users\\...\AppData\LocalLow\Google\GoogleEarth"
  * download ExifTool from https://exiftool.org/, copy the executable in the archive in "C:\Program Files (x86)\ExifTool\" after having created the folder, and rename it from "exiftool(-k).exe" to "exiftool.exe"
- option 3 = use Pillow-SIMD (not actively maintained and wheels no longer available unfortunately) for thumbnail generation and ExifTool for metadata extraction:
  * install Python and Pillow-SIMD, and copy "resize.py" in "C:\Users\\...\AppData\LocalLow\Google\GoogleEarth"
  * download ExifTool from https://exiftool.org/, copy the executable in the archive in "C:\Program Files (x86)\ExifTool\" after having created the folder, and rename it from "exiftool(-k).exe" to "exiftool.exe"
- option 4 = use Irfanview (slow) for thumbnail generation and ExifTool for metadata extraction:
  * download from https://www.irfanview.com/ and install IrfanView 32-bit in "C:\Program Files (x86)\Irfanview\", and copy "i_view32.ini" in "C:\Users\\...\AppData\LocalLow\Google\GoogleEarth" (to use Irfanview 64-bit, install it in "C:\Program Files\Irfanview\", replace "C:\Program Files (x86)\Irfanview\i_view32.exe" by "C:\Program Files\Irfanview\i_view64.exe" in the batches, and rename "i_view32.ini" to "i_view64.ini")
  * download ExifTool from https://exiftool.org/, copy the executable in the archive in "C:\Program Files (x86)\ExifTool\" after having created the folder, and rename it from "exiftool(-k).exe" to "exiftool.exe"

Usage:  
  * kml FOLDER_WITH_PHOTOS FOLDER_DESTINATION  
or  
  * kml-andro FOLDER_WITH_PHOTOS FOLDER_DESTINATION  
or  
  * kmz FOLDER_WITH_PHOTOS FOLDER_DESTINATION  
or  
  * kmz-andro FOLDER_WITH_PHOTOS FOLDER_DESTINATION

where FOLDER_WITH_PHOTOS is the folder containing the photos and FOLDER_DESTINATION is the folder where the kml file and the thumbnails, or the kmz file, will be created  
ex: kml "C:\Users\\...\Pictures\Holidays\" "C:\Users\\...\AppData\LocalLow\Google\GoogleEarth\"

Thumbnails are only generated the first time. If new photos have been added to a folder, just run the command again to create the new thumbnails and update the kml or the kmz file.

Tip: if several folders are to be processed, create in "C:\Users\\...\AppData\LocalLow\Google\GoogleEarth" a batch to run in parallel several commands, such as:  
start "Creation of KML" /D "%~dp0" call "%~dp0kml.bat" "C:\Users\\...\Pictures\Folder1\" "C:\Users\\...\AppData\LocalLow\Google\GoogleEarth\" "exit"  
start "Creation of KML" /D "%~dp0" call "%~dp0kml.bat" "C:\Users\\...\Pictures\Folder2\" "C:\Users\\...\AppData\LocalLow\Google\GoogleEarth\" "exit"  

If the Windows code page differs from cp1252, it may be necessary to change in the batches "chcp 1252" using the appropriate code.

To use the kml files and the thumbnails, or the kmz files, in Google Earth Android:
- install (however, for kmz files, otherwise, pins with thumbnail positioned on the map will still be displayed, but no photo will appear in the balloon) a web server (Tiny Web Server for example) and configure it to serve files on "http://localhost:8080", using "utf-8" charset, from the internal simulated or external SD Card root (photos are supposed to be in the "Picture" folder of this location, otherwise, change it in the script)
- create in "/Android/data/" on the same location the directory tree "com.google.earth/files/thumbs/"
- copy "viewer - andro.htm" in "/Android/data/com.google.earth/files/" to be able to display the photo in full screen from the balloon by touching it
- copy the kml or kmz files with "- andro" in their name in "/Android/data/com.google.earth/files/"
- for the kml files, also copy the thumbnails in "/Android/data/com.google.earth/files/thumbs/"
- load the kml or kmz files in Google Earth from the application or through a file explorer

When shared for use in Google Earth Desktop, to be able to display the original full size photos, the kmz files must be accompanied with "viewer.htm" and these photos.  
On the recipient's computer, "viewer.htm" must be placed in the same folder as the kmz files, and the photos be either placed in a folder with exactly the same path as the one they were inside on the computer on which the batch was run (so that they have the same absolute path), or in the same folder as the kmz files (there obviously must not be several photos with the same file name). It is therefore possible to create an archive file containing the kmz files, "viewer.htm" and the photos, provided their path is not stored, and share it; the recipient will only have to extract its content to a folder and load the kmz files.  
If a kmz file is imported in "My places", "viewer.htm" and the photos must be copied in "C:\Users\\...\AppData\LocalLow\Google\GoogleEarth", as Google Earth does not keep track of the location of the kmz file from which the content has been integrated (the embedded thumbnails will be automatically copied to this same folder when the application is closed).

The script JPEGPS can be used to display and modify the geotag of a JPEG picture (EXIF GPS coordinates), without altering other metadata (it can therefore not create the GPSInfo tag in a photo which is not already geotagged as it would request rewriting the whole EXIF structure).  
ex:  
jpegps "C:\Users\\...\Pictures\Holidays\Sunset.jpg" " -49.5605, 69.4868"  
jpegps "C:\Users\\...\Pictures\Holidays\Sunset.jpg" 49°33'37.8\"S 69°29'12.5\"E
