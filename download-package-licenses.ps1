# This script started with one written by "jerone". See https://softwareengineering.stackexchange.com/a/364008.
# Run in Package Manager Console with `./download-package-licenses.ps1`. (If access denied, execute
# `Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned`.)

Split-Path -parent $dte.Solution.FileName | cd; New-Item -ItemType Directory -Force -Path ".\licenses";

@( Get-Project -All | ? { $_.ProjectName } | % {
    Get-Package -ProjectName $_.ProjectName | ? { $_.LicenseUrl }
} ) | Sort-Object Id -Unique | % {
    $pkg = $_;
    Try {
        if ($pkg.Id -notlike 'microsoft*' -and $pkg.Id -notlike 'LevelUp*' -and $pkg.LicenseUrl.StartsWith('http')) {
        
            Write-Host "Downloading license for package " + $pkg.Id + " from " + $pkg.LicenseUrl

            $licenseUrl = $pkg.LicenseUrl
            if ($licenseUrl.contains('github.com')) {
                $licenseUrl = $licenseUrl.replace("/blob/", "/raw/")
            }

            $extension = ".txt"
            if ($licenseUrl.EndsWith(".md")) {
                $extension = ".md"
            } elseif ($licenseUrl.EndsWith(".html")) {
                $extension = ".html"
            }

            $fileName = (Join-Path (pwd) 'licenses\') + $pkg.Id + $extension
            
            Write-Host "Saving license as " + $fileName
            (New-Object System.Net.WebClient).DownloadFile($licenseUrl, $fileName)
            
            if (Get-Content $fileName | Where-Object { $_.Contains("<head>") }) {             
                $newFileName = (Join-Path (pwd) 'licenses\') + $pkg.Id + ".html"
                Write-Host "Changing " + $filename + " to " + $newFileName
                Move-Item -Path $fileName -Destination $newFileName -Force
            }
        }
    }
    Catch [system.exception] {
        Write-Host $_.exception.GetType().FullName, $_.exception.message
        Write-Host ("Could not download license for " + $pkg.Id)
    }
}
