<?php
header('Content-Type: application/octet-stream');
// This "fakes" the file name, so the downloaded file isn't called
// "download_xml_file.php" or whatever you name the script.
header('Content-Disposition: attachment; filename=pdf.pdf');
//readfile('http://www.pdf995.com/samples/pdf.pdf');
exit(readfile('http://www.pdf995.com/samples/pdf.pdf'));
?>