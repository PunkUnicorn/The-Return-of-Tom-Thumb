write-host "**topdf.ps1**"
Write-Output "Chapter One Spelling Motherfucker"
Get-Content -Path "Prose - Chapter One*.md" | python spellchecker.py
Write-Output "Chapter One Spelling Ends"
Get-Content -Path "Prose - Chapter One*.md" | python spellchecker.py
pandoc --version
pandoc --css epubstyle.css `
  "title.md" `
  "Prose - Chapter One1.md" `
  "Prose - Chapter One2.md" `
  "Prose - Chapter One3.md" `
  -o The-Return-of-Tom-Thumb.epub
