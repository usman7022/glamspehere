# Script to fix Twitter metadata - change "image" back to "images" for Next.js type compatibility
# Keep "summary_large_image" card type

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
        
        # Fix: Change "image": back to "images": in twitter metadata (Next.js requires plural)
        $content = $content -replace '("twitter":\s*\{[^}]*)"image":', '$1"images":'
        
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
