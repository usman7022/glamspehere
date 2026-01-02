# Script to optimize Twitter metadata with "images" array for fastest response
# Changes: "image": "url" -> "images": ["url"]

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
        
        # Optimize: Change "image": "url" to "images": ["url"] for Twitter
        $content = $content -replace '("twitter":\s*\{[^}]*)"image":\s*"([^"]+)"', '$1"images": ["$2"]'
        
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
Write-Host "Optimized: $updatedCount files"
Write-Host "Errors: $errorCount"
Write-Host "Total files: $($blogFiles.Count)"
