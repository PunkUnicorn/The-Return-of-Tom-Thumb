write-host "**topdf.ps1**"
# run tests
Write-Output "Chapter One Spelling Boom" #Add as test fails, and to the message window as errors
$chapterOneSpelling = Get-Content -Path "Prose - Chapter One*.md" | python spellchecker.py | ConvertFrom-Json | %{ $_.Results } 
$chapterOneSpelling | fl
$chapterOneSpelling | fl | Out-File -FilePath "Chapter-One-Spelling.txt" -Append
$chapterOneSpelling | %{ Add-AppveyorMessage -Message "$($_.Word) - Chapter One - Spelling" -Details "$($_.Hint)" -Category "Error" }
$chapterOneSpelling | %{ Add-AppveyorTest -Name "$($_.Word) - Spelling" -Framework NUnit -Filename "$($_.Hint)" -ErrorMessage "$($_.Word)? $($_.Hint)" -Outcome "$($_.Status)" }
Write-Output "Chapter One Spelling Ends"
Write-Output "Chapter One Thesaurunocerous Boom" #Only add to the messages window
$chapterOneTheasurus = Get-Content -Path "Prose - Chapter One*.md" | python thesaurunocerous.py | ConvertFrom-Json | %{ $_.Results }
$chapterOneTheasurus | fl
$chapterOneTheasurus | fl | Out-File -FilePath "Chapter-One-Words.txt" -Append
$chapterOneTheasurus | %{ Add-AppveyorMessage -Message "$($_.Word)$(if ( $($_.Occurs) -gt '0' ){$(" x ");$($_.Occurs)} ) - Chapter One - Thesaurunocerous" -Details "$($_.Hint)" -Category "$($_.Status)" }
Write-Output "Chapter One Thesaurunocerous Ends"
pandoc --version
pandoc --css epubstyle.css `
  "title.md" `
  "Prose - Chapter One1.md" `
  "Prose - Chapter One2.md" `
  "Prose - Chapter One3.md" `
  -o The-Return-of-Tom-Thumb.epub
