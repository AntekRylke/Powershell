# Root folder
$target = Read-Host "Path to folder"

# Output file
$outputFile = "$(Read-Host 'Path to output folder')\_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

$count = 0

# New output file
New-Item -Path $outputFile -ItemType File -Force | Out-Null

# Process folders
Get-ChildItem -LiteralPath "\\?\$target" -Directory -Recurse | ForEach-Object {
    $count++
   
    # Get ACL
        $acl = Get-Acl -LiteralPath "\\?\$($_.FullName)"

    # Check inheritance
    if ($acl.AreAccessRulesProtected) {
        # Write to output file
        Add-Content -Path $outputFile -Value $_.FullName
    }

    # Increment progress counter
    if ($count % 1000 -eq 0) {
        Write-Host "Processed $count folders..." -ForegroundColor Yellow
    }
}

# Completion message
Write-Host "Folders processed: $count" -ForegroundColor Green
Write-Host "Folders with disabled inheritance: $disabledInheritanceCount" -ForegroundColor Cyan
Write-Host "Folders with disabled inheritance saved to: $outputFile" -ForegroundColor Green