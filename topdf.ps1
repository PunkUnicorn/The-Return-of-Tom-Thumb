import-module .\posh\PDFTools.psm1
$path=the_return_of_tom_thumb.pdf
if([System.IO.File]::Exists($path)){
    rm $path
}
ls -r|out-ptspdf $path