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
	Write-Output "$chapterName Spelling starts:"
	
	$chapter = Get-Content -Path "Prose - $chapterName*.md" -Encoding UTF8 | Replace-FancyQuotes
	$chapterSpelling = $chapterOne | python spellchecker.py | ConvertFrom-Json | %{ $_.Results } 
	$chapterSpelling | fl; 
	$chapterOneSpelling | fl | Out-File -FilePath $spellingFailFilename -Append
	$chapterSpelling | `
		%{ Add-AppveyorMessage `
			-Message "$($_.Word) - $chapterName" `
			-Details "$($_.Hint)" `
			-Category "Error" 
		}
		
	$chapterSpelling | `
		%{ Add-AppveyorTest `
			-Name "$($_.Word) - Spelling" `
			-Framework NUnit `
			-Filename "$($_.Hint)" `
			-ErrorMessage "$($_.Word)? $($_.Hint)" `
			-Outcome "$($_.Status)" 
		}

	$spellingResults = $null;
	$spellingResults = Get-Content -Path $spellingFailFilename 
	If ($spellingResults -eq $null) {
		Add-AppveyorTest `
			-Name "Spelling" `
			-Framework NUnit `
			-Filename $chapterName `
			-ErrorMessage "All passed" `
			-Outcome "Passed"
			
		Write-Output "No spelling errors"
		
	}
	
	Write-Output "$chapterName Spelling ends!"
}

#
# Dumps out the contents of the spellcheck.exceptions.txt file
# I.e. all the words that aren't spellchecked
#
Function Spellchecker-DumpExceptions($chapterName) {
	Write-Output "Spelling Exceptions start:"
	Get-Content -Path "spellchecker.exceptions.txt" | Write-Output
	Write-Output "Spelling Exceptions end!"
}

#
# Thesaurunocerous chapter files by filename convension
# Outputs word stat results messages etc
#
Function Thesaurunocerous-Chapter($chapterName) {
	Write-Output "Thesaurunocerous Starts"
	Write-Output "$chapterName Thesaurunocerous starts:"
	
	$chapter = Get-Content -Path "Prose - $chapterName*.md" -Encoding UTF8 | Replace-FancyQuotes 
	$chapterTheasurus = $chapter | python thesaurunocerous.py | ConvertFrom-Json | %{ $_.Results }
	$chapterTheasurus | fl
	$chapterTheasurus | fl | Out-File -FilePath $wordsFilename -Append
	$chapterTheasurus | `
		%{ Add-AppveyorMessage `
			-Message "$($_.Word) x $($_.Occurs) - $chapterName" `
			-Details "$($_.Hint)" `
			-Category "$($_.Status)" 
		}
	
	Write-Output "$chapterName Thesaurunocerous end!"
	Write-Output "Thesaurunocerous Ends"
}

# run tests
Write-Output "Spelling Starts" 
Spellcheck-DumpExceptions
Spellcheck-Chapter "Chapter One" "Chapter-One-Spelling.txt" 
Spellcheck-Chapter "Chapter Two" "Chapter-Two-Spelling.txt"
Write-Output "Spelling Ends"

# word analasys
Write-Output "Thesaurunocerous Starts"
Thesaurunocerous-Chapter "Chapter One" "Chapter-One-Words.txt"
Write-Output "Thesaurunocerous Ends"

pandoc --version
pandoc --css epubstyle.css `
  "title.md" `
  "Prose - Chapter One1.md" `
  "Prose - Chapter One2.md" `
  "Prose - Chapter One3.md" `
  -o The-Return-of-Tom-Thumb.epub
