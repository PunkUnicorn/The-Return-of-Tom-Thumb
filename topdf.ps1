write-host "**topdf.ps1**"
# run tests
Write-Output "Chapter One Spelling Motherfucker"
Get-Content -Path "Prose - Chapter One*.md" | python spellchecker.py | %{($d=,$_.Split("!")) | ? $d.count -gt 0 | Select-Object -Property Word, State, Hints | Add-AppveyorTest -Name "Spelling" -Framework NUnit -Filename "$_.Word" -Outcome "$_.State" -ErrorMessage "$_.Hints" }

#foreach{Write-Host $d $_} }

Write-Output "Chapter One Spelling Ends"
pandoc --version
pandoc --css epubstyle.css `
  "title.md" `
  "Prose - Chapter One1.md" `
  "Prose - Chapter One2.md" `
  "Prose - Chapter One3.md" `
  -o The-Return-of-Tom-Thumb.epub
