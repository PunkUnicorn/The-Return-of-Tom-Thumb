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
# Destroy quotes:
#
Function Destroy-Quotes {
	Process {
		$fancySingleQuotes = "[\u2019\u2018]" 
		$fancyDoubleQuotes = "[\u201C\u201D]" 		
		%{ `
			$_ = `
			[regex]::Replace($_, $fancySingleQuotes, " ")
			[regex]::Replace($_, $fancyDoubleQuotes, ' ') `
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
	
	$chapterSpelling | Out-File -FilePath $spellingFailFilename -Append
	
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

	If ($chapterSpelling.Length -eq 0) {
		Add-AppveyorTest `
			-Name "Spelling $chapterName" `
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
Function Spellcheck-DumpExceptions() {
	Write-Output "Spelling Exceptions start:"
	Get-Content -Path "spellchecker.exceptions.txt" | Write-Output
	Write-Output "Spelling Exceptions end!"
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
	WordAnalysis-Chapter $chapterName | Out-File wordsFilename -Append
	Write-Output "$chapterName Thesaurunocerous end!"	
}	
	

# run tests
Get-Content -Path "./RedRidingHood/ASCII_RED.txt" -Encoding UTF8 
Write-Output "Spelling Starts" 
Spellcheck-DumpExceptions
Spellcheck-Chapter "Chapter One" "Chapter-One-Spelling.txt" 
Spellcheck-Chapter "Chapter Two" "Chapter-Two-Spelling.txt"
Write-Output "Spelling Ends"

Write-Output "Thesaurunocerous Starts"
Thesaurunocerous-Chapter "Chapter One" "Chapter-One-Words.txt"
Thesaurunocerous-Chapter "Chapter Two" "Chapter-Two-Words.txt"
Write-Output "Thesaurunocerous Ends"


# Make the book
Get-Content -Path ".\TheTailor\the-tailor.txt" -Encoding UTF8 
pandoc --version
unzip -h
lame --help
sox -h

#
# I used to think pandoc got upset with chapter two at the top of a new file
# I used to think pandoc really really likes a blank line at the end!!! It can be funny on some readers without
# I'm not really sure about this any more. With the blank line, and all my mitigating measures it still goes funny on my out the box iPad book app
# I think it might be the iPad book app. Other readers seem to find it ok.
#
Write-output `n | Out-File "Prose - Blank line.md" -Append

Write-Output "Adding build version to title.md..."
cat title.md, "Prose - Blank line.md" | sc title2.md
#Add-Content -Path "title.md" -Value $env:APPVEYOR_BUILD_NUMBER
cat title2.md, "Prose - Blank line.md" | sc title3.md
Add-Content -Path "title3.md" -Value $env:APPVEYOR_BUILD_VERSION
Write-Output "Adding build version to title.md FINISHED"

Write-Output "Combining markdown..."
cat "title3.md", 
	"Prose - Chapter One1.md", 
	"Prose - Blank line.md",
	"Prose - Chapter One2.md",
	"Prose - Blank line.md",
	"Prose - Chapter One3.md", 
	"Prose - Blank line.md",
	"Prose - Chapter Two1.md", 
	"Prose - Blank line.md" | sc "The-Return-of-Tom-Thumb.md" 
	
Get-Content "The-Return-of-Tom-Thumb.md" -Encoding UTF8 | Replace-FancyQuotes | Out-File "The-Return-of-Tom-Thumb.txt" -Encoding UTF8 -Append
Write-Output "...The-Return-of-Tom-Thumb.md and The-Return-of-Tom-Thumb.txt created"
Write-Output "Combining markdown FINISHED"

Write-Output "Creating books..."
pandoc --css epubstyle.css `
  "title3.md" `
  "The-Return-of-Tom-Thumb.md" `
  -o The-Return-of-Tom-Thumb.epub
Write-Output "... made The-Return-of-Tom-Thumb.epub..."

pandoc --css epubstyle.css `
  "title3.md" `
  "The-Return-of-Tom-Thumb.txt" `
  -o The-Return-of-Tom-Thumb.html
Write-Output "... made The-Return-of-Tom-Thumb.html..."


# Make the audio book (WIP)
Write-Output "Making Audio book ..."
Get-Content -Path "The-Return-of-Tom-Thumb.txt" -Encoding UTF8 | `
	Destroy-Quotes | `
	%{ $_.Replace("%", "`n").Replace("<sub>","").Replace("</sub>", "") } >> gTTS_word_input.txt
Write-Output "... made gTTS_word_input.txt"

cat gTTS_word_input.txt | python .\googleTextToSpeech.py -o The-Return-of-Tom-Thumb.mp3 -d The-Return-of-Tom-Thumb.mp3.log
Write-Output "... made The-Return-of-Tom-Thumb.mp3 and The-Return-of-Tom-Thumb.mp3.log"

#
# Add a backing track to the audio book
#
Write-Output "Making audio book with soundtrack..."
lame --decode .\Music\natural-reader-soundtrack.mp3 natural-reader-soundtrack.wav  --silent
Write-Output "... made natural-reader-soundtrack.wav"

lame natural-reader-soundtrack.wav -m m natural-reader-soundtrack-mono.pcm --silent
Write-Output "... made natural-reader-soundtrack.pcm (previously wav)"

lame --decode The-Return-of-Tom-Thumb.mp3 The-Return-of-Tom-Thumb.wav --silent
Write-Output "... made The-Return-of-Tom-Thumb.wav"

copy .\Music\natural-reader-soundtrack.mp3 tRoTT-with-music.mp3 # default result if next step fails
Write-Output "... made default upload artifact (backing track with no voice) tRoTT-with-music.mp3"

sox -m natural-reader-soundtrack-mono.pcm The-Return-of-Tom-Thumb.wav tRoTT-with-music.wav -q 
Write-Output "... made sox mix of tRoTT-with-music.wav"

lame -f tRoTT-with-music.wav tRoTT-with-music.mp3 --silent
Write-Output "... made proper tRoTT-with-music.mp3"

#
# Debug google text to speech, to see how words sound (reads contents of gTTS_debug.txt and makes an mp3 debug artifact)
#
Get-Content -Path "gTTS_debug.txt" -Encoding UTF8 | Destroy-Quotes >test1.txt
cat test1.txt | python .\googleTextToSpeech.py -o testymctestface.mp3

Write-Output "... made The-Return-of-Tom-Thumb.mp3 and The-Return-of-Tom-Thumb.mp3.log..."

Write-Output "Creating books FINISHED"

Write-Output "Whole darn lot Finished!"
