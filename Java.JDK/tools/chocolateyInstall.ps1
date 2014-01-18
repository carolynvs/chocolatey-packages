### useful links ###
# https://github.com/carolynvs/chocolatey-packages/tree/master/Java.JDK
# http://www.oracle.com/technetwork/java/javase/downloads/index.html
# http://download.oracle.com/otn-pub/java/jdk/7u51-b13/jdk-7u51-windows-i586.exe
# http://download.oracle.com/otn-pub/java/jdk/7u51-b13/jdk-7u51-windows-x64.exe

$jdk_version = '7u51' 
$build = '13'
$java_version = "1.7.0_51" # cmd> java -version => "1.7.0_04"
$package_name = 'Java.JDK'

function use64bit() {
    $is64bitOS = (Get-WmiObject -Class Win32_ComputerSystem).SystemType -match ‘(x64)’
    return $is64bitOS -and ($params.x64 -ne $false)
}

function has_file($filename) {
    return Test-Path $filename
}

function get-programfilesdir() {
    $programFiles = (Get-Item "Env:ProgramFiles(x86)").Value
    if (use64bit) {
        $programFiles = $programFiles.Replace(" (x86)", "")
    }

    return $programFiles
}

function set-env-var([string]$name, [string]$value, [string]$type = 'User') {
    if ($type -eq 'Machine') {
        $cmd  = "[Environment]::SetEnvironmentVariable('$name', '$value', 'Machine')"    
        Start-ChocolateyProcessAsAdmin $cmd
    }
    else {
        [Environment]::SetEnvironmentVariable($name, $value, 'User')
    }
}

function download-from-oracle($url, $output_filename, $part) {
    if (-not (has_file($output_fileName))) {
        Write-Host  "Downloading JDK from $url"

        $client = New-Object Net.WebClient
        $client.Headers.Add('Cookie', 'oraclelicense$part-oth-JPR=accept-securebackup-cookie;gpw_e24=http://edelivery.oracle.com')
        $client.DownloadFile($url, $output_filename)

        if (-not (has_file($output_fileName))) {
            Write-ChocolateyFailure 'Java.JDK' "Error downloading $url to $output_filename"
        }
    }  
}

function download-jdk-file($url, $output_filename) {
    download-from-oracle $url $output_filename "jdk-$jdk_version"
}

function download-jdk() {
    $arch = get-arch
    $filename = "jdk-$jdk_version-windows-$arch.exe"
    $url = "http://download.oracle.com/otn-pub/java/jdk/$jdk_version-b$build/$filename"
    $package_dir = Join-Path $env:TEMP "chocolatey\$package_name"
    $output_filename = Join-Path $package_dir $filename

    download-jdk-file $url $output_filename

    return $output_filename
}

function get-installationDir-override(){
    if($params.path -ne $null){
        return "INSTALLDIR=$($params.path)"
    } else {
        return $null
    }
}

function get-java-home() {
    if($params.path -ne $null) {
        return $params.path
    } else {
        $program_files = get-programfilesdir
        return Join-Path $program_files "Java\jdk$java_version" #jdk1.6.0_17
    }
}

function get-java-bin() {
    $java_home = get-java-home
    return Join-Path $java_home 'bin'
}

function get-arch() {
    if(use64bit) {
        return "x64"
    } else {
        return "i586"
    }
}

function chocolatey-install() {
    $jdk_file = download-jdk
    $arch = get-arch
    $java_home = get-java-home
    $java_bin = get-java-bin
    $installDirOverride = get-installationDir-override

    Write-Host "Installing JDK $jdk_version($arch) to $java_home"
    Install-ChocolateyInstallPackage 'Java.jdk' 'exe' "/s $installDirOverride" $jdk_file          

    Install-ChocolateyPath $java_bin 'Machine'                 
         
    if ([Environment]::GetEnvironmentVariable('CLASSPATH','Machine') -eq $null) {
        set-env-var 'CLASSPATH' '.;' "Machine"    
    }

    set-env-var 'JAVA_HOME' $java_home 'Machine'          

    Write-ChocolateySuccess 'Java.JDK'
}

#installs Java.JDK
try {
    $params = "$env:chocolateyPackageParameters" # -params '"x64=false;path=c:\\java\\jdk"'
    $params = (ConvertFrom-StringData $params.Replace(";", "`n")) 
    
    chocolatey-install  
} catch {
  Write-ChocolateyFailure 'Java.JDK' "$($_.Exception.Message)"
  throw 
}  


