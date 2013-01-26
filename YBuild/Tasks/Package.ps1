function global:Copy-ArtifactItem {
    param($source, $destination)

    if (Test-Path $source -PathType Container) {
        xcopy /E /I $source\*.* $destination | Out-Null
    } else {
        echo F | xcopy $source $destination | Out-Null
    }
}

function global:Write-Zip($source, $destination, $packageName){
    $libPath = Get-Conventions libPath
    $7z = "$libPath\7z\7za.exe"
    "Zipping $source to $destination\$packageName"
    $zipCommand = "$7z a $(join-path $destination $packageName) $source"
    
    iex $zipCommand | out-null
}

function Write-PackageHelp {
    "You don't have packageContents defined in your build.yml. That's sort of odd" | Write-Host
}

task Package {
    $buildPath = Get-Conventions buildPath

    if ($buildConfig.copyContents.keys) {
        ($buildConfig.copyContents).keys | %{
            $source = Resolve-PathExpanded $_
            $destination = Expand-String $buildConfig.copyContents[$_]
            "Copying $source to $destination"
            
            if(!(Test-Path $destination)){
                mkdir $destination
            }
            Copy-Item $source -destination $destination
        }
    }
    if ($buildConfig.copyContents.keys) {
        ($buildConfig.packageContents).keys | %{
            $source = Resolve-PathExpanded $_
            Write-Zip $source $buildPath $buildConfig.packageContents[$_]
        }
    }
    
}
