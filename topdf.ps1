write-host "**topdf.ps1**"

Get-ChildItem -Filter *.md | 
Foreach-Object {
  $filename = Get-Content $_.FullName
  Write-Output $filename
  Get-Content -Path $filename | python spellchecker.py
}

Write-Output "Chapter One Motherfucker"
Get-Content -Path "Prose - Chapter One*.md" | python spellchecker.py


Get-Content -Path "Prose - Chapter One*.md" | python spellchecker.py
pandoc --version
pandoc --css epubstyle.css `
  "title.md" `
  "Prose - Chapter One1.md" `
  "Prose - Chapter One2.md" `
  "Prose - Chapter One3.md" `
  -o The-Return-of-Tom-Thumb.epub
