# Script to properly format Twitter images as array with clean formatting
$blogFiles = Get-ChildItem -Path "app\blog" -Filter "page.tsx" -Recurse | 
    Where-Object { 
        $_.FullName -notmatch "\\blog\\page\.tsx$" -and 
        $_.FullName -notmatch "\\blog\\\[slug\]\\page\.tsx$" 
    }

$updatedCount = 0

foreach ($file in $blogFiles) {
    try {
        $content = Get-Content -Path $file.FullName -Raw
        
        # Fix Twitter metadata formatting with proper array brackets
        if ($content -match '"twitter":\s*\{[^}]*"images":\s*"([^"]+)"') {
            $imageUrl = $matches[1]
            $content = $content -replace '("twitter":\s*\{)(\s*)"card":\s*"([^"]+)",(\s*)"title":\s*"([^"]*)",(\s*)"images":\s*"[^"]+",', '$1$2"card": "$3",$4"title": "$5",$6"images": ["' + $imageUrl + '"],'
            
            Set-Content -Path $file.FullName -Value $content -NoNewline
            Write-Host "Fixed: $($file.Directory.Name)"
            $updatedCount++
        }
    }
    catch {
        Write-Host "Error: $($file.Name)"
    }
}

Write-Host "`nFixed $updatedCount files with proper array format"
