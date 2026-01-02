# Script to fix Twitter Card metadata in all blog posts
# Changes: "images" -> "image" and "summary" -> "summary_large_image"

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
        
        # Fix 1: Change "images": to "image": in twitter metadata
        $content = $content -replace '"twitter":\s*\{\s*"card":\s*"[^"]*",\s*"title":\s*"([^"]*)",\s*"images":', '"twitter": {    "card": "summary_large_image",    "title": "$1",    "image":'
        
        # Fix 2: Also handle case where card comes after title and images
        $content = $content -replace '("twitter":\s*\{[^}]*)"images":', '$1"image":'
        
        # Fix 3: Change card type from summary to summary_large_image
        $content = $content -replace '"twitter":\s*\{\s*"card":\s*"summary"', '"twitter": {    "card": "summary_large_image"'
        
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
