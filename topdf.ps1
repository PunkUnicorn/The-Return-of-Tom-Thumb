write-host "**topdf.ps1**"
# run tests
Add-AppveyorMessage -Message "Matthew is cool" -Details "Hint" -Category "Error" #Information | Warning | Error
Add-AppveyorTest -Name "Spelling" -Framework NUnit -Filename "Word" -ErrorMessage "Hint" -Outcome "Failed" #Passed, Failed, Ignored, Skipped, Inconclusive, NotFound, Cancelled, NotRunnable
Write-Output "Chapter One Spelling Motherfucker"
Get-Content -Path "Prose - Chapter One*.md" | python spellchecker.py | fl  #Add-AppveyorTest -Name "Spelling" -Framework NUnit -Filename -ErrorMessage
Write-Output "Chapter One Spelling Ends"
Write-Output "Chapter One Thesaurunocerous Boom (sorry takes a while to download)"
Get-Content -Path "Prose - Chapter One*.md" | python thesaurunocerous.py | fl 
Write-Output "Chapter One Thesaurunocerous Ends"
pandoc --version
pandoc --css epubstyle.css `
  "title.md" `
  "Prose - Chapter One1.md" `
  "Prose - Chapter One2.md" `
  "Prose - Chapter One3.md" `
  -o The-Return-of-Tom-Thumb.epub
