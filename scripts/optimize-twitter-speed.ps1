# Script to optimize Twitter metadata for FASTEST loading
# Changes: "images": ["url"] -> "image": "url" (Twitter prefers singular and simple format)

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
        
        # Optimize for speed: Change "images": ["url"] to "image": "url"
        # Twitter's crawler parses this faster (singular, no array)
        $content = $content -replace '("twitter":\s*\{[^}]*)"images":\s*\["([^"]+)"\]', '$1"image": "$2"'
        
        if ($content -ne $originalContent) {
            Set-Content -Path $file.FullName -Value $content -NoNewline
            Write-Host "Optimized $($file.Name)"
            $updatedCount++
        }
        else {
            Write-Host "Already optimized: $($file.Name)"
        }
    }
    catch {
        Write-Host "Error processing $($file.Name): $_"
        $errorCount++
    }
}

Write-Host "`n=== Summary ==="
Write-Host "Optimized: $updatedCount files for faster Twitter loading"
Write-Host "Errors: $errorCount"
Write-Host "Total files: $($blogFiles.Count)"
