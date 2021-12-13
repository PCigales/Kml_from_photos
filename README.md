# Kml_from_photos
Batches to generate a kml file to display geotagged photos in Google Earth on Windows or Android

It is a set of batch that can be run under Windows to generate a kml file and thumbnails from a folder of geotagged photos, with placemarks and descriptive balloons, that can be imported in Google Earth in order to display the pictures at their respective location on the map. It is possible to open the photo in a bigger window from the balloon by clicking the link with its name under the small view of the photo (or, in Windows, if the option is disabled in settings, by right-clicking the link and clicking "open link").

Installation:
- download ExifTool from https://exiftool.org/, copy the executable in the archive in "C:\Program Files (x86)\ExifTool\" after having created the folder, and rename it from "exiftool(-k).exe" to "exiftool.exe"
- copy "kml.bat", "kml-andro.bat" and "viewer.htm" (and only these files at this stage) in "C:\Users\...\AppData\LocalLow\Google\GoogleEarth" where "..." must be replaced by the name of the account
- either:
  * download from https://www.irfanview.com/ and install IrfanView in "C:\Program Files (x86)\Irfanview\", and copy "i_view32.ini" in "C:\Users\...\AppData\LocalLow\Google\GoogleEarth"
  * or, for faster generation of thumbnails, install Python and Pillow-SIMD (wheels are available at https://www.lfd.uci.edu/~gohlke/pythonlibs/#pillow-simd), and copy "resize.py" in "C:\Users\...\AppData\LocalLow\Google\GoogleEarth"

Usage:
kml FOLDER_WITH_PHOTOS FOLDER_DESTINATION
or
kml-andro FOLDER_WITH_PHOTOS FOLDER_DESTINATION
where FOLDER_WITH_PHOTOS is the folder containing the photos and FOLDER_DESTINATION is the folder where the kml file and the thumbnails will be created
ex: kml "C:\Users\...\Pictures\Holidays\" "C:\Users\...\AppData\LocalLow\Google\GoogleEarth\"

Thumbnails are only generated the first time. If new photos have been added to a folder, just run the command again to create the new thumbnails and update the kml file

Tip: if several folders are to be processed, create in "C:\Users\...\AppData\LocalLow\Google\GoogleEarth" a batch to run in parallel several commands, such as:
start "Creation of KML" /D "%~dp0" call "%~dp0kml.bat" "C:\Users\...\Pictures\Folder1\" "C:\Users\...\AppData\LocalLow\Google\GoogleEarth\" "exit"
start "Creation of KML" /D "%~dp0" call "%~dp0kml.bat" "C:\Users\...\Pictures\Folder2\" "C:\Users\...\AppData\LocalLow\Google\GoogleEarth\" "exit"

To use the thumbnails and the kml files in Google Earth Android:
- install a web server (Tiny Web Server for example) and configure it to serve files on "http://localhost:8080", using "utf-8" charset, from the internal simulated or external SD Card root (photos are supposed to be in the "Picture" folder of this location, otherwise, change it in the script)
- create in "/Android/data/" on the same location the directory tree "com.google.earth/files/thumbs/"
- copy the thumbnails in "/Android/data/com.google.earth/files/thumbs/"
- copy the kml files with "- andro" in their name in "/Android/data/com.google.earth/files/"
- load the kml files in Google Earth from the application or through a file explorer
