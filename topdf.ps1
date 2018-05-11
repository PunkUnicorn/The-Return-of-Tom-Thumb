write-host "**topdf.ps1**"
Get-Content -Path "Prose - Chapter One1.md" | python spellchecker.py
pandoc --version
pandoc --css epubstyle.css `
  "title.md" `
  "Prose - Chapter One1.md" `
  "Prose - Chapter One2.md" `
  "Prose - Chapter One3.md" `
  -o The-Return-of-Tom-Thumb.epub
