write-host "**topdf.ps1**"
# run tests

#Add-AppveyorMessage -Message "Yo dawg" -Details "Boomshanka" -Category "Information" #Information | Warning | Error
#Add-AppveyorTest -Name "Argh Mateys" -Framework NUnit -Filename "suddently" -ErrorMessage "suggest: two or too or to or 2" -Outcome "Failed" #Passed, Failed, Ignored, Skipped, Inconclusive, NotFound, Cancelled, NotRunnable

Write-Output "Chapter One Spelling Boom" #Add as test fails, and to the message window as errors
Get-Content -Path "Prose - Chapter One*.md" | python spellchecker.py | ConvertFrom-Json | %{ $_.Results } | fl
Get-Content -Path "Prose - Chapter One*.md" | python spellchecker.py | ConvertFrom-Json | %{ $_.Results } | Add-AppveyorMessage -Message "Chapter One - $($_.Word)" -Details "$($_.Hint)" -Category "$($_.Status)"
Get-Content -Path "Prose - Chapter One*.md" | python spellchecker.py | ConvertFrom-Json | %{ $_.Results } | %{ Add-AppveyorTest -Name "Spelling" -Framework NUnit -Filename "Chapter One - $($_.Word)" -ErrorMessage "$($_.Hint)" -Outcome "$($_.Status)" }
Write-Output "Chapter One Spelling Ends"
Write-Output "Chapter One Thesaurunocerous Boom" #Only add to the messages window
Get-Content -Path "Prose - Chapter One*.md" | python thesaurunocerous.py | ConvertFrom-Json | %{ $_.Results } | fl
Get-Content -Path "Prose - Chapter One*.md" | python thesaurunocerous.py | ConvertFrom-Json | %{ $_.Results } | %{ Add-AppveyorMessage -Message "Chapter One - $($_.Word)" -Details "$($_.Hint)" -Category "$($_.Status)" }
Write-Output "Chapter One Thesaurunocerous Ends"
pandoc --version
pandoc --css epubstyle.css `
  "title.md" `
  "Prose - Chapter One1.md" `
  "Prose - Chapter One2.md" `
  "Prose - Chapter One3.md" `
  -o The-Return-of-Tom-Thumb.epub
