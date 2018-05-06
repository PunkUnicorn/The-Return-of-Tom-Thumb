import-module .\_toolz\posh\PDFTools.psm1
$path='..\The-Return-of-Tom-Thumb.pdf'
ls -r|out-ptspdf $path -force
gci -r *.pdf