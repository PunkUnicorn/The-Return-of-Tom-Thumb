write-host "**txttospeech.ps1**"
Get-Content -Path "The-Return-of-Tom-Thumb.txt" -Encoding UTF8 | python .\googleTextToSpeech.py 
