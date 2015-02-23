$packageName = 'atlassian-plugin-sdk'
$installerType = 'exe'
$url = 'https://marketplace.atlassian.com/download/plugins/atlassian-plugin-sdk-windows/version/42260'
$silentArgs = '--mode unattended'
$validExitCodes = @(0)

Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$url" -validExitCodes $validExitCodes