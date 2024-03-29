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
		
	Write-Output $chapterSpelling | Format-Table -Wrap
	
	$chapterSpelling | Out-File -FilePath $spellingFailFilename -Append
	
	$chapterSpelling | `
		%{ Add-AppveyorTest `
			-Name "$($_.Word) - Spelling $chapterName" `
			-Framework NUnit `
			-Filename "$($_.Hint)" `
			-ErrorMessage "$($_.Word)? $($_.Hint)" `
			-Outcome "Failed" 
		}

#	$chapterSpelling  | `
#		%{ Add-AppveyorMessage `
#			-Message "$($_.Word) - $chapterName" `
#			-Details "$($_.Hint)" `
#			-Category "Error" 
#		}

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

	#Write-Output $bigWords
	
	$chapterWordCount | Measure-Object Count -Sum -Maximum | Select -Property `
		@{Label="Unique word count";Expression={$_.Count}}, 
		@{label="Word count";Expression={$_.Sum}}, 
		@{label="Maximum occurrence of any word";Expression={$_.Maximum}} | fl
	
	if ($env:WANTTHES -eq "1") {
		$chapterWordHints = $bigWords | `
			foreach { $_.Word } | `
			python theasaurus.py | ` 
			ConvertFrom-Csv
	}	
	
	# JASON HULP! ADD $chapterWordCount to $bigWords!!! SO KNOW WORD COUNT WITH SYNONYM LOOKUP??? 
	# wut $hintsWithCount = $bigWords | Add-Member 
	
	
	Write-Output $chapterWordHints | Format-Table -Wrap
	Write-Output "$chapterName WordAnalysis ends!"
}

#
# Thesaurunocerous chapter files by filename convention
# Outputs word stat results messages etc
#
Function Thesaurunocerous-Chapter($chapterName, $wordsFilename, $isAppveryorMessage) {
	Write-Output "$chapterName Thesaurunocerous starts:"	
  	if ($env:WANTTHES -eq "1")
  	{

		$chapter = Get-Content -Path "Prose - $chapterName*.md" -Encoding UTF8 | Replace-FancyQuotes 
		$chapterTheasurus = $chapter | python thesaurunocerous.py | ConvertFrom-Json | %{ $_.Results }  # | Where-Object {$_.Occurs -gt 10 -and $_.Length -gt 3 }
		#$chapterTheasurus | fl
		#$chapterTheasurus | fl | Out-File -FilePath $wordsFilename -Append
		if ($isAppveryorMessage -eq "True") {
			$chapterTheasurus | `
				%{ Add-AppveyorMessage `
					-Message "$($_.Word) x $($_.Occurs) - $chapterName" `
					-Details "$($_.Hint)" `
					-Category "Information" 
				}		
		}
  	}
	else
	{
		Write-Output "Thesaurunocerous Skipped! (takes too long to download theasaurus corpus'"
	}
	WordAnalysis-Chapter $chapterName | Out-File $wordsFilename -Append
	#Write-Output "$chapterName Thesaurunocerous end!"	
}	
	

# run tests
Get-Content -Path "./RedRidingHood/ASCII_RED.txt" -Encoding UTF8 
Write-Output "Spelling Starts" 
#Spellcheck-DumpExceptions
Spellcheck-Chapter "Chapter One" "Chapter-One-Spelling.txt" 
Spellcheck-Chapter "Chapter Two" "Chapter-Two-Spelling.txt"
Spellcheck-Chapter "Chapter Three" "Chapter-Three-Spelling.txt"
Spellcheck-Chapter "Chapter Four" "Chapter-Four-Spelling.txt"
Spellcheck-Chapter "Chapter Five" "Chapter-Five-Spelling.txt"
Spellcheck-Chapter "Chapter Six" "Chapter-six-Spelling.txt"
Write-Output "Spelling Ends"

Write-Output "Thesaurunocerous Starts"
Thesaurunocerous-Chapter "Chapter One" "Chapter-One-Words.txt" "False"
Thesaurunocerous-Chapter "Chapter Two" "Chapter-Two-Words.txt" "False"
Thesaurunocerous-Chapter "Chapter Three" "Chapter-Three-Words.txt" "False"
Thesaurunocerous-Chapter "Chapter Four" "Chapter-Four-Words.txt" "False"
Thesaurunocerous-Chapter "Chapter Five" "Chapter-Five-Words.txt" "False"
Thesaurunocerous-Chapter "Chapter Six" "Chapter-six-Words.txt" "False"

Thesaurunocerous-Chapter "Chapter *" "Chapter-All-Words.txt" "True"
Write-Output "Thesaurunocerous Ends"

Write-Output "Word Analysis Starts"
# something for the colsole
WordAnalysis-Chapter "Chapter *"
Write-Output "Word Analysis Ends"


# Make the book
Get-Content -Path ".\TheTailor\the-tailor.txt" -Encoding UTF8 
Write-Output "`n`nIntroducing ... pandoc!`n"
pandoc --version
Write-Output "`n`nIntroducing ... lame!`n"
.\lame --version
Write-Output "`n`nIntroducing ... sox!`n"
sox -h
Write-Output "`n`nIntroducing ... soxi!`n"
soxi
#Write-Output "`n`nIntroducing ... well ... it's a PARTY GATECRASHER! THE SYSTEM PATH!!!! Welcome though bro'. Grab a drink, you know, and chill; mi casa es tu casa`n"
#path

#
# I used to think pandoc got upset with chapter two at the top of a new file
# I used to think pandoc really really likes a blank line at the end!!! It can be funny on some readers without
# I'm not really sure about this any more. With the blank line, and all my mitigating measures it still goes funny on my out the box iPad book app
# I think it might be the iPad book app. Other readers seem to find it ok.
# Now I think it's an epub book version thing
#
# Now I know it's the filename
#
# iBooks likes different filenames
#
# BOOM
#

Write-output `n | Out-File "Prose - Blank line.md" -Append
Write-output "# Appendix A-1" | Out-File "Prose - Appendix1-1.md" -Append
Write-output "# Appendix A-2" | Out-File "Prose - Appendix1-2.md" -Append
Write-output "# Appendix A-3" | Out-File "Prose - Appendix1-3.md" -Append
Write-output "# Appendix A-4" | Out-File "Prose - Appendix1-4.md" -Append
Write-output "# Appendix B" | Out-File "Prose - Appendix2.md" -Append
Add-Content -Path "book-version.txt" -Value $env:APPVEYOR_BUILD_VERSION

Write-Output "Adding build version and creating metadata.yaml..."
Get-Content partial_metadata.yaml -Encoding UTF8 | %{ $_.Replace("BOOKVERSIONHERE", "$env:APPVEYOR_BUILD_VERSION.1") } | Out-File "metadata_v1.yaml" -Encoding UTF8
Get-Content partial_metadata.yaml -Encoding UTF8 | %{ $_.Replace("BOOKVERSIONHERE", "$env:APPVEYOR_BUILD_VERSION.2") } | Out-File "metadata_v2.yaml" -Encoding UTF8
Get-Content partial_metadata.yaml -Encoding UTF8 | %{ $_.Replace("BOOKVERSIONHERE", "$env:APPVEYOR_BUILD_VERSION.3") } | Out-File "metadata_v3.yaml" -Encoding UTF8

Get-Content "metadata_v1.yaml" -Encoding UTF8
Get-Content "metadata_v2.yaml" -Encoding UTF8
Get-Content "metadata_v3.yaml" -Encoding UTF8

Write-Output "Combining markdown..."

#cat "book-version.txt",
#	"Prose - Blank line.md",
#	"Prose - Chapter One1.md",
#	"Prose - Blank line.md",
#	"Prose - Chapter Two1.md",
#	"Prose - Blank line.md",
#	"Prose - Chapter Two2.md", 
#	"Prose - Blank line.md",
#	"Prose - Chapter Two3.md", 
#	"Prose - Blank line.md",
#	"Prose - Chapter Three1.md", 
#	"Prose - Blank line.md",
#	"Prose - Chapter Four1.md", 
#	"Prose - Blank line.md" | sc "The-Return-of-Tom-Thumb-for-audio-single-chapter-one.md" 


cat "book-version.txt",
	"Prose - Blank line.md",
	"Prose - Chapter One1.md",
	"Prose - Blank line.md",
	"Prose - Chapter Two1.md",
	"Prose - Blank line.md",
	"Prose - Chapter Two2.md", 
	"Prose - Blank line.md",
	"Prose - Chapter Two3.md", 
	"Prose - Blank line.md",
	"Prose - Chapter Three1.md", 
	"Prose - Blank line.md",
	"Prose - Chapter Four1.md",
	"Prose - Blank line.md",
	"Prose - Chapter Five1.md",
	"Prose - Blank line.md",
	"Prose - Chapter Six1.md",
	"Prose - Blank line.md" | sc "The-Return-of-Tom-Thumb-for-audio.md" 


#cat "The-Return-of-Tom-Thumb-for-audio-single-chapter-one.md" | sc "The-Return-of-Tom-Thumb-single-chapter-one.md" 


cat "The-Return-of-Tom-Thumb-for-audio.md",	
	"Prose - Blank line.md",
	"Prose - Appendix1-1.md",
	"Prose - Blank line.md",
	"Character - Red Riding Hood\Red Riding Hood - D20 Model.md",
	"Prose - Blank line.md",
	"Prose - Appendix1-2.md",
	"Prose - Blank line.md",
	"Character - Tom Thumb\Tom Thumb - D20 Model.md",
	"Prose - Blank line.md",
	"Prose - Appendix1-3.md",
	"Prose - Blank line.md",
	"Character - The Knight\The Knight - D20 Model.md",
	"Prose - Blank line.md",
	"Prose - Appendix1-4.md",
	"Prose - Blank line.md",
	"Character - The Tailor\The Tailor - D20 Model.md",
	"Prose - Blank line.md",
	"Prose - Appendix2.md",
	"Prose - Blank line.md",
	"Character - Others\Croconossorus - origin.md"	| sc "The-Return-of-Tom-Thumb.md" 


#Get-Content "The-Return-of-Tom-Thumb-single-chapter-one.md" -Encoding UTF8 | Replace-FancyQuotes | Out-File "The-Return-of-Tom-Thumb-single-chapter-one.txt" -Encoding UTF8 -Append
#Write-Output "... made The-Return-of-Tom-Thumb-single-chapter-one.md and The-Return-of-Tom-Thumb-single-chapter-one.txt"

Get-Content "The-Return-of-Tom-Thumb.md" -Encoding UTF8 | Replace-FancyQuotes | Out-File "The-Return-of-Tom-Thumb.txt" -Encoding UTF8 -Append
Write-Output "... made The-Return-of-Tom-Thumb.md and The-Return-of-Tom-Thumb.txt"


Get-Content "The-Return-of-Tom-Thumb-for-audio.md" -Encoding UTF8 | Replace-FancyQuotes | Out-File "The-Return-of-Tom-Thumb-for-audio.txt" -Encoding UTF8 -Append
Write-Output "... made The-Return-of-Tom-Thumb-for-audio.md and The-Return-of-Tom-Thumb-for-audio.txt"



#Get-Content "The-Return-of-Tom-Thumb-for-audio-single-chapter-one.md" -Encoding UTF8 | Replace-FancyQuotes | Out-File "The-Return-of-Tom-Thumb-for-audio-single-chapter-one.txt" -Encoding UTF8 -Append
#Write-Output "... made The-Return-of-Tom-Thumb-for-audio.md and The-Return-of-Tom-Thumb-for-audio-single-chapter-one.txt"

Write-Output "Combining markdown FINISHED"

Write-Output "Creating books..."

#pandoc --css epubstyle.css 		`
#  --epub-cover-image=cover_small.png 	`
#  "title.md" 				`
#  "The-Return-of-Tom-Thumb-single-chapter-one.md" 		`
#  -t epub 				`
#  -o The-Return-of-Tom-Thumb_single_chapter_one_$($($env:APPVEYOR_BUILD_VERSION).Replace(".", "_"))_v1.epub 	`
#  metadata_v1.yaml --embed-resources --standalone
#Write-Output "... made The-Return-of-Tom-Thumb_single_chapter_one_$($($env:APPVEYOR_BUILD_VERSION).Replace(".", "_"))_v1.epub... (epub v1)"

pandoc --css epubstyle.css 		`
  --epub-cover-image=cover_small.png 	`
  "title.md" 				`
  "The-Return-of-Tom-Thumb.md" 		`
  -t epub 				`
  -o The-Return-of-Tom-Thumb_$($($env:APPVEYOR_BUILD_VERSION).Replace(".", "_"))_v1.epub 	`
  metadata_v1.yaml --embed-resources --standalone
Write-Output "... made The-Return-of-Tom-Thumb_$($($env:APPVEYOR_BUILD_VERSION).Replace(".", "_"))_v1.epub... (epub v1)"

pandoc --css epubstyle.css 		`
  --epub-cover-image=cover_small.png 	`
  "title.md" 				`
  "The-Return-of-Tom-Thumb.md" 		`
  -t epub2+smart 			`
  -o The-Return-of-Tom-Thumb_$($($env:APPVEYOR_BUILD_VERSION).Replace(".", "_"))_v2.epub 	`
  metadata_v2.yaml --embed-resources --standalone
Write-Output "... made The-Return-of-Tom-Thumb_$($($env:APPVEYOR_BUILD_VERSION).Replace(".", "_"))_v2.epub ... (epub v2)"

pandoc --css epubstyle.css 		`
  --epub-cover-image=cover_small.png 	`
  "title.md" 				`
  "The-Return-of-Tom-Thumb.md" 		`
  -t epub3+smart 			`
  -o The-Return-of-Tom-Thumb_$($($env:APPVEYOR_BUILD_VERSION).Replace(".", "_")).epub 	`
  --metadata-file=metadata_v3.yaml --embed-resources --standalone
Write-Output "... made The-Return-of-Tom-Thumb_$($($env:APPVEYOR_BUILD_VERSION).Replace(".", "_")).epub... (epub v3)"

#copy The-Return-of-Tom-Thumb_single_chapter_one_$($($env:APPVEYOR_BUILD_VERSION).Replace(".", "_"))_v1.epub The-Return-of-Tom-Thumb-single-chapter-one.epub
#Write-Output "... made The-Return-of-Tom-Thumb-single-chapter-one.epub... (v1)"

copy The-Return-of-Tom-Thumb_$($($env:APPVEYOR_BUILD_VERSION).Replace(".", "_"))_v1.epub The-Return-of-Tom-Thumb.epub
Write-Output "... made The-Return-of-Tom-Thumb.epub... (epub v3)"

Write-output "# Appendix A-1" | Out-File "Prose - Appendix1-1.md" -Append

#pandoc "title.md" "The-Return-of-Tom-Thumb-single-chapter-one.md" `
#  -o The-Return-of-Tom-Thumb-single-chapter-one.html `
#  --css=htmlstyle.css --embed-resources --standalone
#Write-Output "... made The-Return-of-Tom-Thumb-single-chapter-one.html..."

#pandoc --css epubstyle.css 
pandoc --toc "title.md" The-Return-of-Tom-Thumb.md `
  -o The-Return-of-Tom-Thumb.html `
  --css=./htmlstyle.css --embed-resources --standalone

# pandoc "title.md" The-Return-of-Tom-Thumb.md -o The-Return-of-Tom-Thumb.html `
# --css=.\typo-today\css\stylesheet.css `
# --resource-path=".\typo-today\css;.\typo-today\img;.\typo-today\js" `
# --metadata cover-image=cover_small.png `
# --standalone
Write-Output "... made The-Return-of-Tom-Thumb.html..."

# Make the audio book (WIP)
Write-Output "Making Audio book ..."
# Add the title page in, which pandoc takes in as a separate file in addition to the book files. Here we want to include it all in one file

#cat "title.md", "Prose - Blank Line.md", The-Return-of-Tom-Thumb-for-audio-single-chapter-one.txt | sc The-Return-of-Tom-Thumb-for-audio-with-title-single-chapter-one.txt

cat "title.md", "Prose - Blank Line.md", The-Return-of-Tom-Thumb-for-audio.txt | sc The-Return-of-Tom-Thumb-for-audio-with-title.txt

#Get-Content -Path "The-Return-of-Tom-Thumb-for-audio-with-title-single-chapter-one.txt" -Encoding UTF8 | `
#	Destroy-Quotes | `
#	%{ $_.Replace("%", "").Replace("<sub>","").Replace("</sub>", "").Replace("*to*", "TO").Replace("*the*", "THE").Replace("*all*", "ALL").Replace("- ", "").Replace(" -", "") } >> gTTS_word_input-single-chapter-one.txt
#Write-Output "... made gTTS_word_input-single-chapter-one.txt"

Get-Content -Path "The-Return-of-Tom-Thumb-for-audio-with-title.txt" -Encoding UTF8 | `
	Destroy-Quotes | `
	%{ $_.Replace("%", "").Replace("<sub>","").Replace("</sub>", "").Replace("*to*", "TO").Replace("*the*", "THE").Replace("*all*", "ALL").Replace("- ", "").Replace(" -", "") } >> gTTS_word_input.txt
Write-Output "... made gTTS_word_input.txt"

#cat gTTS_word_input-single-chapter-one.txt | python .\googleTextToSpeech.py -o The-Return-of-Tom-Thumb-single-chapter-one.mp3 -d The-Return-of-Tom-Thumb-single-chapter-one.mp3.log 
#Write-Output "... made The-Return-of-Tom-Thumb-single-chapter-one.mp3 and The-Return-of-Tom-Thumb-single-chapter-one.mp3.log"

if ($env:WANTPREM -eq "1" -and "$($env:prem)".Length -gt 0) {
	Write-Output "... making the premium audio book"
	dotnet run --project PremiumAudioBookSdk\TomThumbPremiumAudioBook\TomThumbPremiumAudioBook\TomThumbPremiumAudioBook.csproj -- $($env:prem) PremiumAudioBookSdk\TomThumbPremiumAudioBook\TomThumbPremiumAudioBook\template-ssml.xml audio The-Return-of-Tom-Thumb-for-audio.txt
	dir .\
	dir .\audio
	copy .\audio\The-Return-of-Tom-Thumb-Autoread.mp3 The-Return-of-Tom-Thumb-16000.mp3
	.\lame --resample 24000 The-Return-of-Tom-Thumb-16000.mp3 The-Return-of-Tom-Thumb.mp3 --silent
	del The-Return-of-Tom-Thumb-16000.mp3
	Write-Output "... made The-Return-of-Tom-Thumb.mp3"
} else {
	cat gTTS_word_input.txt | python .\googleTextToSpeech.py -o The-Return-of-Tom-Thumb.mp3 -d The-Return-of-Tom-Thumb.mp3.log 
	Write-Output "... made The-Return-of-Tom-Thumb.mp3 and The-Return-of-Tom-Thumb.mp3.log"
}

#
# Add a backing track to the audio book
#
Write-Output "Making audio book with soundtrack..."
.\lame --decode .\Music\natural-reader-soundtrack.mp3 natural-reader-soundtrack.wav --silent
Write-Output "... made natural-reader-soundtrack.wav"

#.\lame --decode The-Return-of-Tom-Thumb-single-chapter-one.mp3 The-Return-of-Tom-Thumb-single-chapter-one.wav --silent
#Write-Output "... made The-Return-of-Tom-Thumb-single-chapter-one.wav"

.\lame --decode The-Return-of-Tom-Thumb.mp3 The-Return-of-Tom-Thumb.wav  --silent
Write-Output "... made The-Return-of-Tom-Thumb.wav"

#sox The-Return-of-Tom-Thumb-single-chapter-one.wav --channels 2 The-Return-of-Tom-Thumb-stereo-single-chapter-one.wav -q
#Write-Output "... made The-Return-of-Tom-Thumb-stereo-single-chapter-one.wav"

sox The-Return-of-Tom-Thumb.wav --channels 2 The-Return-of-Tom-Thumb-stereo.wav -q
Write-Output "... made The-Return-of-Tom-Thumb-stereo.wav"

# Triple length of The-Return-of-Tom-Thumb-with-music.mp3
sox natural-reader-soundtrack.wav natural-reader-soundtrack.wav natural-reader-soundtrack.wav natural-reader-soundtrack-tripled.wav -q 
Write-Output "... made natural-reader-soundtrack-tripled.wav"

#sox -m natural-reader-soundtrack-tripled.wav The-Return-of-Tom-Thumb-stereo-single-chapter-one.wav tRoTT-with-music-single-chapter-one.wav -q
#Write-Output "... made sox mix of tRoTT-with-music-single-chapter-one.wav"

soxi -r natural-reader-soundtrack-tripled.wav
#soxi -t -r -c -s -d -D -b -B -e -a natural-reader-soundtrack-tripled.wav

soxi -r The-Return-of-Tom-Thumb-stereo.wav
#soxi -t -r -c -s -d -D -b -B -e -a The-Return-of-Tom-Thumb-stereo.wav

sox -m natural-reader-soundtrack-tripled.wav The-Return-of-Tom-Thumb-stereo.wav tRoTT-with-music.wav -q
Write-Output "... made sox mix of tRoTT-with-music.wav"

#$trimToMinutes = "$([int]($(soxi -D The-Return-of-Tom-Thumb-stereo-single-chapter-one.wav)/60))"
#$trimToMinutes = ([int]$trimToMinutes) + 1
#$trimToParam = "$trimToMinutes`:00"
#sox tRoTT-with-music-single-chapter-one.wav tRoTT-with-music-trimmed-single-chapter-one.wav trim 0 $trimToParam 
#Write-Output "... made tRoTT-with-music-trimmed-single-chapter-one.wav"

$trimToMinutes = "$([int]($(soxi -D The-Return-of-Tom-Thumb-stereo.wav)/60))"
$trimToMinutes = ([int]$trimToMinutes) + 1
$trimToParam = "$trimToMinutes`:00"
sox tRoTT-with-music.wav tRoTT-with-music-trimmed.wav trim 0 $trimToParam 
Write-Output "... made tRoTT-with-music-trimmed.wav"

#.\lame tRoTT-with-music-trimmed-single-chapter-one.wav The-Return-of-Tom-Thumb-with-music-single-chapter-one.mp3 --silent
#Write-Output "... made The-Return-of-Tom-Thumb-with-music-single-chapter-one.mp3"

.\lame tRoTT-with-music-trimmed.wav The-Return-of-Tom-Thumb-with-music.mp3 --silent
Write-Output "... made The-Return-of-Tom-Thumb-with-music.mp3"

#
# Croconocerous poem text to speech
#
$numberingRegEx = "[\d+\)]" 
Get-Content -Path ".\Character - Others\Croconossorus - origin.md" -Encoding UTF8 | `
	Destroy-Quotes | `
	%{ [regex]::Replace($_, $numberingRegEx, "").Replace("__unreadable__", "(There is text here, but it is unreadable)").Replace("__", "").Replace("#","") } >> gTTS_croconossorus_word_input.txt

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
