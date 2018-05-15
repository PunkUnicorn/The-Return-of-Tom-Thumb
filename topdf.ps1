write-host "**topdf.ps1**"

#
# Fancy quote solution: 
# https://stackoverflow.com/questions/6968270/replacing-smart-quotes-in-powershell
#
Function Replace-FancyQuotes {
	Process {
		$fancySingleQuotes = "[\u2019\u2018]" 
		$fancyDoubleQuotes = "[\u201C\u201D]" 		
		%{ `
			$_ = `
			[regex]::Replace($_, $fancySingleQuotes, "'")
			[regex]::Replace($_, $fancyDoubleQuotes, '"') `
		}
	}
}

#
# Spellchecks chapter files by filename convension
# Outputs test result messages and all the jazz
#
Function Spellcheck-Chapter($chapterName, $spellingFailFilename) {
	Write-Output ".oO{$chapterName Spelling starts:}"
	
	$chapter = Get-Content -Path "Prose - $chapterName*.md" -Encoding UTF8
	$chapterSpelling = $chapterOne | Replace-FancyQuotes | python spellchecker.py | ConvertFrom-Json | %{ $_.Results } 
	$chapterSpelling | fl; $chapterOneSpelling | fl | Out-File -FilePath $spellingFailFilename -Append
	$chapterSpelling | %{ Add-AppveyorMessage -Message "$($_.Word) - $chapterName" -Details "$($_.Hint)" -Category "Error" }
	$chapterSpelling | %{ Add-AppveyorTest -Name "$($_.Word) - Spelling" -Framework NUnit -Filename "$($_.Hint)" -ErrorMessage "$($_.Word)? $($_.Hint)" -Outcome "$($_.Status)" }

	$spellingResults = $null;
	$spellingResults = Get-Content -Path $spellingFailFilename 
	If ($spellingResults -eq $null)
	{
		Add-AppveyorTest -Name "Spelling" -Framework NUnit -Filename $chapterName -ErrorMessage "All passed" -Outcome "Passed"
		Write-Output "No spelling errors"
	}
	
	Write-Output ".oO{$chapterName Spelling ends!}"
}



# run tests

Write-Output "Spelling Starts" 
Write-Output "Spelling Exceptions start:"
Get-Content -Path "spellchecker.exceptions.txt" | Write-Output
Write-Output "Spelling Exceptions end!"
Spellcheck-Chapter("Chapter One", "Chapter-One-Spelling.txt")
Spellcheck-Chapter("Chapter Two", "Chapter-One-Spelling.txt")
Write-Output "Spelling Ends"

$chapterName = "Chapter One"
$wordsFilename = "Chapter-One-Words.txt"
Write-Output "Thesaurunocerous Starts"
Write-Output "$chapterName Thesaurunocerous starts:"
$chapter = Get-Content -Path "Prose - $chapterName*.md" -Encoding UTF8 | Replace-FancyQuotes 
$chapterTheasurus = $chapter | python thesaurunocerous.py | ConvertFrom-Json | %{ $_.Results }
$chapterOneTheasurus | fl
$chapterOneTheasurus | fl | Out-File -FilePath $wordsFilename -Append
$chapterOneTheasurus | %{ Add-AppveyorMessage -Message "$($_.Word) x $($_.Occurs) - $chapterName" -Details "$($_.Hint)" -Category "$($_.Status)" }
Write-Output "$chapterName Thesaurunocerous end!"
Write-Output "Thesaurunocerous Ends"

pandoc --version
pandoc --css epubstyle.css `
  "title.md" `
  "Prose - Chapter One1.md" `
  "Prose - Chapter One2.md" `
  "Prose - Chapter One3.md" `
  "Prose - Chapter Two1.md" `
  -o The-Return-of-Tom-Thumb.epub
