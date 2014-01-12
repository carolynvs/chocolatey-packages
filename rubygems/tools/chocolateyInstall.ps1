$pwd = Get-Location
$packageName = 'rubygems'
$version = '2.1.11'
$zipName = "rubygems-$version.zip"
$url = "http://production.cf.rubygems.org/rubygems/$zipName"
$validExitCodes = @(0)
$scriptPath = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
$zipPath = Join-Path $scriptPath $zipName
$setupDir = Join-Path $scriptPath "rubygems-$version"

try {

  Get-ChocolateyWebFile "$packageName" "$zipPath" "$url"
  Get-ChocolateyUnzip "$zipPath" "$scriptPath"
  
  Set-Location $setupDir
  Start-ChocolateyProcessAsAdmin 'setup.rb' 'ruby' -validExitCodes $validExitCodes

  Write-ChocolateySuccess "$packageName"
} catch {
  Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
  throw
}
finally {
  Set-Location $pwd
}