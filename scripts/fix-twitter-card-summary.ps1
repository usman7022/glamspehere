# Script to change Twitter card from "summary_large_image" back to "summary"
# This will show image on left, text on right (compact layout)

$blogFiles = Get-ChildItem -Path "app\blog" -Filter "page.tsx" -Recurse | 
    Where-Object { 
        $_.FullName -notmatch "\\blog\\page\.tsx$" -and 
        $_.FullName -notmatch "\\blog\\\[slug\]\\page\.tsx$" 
    }

$updatedCount = 0
$errorCount = 0

foreach ($file in $blogFiles) {
    try {
        $content = Get-Content -Path $file.FullName -Raw
        $originalContent = $content
        
        # Change "summary_large_image" to "summary" for compact Twitter cards
        $content = $content -replace '"card":\s*"summary_large_image"', '"card": "summary"'
        
        if ($content -ne $originalContent) {
            Set-Content -Path $file.FullName -Value $content -NoNewline
            Write-Host "Updated $($file.Name)"
            $updatedCount++
        }
        else {
            Write-Host "No changes needed for $($file.Name)"
        }
    }
    catch {
        Write-Host "Error processing $($file.Name): $_"
        $errorCount++
    }
}

Write-Host "`n=== Summary ==="
Write-Host "Updated: $updatedCount"
Write-Host "Errors: $errorCount"
Write-Host "Total files: $($blogFiles.Count)"
