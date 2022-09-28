Add-Type -Assembly System.IO.Compression.FileSystem
$filePath = "Path-to-folder-with-zip-files"
$filePathCSV = "Path-to-folder-for-unzipped-files"

foreach($sourceFile in (Get-ChildItem $filePath -filter '*.zip')) 
{
    $zip = [IO.Compression.ZipFile]::OpenRead($sourceFile.FullName)
    $files = [array]($zip.Entries | Where-Object { return $_.FullName -match '.csv'});
    foreach ($file in $files) {
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($file, "$filePathCSV\csv_$file", $true)
    }
    $zip.Dispose()
}
