write-host "**topdf.ps1**"
# run tests
Write-Output "Chapter One Spelling Motherfucker"
Get-Content -Path "Prose - Chapter One*.md" | python spellchecker.py | fl# | %{,$_.Split("!") | fl $_ }

##Add-AppveyorTest -Name "Spelling" -Framework NUnit -Filename -ErrorMessage
#foreach{Write-Host $_} }

Write-Output "Chapter One Spelling Ends"
pandoc --version
pandoc --css epubstyle.css `
  "title.md" `
  "Prose - Chapter One1.md" `
  "Prose - Chapter One2.md" `
  "Prose - Chapter One3.md" `
  -o The-Return-of-Tom-Thumb.epub
