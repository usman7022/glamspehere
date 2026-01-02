# Script to convert Twitter images from string to array format
# Changes: "images": "url" -> "images": ["url"]

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
        
        # Change "images": "url" to "images": ["url"] in twitter metadata
        $content = $content -replace '("twitter":\s*\{[^}]*"images"):\s*"([^"]+)"', '$1: ["$2"]'
        
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
