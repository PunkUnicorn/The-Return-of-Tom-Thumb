import-module .\_toolz\posh\PDFTools.psm1
$path='..\The-Return-of-Tom-Thumb.pdf'
ls -r|out-ptspdf $path -force
if(![System.IO.File]::Exists($path)){
    throw [System.IO.FileNotFoundException] "$path not found.";
}