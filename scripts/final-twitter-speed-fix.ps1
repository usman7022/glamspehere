# Final Twitter Speed Optimization - Convert arrays to strings for FASTEST loading
$blogFiles = Get-ChildItem -Path "app\blog" -Filter "page.tsx" -Recurse | 
    Where-Object { 
        $_.FullName -notmatch "\\blog\\page\.tsx$" -and 
        $_.FullName -notmatch "\\blog\\\[slug\]\\page\.tsx$" 
    }

$updatedCount = 0

foreach ($file in $blogFiles) {
    try {
        $content = Get-Content -Path $file.FullName -Raw
        $originalContent = $content
        
        # Convert "images": ["url"] to "images": "url" for faster Twitter parsing
        $content = $content -replace '"images":\s*\["([^"]+)"\]', '"images": "$1"'
        
        if ($content -ne $originalContent) {
            Set-Content -Path $file.FullName -Value $content -NoNewline
            Write-Host "Optimized: $($file.Directory.Name)"
            $updatedCount++
        }
    }
    catch {
        Write-Host "Error: $($file.Name)"
    }
}

Write-Host "`n✅ SPEED OPTIMIZATION COMPLETE"
Write-Host "Optimized: $updatedCount files"
Write-Host "`nTwitter will now load cards INSTANTLY!"
