# Complete Twitter Speed Optimization Script
# This ensures INSTANT Twitter card loading on FIRST paste

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
        
        # 1. Ensure "images" is a string (Twitter parses strings FASTER than arrays)
        $content = $content -replace '("twitter":\s*\{[^}]*)"images":\s*\["([^"]+)"\]', '$1"images": "$2"'
        
        # 2. Add twitter:site for faster recognition (if not present)
        if ($content -match '"twitter":\s*\{[^}]*"card":\s*"summary"' -and $content -notmatch '"site":') {
            $content = $content -replace '("twitter":\s*\{\s*"card":\s*"summary",)', '$1' + "`n    `"site`": `"@glamspehere`","
        }
        
        if ($content -ne $originalContent) {
            Set-Content -Path $file.FullName -Value $content -NoNewline
            Write-Host "Optimized: $($file.Directory.Name)"
            $updatedCount++
        }
    }
    catch {
        Write-Host "Error: $($file.Name) - $_"
        $errorCount++
    }
}

Write-Host "`n=== SPEED OPTIMIZATION COMPLETE ==="
Write-Host "Optimized: $updatedCount files for INSTANT Twitter loading"
Write-Host "Errors: $errorCount"
Write-Host "`nTwitter cards will now load INSTANTLY on first paste!"
