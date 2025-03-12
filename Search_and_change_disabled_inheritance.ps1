# Root folder
$target = Read-Host "Path to folder"

# Output file
$outputFile = "$(Read-Host 'Path to output folder')\_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

$count = 0
$disabledInheritanceCount = 0

# Create or clear the output file
New-Item -Path $outputFile -ItemType File -Force | Out-Null

# Process folders
# \\?\ prefix for long paths
Get-ChildItem -LiteralPath "\\?\$target" -Directory -Recurse | ForEach-Object {
    $count++

    try {
        # Get ACL
        $acl = Get-Acl -LiteralPath "\\?\$($_.FullName)"

        # Check inheritance
        if ($acl.AreAccessRulesProtected) {
            # Write to output file
            Add-Content -Path $outputFile -Value $_.FullName
            $disabledInheritanceCount++
        }
    } catch {
        # Write errors to console
        Write-Host "Error accessing $_.FullName: $_" -ForegroundColor Red
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

# Prompt to activate inheritance
$activateInheritance = Read-Host "Activate inheritance on these folders? (Yes/No)"
if ($activateInheritance -eq "Yes") {
    # Read folder paths from the output file
    $foldersToFix = Get-Content -Path $outputFile

    foreach ($folder in $foldersToFix) {
        try {
            # Get ACL
            $acl = Get-Acl $folder

            # Enable inheritance
            $acl.SetAccessRuleProtection($false, $true)

            # Apply modified ACL back
            Set-Acl -Path $folder -AclObject $acl

            Write-Host "Activated inheritance for: $folder" -ForegroundColor Green
        } catch {
            Write-Host "Failed to activate inheritance for: $folder" -ForegroundColor Red
        }
    }

    Write-Host "Inheritance activation completed!" -ForegroundColor Cyan
} else {
    Write-Host "No changes made to folder permissions." -ForegroundColor Yellow
}