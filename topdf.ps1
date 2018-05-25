write-host "**topdf.ps1**"

Get-Content -Path "./RedRidingHood/ASCII_RED.txt" -Encoding UTF8 

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
# Destroy quotes:
#
Function Destroy-Quotes {
	Process {
		$singleQuotes = "[\u2019\u2018']" 
		$doubleQuotes = '[\u201C\u201D"]'
		%{ `
			$_ = `
			#[regex]::Replace($_, $singleQuotes, " ")
			[regex]::Replace($_, $doubleQuotes, ' ') ` 
		}
	}
}

# Spellchecks chapter files by filename convention
# Outputs test result messages and all the jazz
#
Function Spellcheck-Chapter($chapterName, $spellingFailFilename) {
	Write-Output "$chapterName Spelling starts:"
	
	$chapter = Get-Content -Path "Prose - $chapterName*.md" -Encoding UTF8
	$chapterSpelling = $chapter | Replace-FancyQuotes | python spellchecker.py | ConvertFrom-Csv
	$chapterSpelling 
	
	,$chapterSpelling  | Where {$_.Length -gt 0 } | ForEach { $_ } | Out-File -FilePath $spellingFailFilename -Append
	
	$chapterSpelling | `
		%{ Add-AppveyorTest `
			-Name "$($_.Word) - Spelling $chapterName" `
			-Framework NUnit `
			-Filename "$($_.Hint)" `
			-ErrorMessage "$($_.Word)? $($_.Hint)" `
			-Outcome "Failed" 
		}

	$chapterSpelling  | `
		%{ Add-AppveyorMessage `
			-Message "$($_.Word) - $chapterName" `
			-Details "$($_.Hint)" `
			-Category "Error" 
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

#`
# Dumps out the contents of the spellcheck.exceptions.txt file
# I.e. all the words that aren't spellchecked
#
Function Spellcheck-DumpExceptions() {
	Write-Output "Spelling Exceptions start:"
	Get-Content -Path "spellchecker.exceptions.txt" | Write-Output
	Write-Output "Spelling Exceptions end!"
}

#
# Thesaurunocerous chapter files by filename convention
# Outputs word stat results messages etc
#
Function Thesaurunocerous-Chapter($chapterName, $wordsFilename) {
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
}	
	
#
# Word analysis chapter files by filename convention
# Outputs word stats for files
#
Function WordAnalysis-Chapter($chapterName) {
	# $chapterName = "Chapter One"
	Write-Output "$chapterName WordAnalysis starts:"	
	$chapterContent = Get-Content -Path "Prose - $chapterName*.md" -Encoding UTF8 | Replace-FancyQuotes 
	$chapterWordCount = $chapterContent | python wordcounter.py | ConvertFrom-Csv 
	# Four columns: Word, Length, Count, Percent: 
	# - Word is the word
	# - Length is it's length of characters 
	# - Count is it's number of occurances in the chapter
	# - Percent is it's percent occurance in the chapter
	$chapterWordCount | `
		Where { $_.Count -gt 1 } | `
		Where { $_.Length -gt 2 }	
	$chapterWordCount | Measure-Object Count -Sum -Maximum | Select -Property `
		@{Label="Unique word count";Expression={$_.Count}}, 
		@{label="Word count";Expression={$_.Sum}}, 
		@{label="Maximum occurrence of any word";Expression={$_.Maximum}} | fl
	$chapterWordHints = $chapterWordCount | `
		Where { $_.Count -gt 1 } | `
		Where { $_.Length -gt 2 } | `
		foreach { $_.Word } | `
		python theasaurus.py | ` #`
		ConvertFrom-Csv
	Write-Output $chapterWordHints 
	Write-Output "$chapterName WordAnalysis ends!"
}


# run tests
Write-Output "Spelling Starts" 
Spellcheck-DumpExceptions
Spellcheck-Chapter "Chapter One" "Chapter-One-Spelling.txt" 
Spellcheck-Chapter "Chapter Two" "Chapter-Two-Spelling.txt"
Write-Output "Spelling Ends"

# word counts and Thesaurus
Write-Output "Thesaurunocerous Starts"
Thesaurunocerous-Chapter "Chapter One" "Chapter-One-Words.txt"
Write-Output "Thesaurunocerous Ends"

# word analysis
WordAnalysis-Chapter "Chapter One" | Out-File "Chapter-One-Words.txt" -Append

# Make the book
#
# pandoc seems to get upset with chapter two at the top of a new file
# pandoc really really likes a blank line at the end!!! It can be funny on some readers without
#
Write-Output "Combining files ..."
Write-output `n | Out-File "Prose - Blank line.md" -Append
cat "Prose - Chapter One1.md", 
		"Prose - Chapter One2.md", 
		"Prose - Chapter One3.md", 
		"Prose - Chapter Two1.md", 
		"Prose - Blank line.md" | sc "The-Return-of-Tom-Thumb.md" 
Get-Content "The-Return-of-Tom-Thumb.md" -Encoding UTF8 | Replace-FancyQuotes | Out-File "The-Return-of-Tom-Thumb.txt" -Encoding UTF8 -Append
Write-Output "...The-Return-of-Tom-Thumb.md and The-Return-of-Tom-Thumb.txt created"

Write-Output "Combining books ..."
pandoc --version
pandoc --css epubstyle.css `
  "title.md" `
  "The-Return-of-Tom-Thumb.md" `
  -o The-Return-of-Tom-Thumb.epub
Write-Output "... made The-Return-of-Tom-Thumb.epub..."

#html version
pandoc --css epubstyle.css `
  "title.md" `
  "The-Return-of-Tom-Thumb.txt" `
  -o The-Return-of-Tom-Thumb.html
Write-Output "... made The-Return-of-Tom-Thumb.html..."
	
# Make the audio book (WIP)
Get-Content -Path "The-Return-of-Tom-Thumb.txt" -Encoding UTF8 | Destroy-Quotes >test1.txt
cat test1.txt | python .\googleTextToSpeech.py -o The-Return-of-Tom-Thumb.mp3 -d The-Return-of-Tom-Thumb.mp3.log
Write-Output "... made The-Return-of-Tom-Thumb.mp3 and The-Return-of-Tom-Thumb.mp3.log..."

#Get-Content -Path "gTTS_debug.txt" -Encoding UTF8 | Destroy-Quotes >test2.txt
cat gTTS_debug.txt | python .\googleTextToSpeech.py -o testymctestface.mp3 -d The-Return-of-Tom-Thumb.mp3.log

Write-Output "Finished!"
Write-Output "woos awesum YO'UR AWSUM"
