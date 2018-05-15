write-host "**topdf.ps1**"
# run tests
Write-Output "Spelling Boom" #Add as test fails, and to the message window as errors
Write-Output "Spelling Exceptions start:"
Get-Content -Path "spellchecker.exceptions.txt" | Write-Output
Write-Output "Spelling Exceptions end!"

# Fancy quote solution: https://stackoverflow.com/questions/6968270/replacing-smart-quotes-in-powershell
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

# Fancy quote solution: https://stackoverflow.com/questions/6968270/replacing-smart-quotes-in-powershell
#$fancySingleQuotes = "[\u2019\u2018]" #Strip out fancy single and double quotes for spellchecking etc, or python goes ballistic
#$fancyDoubleQuotes = "[\u201C\u201D]" 
$chapterName = "Chapter One"
$spellingFailFilename = "Chapter-One-Spelling.txt"

Write-Output "$chapterName Spelling..."
$chapterOne = Get-Content -Path "Prose - $chapterName*.md" -Encoding UTF8
#$chapterOneSpelling = Get-Content -Path "Prose - Chapter One*.md" -Encoding UTF8 | `
#%{ `
#	$_ = `
#	[regex]::Replace($_, $fancySingleQuotes, "'")
#	[regex]::Replace($_, $fancyDoubleQuotes, '"') `
#} | python spellchecker.py | ConvertFrom-Json | %{ $_.Results } 
$chapterOneSpelling = $chapterOne | Replace-FancyQuotes
$chapterOneSpelling | fl; $chapterOneSpelling | fl | Out-File -FilePath $spellingFailFilename -Append
$chapterOneSpelling | %{ Add-AppveyorMessage -Message "$($_.Word) - $chapterName" -Details "$($_.Hint)" -Category "Error" }
$chapterOneSpelling | %{ Add-AppveyorTest -Name "$($_.Word) - Spelling" -Framework NUnit -Filename "$($_.Hint)" -ErrorMessage "$($_.Word)? $($_.Hint)" -Outcome "$($_.Status)" }

$spellingResults = $null;
$spellingResults = Get-Content -Path $spellingFailFilename 
If ($spellingResults -eq $null)
{
	Add-AppveyorTest -Name "Spelling" -Framework NUnit -Filename $chapterName -ErrorMessage "All passed" -Outcome "Passed"
	Write-Output "No spelling errors"
}
Write-Output "$chapterName Spelling Ends!"


Write-Output "Spelling Ends"

Write-Output "Chapter One Thesaurunocerous Boom" #Only add to the messages window
$chapterOneTheasurus = Get-Content -Path "Prose - Chapter One*.md" | `
%{ `
	$_ = `
	[regex]::Replace($_, $fancySingleQuotes, "'")
	[regex]::Replace($_, $fancyDoubleQuotes, '"') `
} | python thesaurunocerous.py | ConvertFrom-Json | %{ $_.Results }
$chapterOneTheasurus | fl
$chapterOneTheasurus | fl | Out-File -FilePath "Chapter-One-Words.txt" -Append
$chapterOneTheasurus | %{ Add-AppveyorMessage -Message "$($_.Word) x $($_.Occurs) - Chapter One" -Details "$($_.Hint)" -Category "$($_.Status)" }
Write-Output "Chapter One Thesaurunocerous Ends"
pandoc --version
pandoc --css epubstyle.css `
  "title.md" `
  "Prose - Chapter One1.md" `
  "Prose - Chapter One2.md" `
  "Prose - Chapter One3.md" `
  -o The-Return-of-Tom-Thumb.epub
