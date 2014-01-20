$packageName = 'atlassian-plugin-sdk'
$installerType = 'exe'
$url = 'https://marketplace.atlassian.com/download/plugins/atlassian-plugin-sdk-windows'
$silentArgs = '--mode unattended'
$validExitCodes = @(0)

Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$url" -validExitCodes $validExitCodes