Update-SessionEnvironment # If ruby was just installed, it won't be on the path yet, unless we do this.
$rubyFound = [bool](Get-Command ruby -ErrorAction SilentlyContinue)
If (! $rubyFound) {
  Write-Host "Ruby not found!  Install with 'choco install ruby', or add ruby to your path if already installed."
  Throw "Ruby not found!"
}

$dir = Join-Path $env:chocolateyPackageFolder 'tools'
$filename = 'rubygems-update-2.4.6.gem'
$url = "https://rubygems.org/downloads/$filename"
$gemrc = Join-Path $env:userprofile '.gemrc'

If (! (Test-Path $gemrc)) {
  "gem: --no-document --quiet" | Out-File -Encoding ASCII $gemrc
  Write-Host "Setting gem installations to skip documentation and produce minimal output - if you need ri/rdoc available locally, please edit or remove $gemrc"
}

Get-ChocolateyWebFile 'rubygems' "$dir\$filename" $url
Set-Location $dir
& gem install -q $filename
& update_rubygems.bat --no-document | Out-Null
