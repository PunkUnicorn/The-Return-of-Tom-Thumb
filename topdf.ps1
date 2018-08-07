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
	$chapterSpelling = $chapter | `
		Replace-FancyQuotes | `
		%{ $_.Replace("%", "`n").Replace("<sub>","").Replace("</sub>", "") } | `
		python spellchecker.py | `
		ConvertFrom-Csv
		
	Write-Output $chapterSpelling 
	
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
	Write-Output "$chapterName Word Analysis starts:"	
	
	$chapterContent = Get-Content -Path "Prose - $chapterName*.md" -Encoding UTF8 | Replace-FancyQuotes 
	
	$chapterWordCount = $chapterContent | python wordcounter.py | ConvertFrom-Csv 
	# Four columns: Word, Length, Count, Percent: 
	# - Word is the word
	# - Length is it's length of characters 
	# - Count is it's number of occurrences in the chapter
	# - Percent is it's percent occurrence in the chapter

	$smallWords = $chapterWordCount | `
		Where { $_.Count -lt 2 } | `
		Where { $_.Length -lt 3 }

	$bigWords = $chapterWordCount | `
		Where { $_.Count -gt 1 } | `
		Where { $_.Length -gt 2 }

	$chapterWordCount | Measure-Object Count -Sum -Maximum | Select -Property `
		@{Label="Unique word count";Expression={$_.Count}}, 
		@{label="Word count";Expression={$_.Sum}}, 
		@{label="Maximum occurrence of any word";Expression={$_.Maximum}} | fl
		
	$chapterWordHints = $bigWords | `
		foreach { $_.Word } | `
		python theasaurus.py | ` 
		ConvertFrom-Csv
	
	
	
	# JASON HULP! ADD $chapterWordCount to $bigWords!!! SO KNOW WORD COUNT WITH SYNONYM LOOKUP??? 
	# wut $hintsWithCount = $bigWords | Add-Member 
	
	
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
	#$chapterTheasurus | fl
	#$chapterTheasurus | fl | Out-File -FilePath $wordsFilename -Append
	$chapterTheasurus | `
		%{ Add-AppveyorMessage `
			-Message "$($_.Word) x $($_.Occurs) - $chapterName" `
			-Details "$($_.Hint)" `
			-Category "$($_.Status)" 
		}	
		
	WordAnalysis-Chapter $chapterName | Out-File $wordsFilename -Append
	#Write-Output "$chapterName Thesaurunocerous end!"	
}	
	

# run tests
Get-Content -Path "./RedRidingHood/ASCII_RED.txt" -Encoding UTF8 
Write-Output "Spelling Starts" 
Spellcheck-DumpExceptions
Spellcheck-Chapter "Chapter One" "Chapter-One-Spelling.txt" 
Spellcheck-Chapter "Chapter Two" "Chapter-Two-Spelling.txt"
Spellcheck-Chapter "Chapter Three" "Chapter-Three-Spelling.txt"
Spellcheck-Chapter "Chapter Four" "Chapter-Four-Spelling.txt"
Write-Output "Spelling Ends"

Write-Output "Thesaurunocerous Starts"
Thesaurunocerous-Chapter "Chapter One" "Chapter-One-Words.txt"
Thesaurunocerous-Chapter "Chapter Two" "Chapter-Two-Words.txt"
Thesaurunocerous-Chapter "Chapter Three" "Chapter-Three-Words.txt"
Thesaurunocerous-Chapter "Chapter Four" "Chapter-Four-Words.txt"

Thesaurunocerous-Chapter "Chapter *" "Chapter-All-Words.txt"

# something for the colsole
WordAnalysis-Chapter "Chapter *"

Write-Output "Thesaurunocerous Ends"


# Make the book
Get-Content -Path ".\TheTailor\the-tailor.txt" -Encoding UTF8 
Write-Output "`n`nIntroducing ... pandoc!`n"
pandoc --version
Write-Output "`n`nIntroducing ... lame!`n"
lame --help
Write-Output "`n`nIntroducing ... sox!`n"
sox -h
Write-Output "`n`nIntroducing ... soxi!`n"
soxi

#
# I used to think pandoc got upset with chapter two at the top of a new file
# I used to think pandoc really really likes a blank line at the end!!! It can be funny on some readers without
# I'm not really sure about this any more. With the blank line, and all my mitigating measures it still goes funny on my out the box iPad book app
# I think it might be the iPad book app. Other readers seem to find it ok.
# Sometimes I worry that I don't over-think things enough
#
Write-output `n | Out-File "Prose - Blank line.md" -Append

Write-Output "Adding build version to final-title.md..."
Add-Content -Path "book-version.txt" -Value $env:APPVEYOR_BUILD_VERSION
cat title-top.md, "Prose - Blank line.md", book-version.txt, "Prose - Blank line.md", title-bottom.md, "Prose - Blank line.md" | sc final-title.md # title.md contents at the top
#cat title-top.md, "Prose - Blank line.md", book-version.txt, "Prose - Blank line.md" | sc final-title.md # title.md contents at the top
Write-Output "Adding build version to final-title.md FINISHED"

Write-Output "Combining markdown..."
cat "Prose - Chapter One1.md", 
	"Prose - Blank line.md",
	"Prose - Chapter Two1.md",
	"Prose - Blank line.md",
	"Prose - Chapter Two2.md", 
	"Prose - Blank line.md",
	"Prose - Chapter Two3.md", 
	"Prose - Blank line.md",
	"Prose - Chapter Three1.md", 
	"Prose - Blank line.md",
	"Prose - Chapter Four1.md" | sc "The-Return-of-Tom-Thumb.md" 
	
Get-Content "The-Return-of-Tom-Thumb.md" -Encoding UTF8 | Replace-FancyQuotes | Out-File "The-Return-of-Tom-Thumb.txt" -Encoding UTF8 -Append
Write-Output "... made The-Return-of-Tom-Thumb.md and The-Return-of-Tom-Thumb.txt created"
Write-Output "Combining markdown FINISHED"

Write-Output "Creating books..."
pandoc --css epubstyle.css `
  "final-title.md" `
  "The-Return-of-Tom-Thumb.md" `
  -t epub
  -o The-Return-of-Tom-Thumb1.epub
Write-Output "... made The-Return-of-Tom-Thumb1.epub... (epub v1)"

pandoc --css epubstyle.css `
  "final-title.md" `
  "The-Return-of-Tom-Thumb.md" `
  -t epub2
  -o The-Return-of-Tom-Thumb2.epub
Write-Output "... made The-Return-of-Tom-Thumb1.epub... (epub v2)"

pandoc --css epubstyle.css `
  "final-title.md" `
  "The-Return-of-Tom-Thumb.md" `
  -t epub3
  -o The-Return-of-Tom-Thumb3.epub
Write-Output "... made The-Return-of-Tom-Thumb1.epub... (epub v3)"

pandoc --css epubstyle.css `
  "final-title.md" `
  "The-Return-of-Tom-Thumb.txt" `
  -o The-Return-of-Tom-Thumb.html
Write-Output "... made The-Return-of-Tom-Thumb.html..."


# Make the audio book (WIP)
Write-Output "Making Audio book ..."
# Add the title page in, which pandoc takes in as a separate file in addition to the book files. Here we want to include it all in one file
cat "final-title.md", The-Return-of-Tom-Thumb.txt | sc The-Return-of-Tom-Thumb-with-title.txt
Get-Content -Path "The-Return-of-Tom-Thumb-with-title.txt" -Encoding UTF8 | `
	Destroy-Quotes | `
	%{ $_.Replace("%", "").Replace("<sub>","").Replace("</sub>", "").Replace("*to*", "TO") } >> gTTS_word_input.txt
Write-Output "... made gTTS_word_input.txt"

cat gTTS_word_input.txt | python .\googleTextToSpeech.py -o The-Return-of-Tom-Thumb.mp3 -d The-Return-of-Tom-Thumb.mp3.log 
Write-Output "... made The-Return-of-Tom-Thumb.mp3 and The-Return-of-Tom-Thumb.mp3.log"

#
# Add a backing track to the audio book
#
Write-Output "Making audio book with soundtrack..."
lame --decode .\Music\natural-reader-soundtrack.mp3 natural-reader-soundtrack.wav  --silent
Write-Output "... made natural-reader-soundtrack.wav"

lame --decode The-Return-of-Tom-Thumb.mp3 The-Return-of-Tom-Thumb.wav --silent
Write-Output "... made The-Return-of-Tom-Thumb.wav"

sox The-Return-of-Tom-Thumb.wav --channels 2 The-Return-of-Tom-Thumb-stereo.wav -q
Write-Output "... made The-Return-of-Tom-Thumb-stereo.wav"

#copy .\Music\natural-reader-soundtrack.mp3 The-Return-of-Tom-Thumb-with-music.mp3 # default result if next step fails
#Write-Output "... made default upload artifact (backing track with no voice) The-Return-of-Tom-Thumb-with-music.mp3"

#tripple length of The-Return-of-Tom-Thumb-with-music.mp3
sox natural-reader-soundtrack.wav natural-reader-soundtrack.wav natural-reader-soundtrack.wav natural-reader-soundtrack-trippled.wav -q 
Write-Output "... made natural-reader-soundtrack-trippled.wav"

sox -m natural-reader-soundtrack-trippled.wav The-Return-of-Tom-Thumb-stereo.wav tRoTT-with-music.wav -q
Write-Output "... made sox mix of tRoTT-with-music.wav"

$trimToMinutes = "$([int]($(soxi -D The-Return-of-Tom-Thumb-stereo.wav)/60))"
$trimToMinutes = ([int]$trimToMinutes) + 1
$trimToParam = "$trimToMinutes`:00"
sox tRoTT-with-music.wav tRoTT-with-music-trimmed.wav trim 0 $trimToParam 
Write-Output "... made tRoTT-with-music-trimmed.wav"

lame tRoTT-with-music-trimmed.wav The-Return-of-Tom-Thumb-with-music.mp3 --silent
Write-Output "... made The-Return-of-Tom-Thumb-with-music.mp3"

#
# Croconocerous poem text to speech
#
$numberingRegEx = "[\d+\)]" 
Get-Content -Path ".\Character - Others\Croconossorus - origin.md" -Encoding UTF8 | `
	Destroy-Quotes | `
	%{ [regex]::Replace($_, $numberingRegEx, "").Replace("__", "").Replace("unreadable", "") } >> gTTS_croconossorus_word_input.txt

cat gTTS_croconossorus_word_input.txt | python .\googleTextToSpeech.py -o A_Croconossorus_Tale.mp3 -d A_Croconossorus_Tale.mp3.log 
Write-Output "... made A_Croconossorus_Tale.mp3"


#
# Debug google text to speech, to see how words sound (reads contents of gTTS_debug.txt and makes an mp3 debug artifact)
#
Get-Content -Path "gTTS_debug.txt" -Encoding UTF8 | Destroy-Quotes >test1.txt
cat test1.txt | python .\googleTextToSpeech.py -o testymctestface.mp3 -d testymctestface.mp3.log #-l fr-FR

Write-Output "... made The-Return-of-Tom-Thumb.mp3 and The-Return-of-Tom-Thumb.mp3.log..."

Write-Output "Creating books FINISHED"

Write-Output "Whole darn lot Finished!"
