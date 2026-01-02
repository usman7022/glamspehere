# Script to add images field to openGraph metadata in all blog posts

$blogFiles = Get-ChildItem -Path "app\blog" -Filter "page.tsx" -Recurse | 
    Where-Object { 
        $_.FullName -notmatch "\\blog\\page\.tsx$" -and 
        $_.FullName -notmatch "\\blog\\\[slug\]\\page\.tsx$" 
    }

$updatedCount = 0
$skippedCount = 0
$errorCount = 0

foreach ($file in $blogFiles) {
    try {
        $content = Get-Content -Path $file.FullName -Raw
        
        # Check if openGraph already has images
        if ($content -match '"openGraph":\s*\{[^}]*"images"') {
            Write-Host "Skipping $($file.Name) - already has images in openGraph"
            $skippedCount++
            continue
        }
        
        # Extract the twitter images value
        if ($content -match '"twitter":\s*\{[^}]*"images":\s*"([^"]+)"') {
            $imageUrl = $matches[1]
            
            # Add images to openGraph after title
            $updatedContent = $content -replace `
                '("openGraph":\s*\{\s*"title":\s*"[^"]*",)', `
                "`$1`n    `"images`": `"$imageUrl`","
            
            # Write back to file
            Set-Content -Path $file.FullName -Value $updatedContent -NoNewline
            Write-Host "Updated $($file.Name)"
            $updatedCount++
        }
        else {
            Write-Host "Warning: Could not find twitter images in $($file.Name)"
            $errorCount++
        }
    }
    catch {
        Write-Host "Error processing $($file.Name): $_"
        $errorCount++
    }
}

Write-Host "`n=== Summary ==="
Write-Host "Updated: $updatedCount"
Write-Host "Skipped: $skippedCount"
Write-Host "Errors: $errorCount"
Write-Host "Total files: $($blogFiles.Count)"
