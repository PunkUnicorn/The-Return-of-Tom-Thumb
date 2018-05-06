write-host "**topdf.ps1**"
pandoc --version
pandoc readme.md -f markdown -t pdf -s -o readme.pdf