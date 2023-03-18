# Install-Module -Name ThreadJob

$url=""
$title=""
$pages=10
$ext="jpg"

$PATH = './' + $title

# Make Directory
New-Item -Path $PATH -ItemType Directory

$files = @()

for (($i = 1); $i -le $pages; $i++)
{
    $number = $i.ToString();
    $paddednumber = $i.ToString();

    if ($i -lt 10)
    {
        $paddednumber = "0" + $i.ToString();
    }

    $Uri = $url + "/" + $number + "." + $ext

    # Download
    $OutFile = $PATH + "/" + $number + "." + $ext
    Write-Output($uri)
    Write-Output($OutFile)

    $file = @{
        Uri = $Uri
        OutFile = $OutFile
    }

    $files += $file
}


$jobs = @()

foreach ($file in $files) {
    $jobs += Start-ThreadJob -Name $file.OutFile -ScriptBlock {
        $params = $using:file
        Invoke-WebRequest @params
    }
}

Write-Host "Downloads started..."
Wait-Job -Job $jobs

foreach ($job in $jobs) {
    Receive-Job -Job $job
}

# Zip
$ZipDestnation = "./" + $title
$compress = @{
  Path = $PATH
  CompressionLevel = "Fastest"
  DestinationPath = $ZipDestnation
}
Compress-Archive @compress

Get-ChildItem *.zip | Rename-Item -NewName { $_.Name -replace '.zip','.cbz' }

# Delete Directory

Remove-Item $PATH -Recurse