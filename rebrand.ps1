# Rebrand script for Kilas Janten
# Backup articles.json
Copy-Item -Path "articles.json" -Destination "articles.json.bak" -Force

# Counters
$mainPagesChanged = 0
$articlePagesChanged = 0
$cssChanged = 0
$packageChanged = 0
$docsChanged = 0

# Function to process HTML files
function Process-HTMLFile {
    param([string]$filePath)
    $content = Get-Content -Path $filePath -Encoding UTF8 -Raw

    $originalContent = $content

    # Fix quotation encoding
    $content = $content -replace '\u201C', '"'
    $content = $content -replace '\u201D', '"'
    $content = $content -replace '\u2018', "'"
    $content = $content -replace '\u2019', "'"
    $content = $content -replace '\u2013', '-'
    $content = $content -replace '\u2014', '-'
    $content = $content -replace '\uFFFD', ' '
    $content = $content -replace '\u00A0', ' '

    # Replace branding
    $content = $content -replace 'Kilas Janten', 'Kilas Janten'
    $content = $content -replace 'kilasjanten', 'kilasjanten'
    $content = $content -replace 'kilasjanten', 'KilasJanten'

    # Replace email
    $content = $content -replace 'kilasjanten33@gmail\.com', 'kilasjanten@gmail.com'

    # Replace title suffix
    $content = $content -replace ' - Kilas Janten', ' - Kilas Janten'

    # Replace navbar brand
    $content = $content -replace "<span style=`"font-weight: bold; color: #[0-9A-Fa-f]{6}; font-size: 24px; letter-spacing: -0.5px;`">WARTA<span style=`"color: #[0-9A-Fa-f]{6}; font-weight: normal; font-size: 18px; margin-left: 2px;`">JANTEN</span></span>", "<strong style=`"color:#1E3A8A`">KILAS</strong> <span style=`"color:#0B1120`">JANTEN</span>"

    # Replace inline colors (specific ones mentioned)
    $content = $content -replace '#065F46', '#1E3A8A'
    $content = $content -replace '#1E3A5F', '#0B1120'
    $content = $content -replace '#FFCC00', '#1E3A8A'
    $content = $content -replace '#1E2024', '#3F0F1F'

    if ($content -ne $originalContent) {
        Set-Content -Path $filePath -Value $content -Encoding UTF8
        return $true
    }
    return $false
}

# Process all HTML files recursively
$htmlFiles = Get-ChildItem -Path "." -Recurse -Include "*.html" -File
foreach ($file in $htmlFiles) {
    if (Process-HTMLFile -filePath $file.FullName) {
        if ($file.DirectoryName -eq (Get-Location).Path) {
            $mainPagesChanged++
        } elseif ($file.DirectoryName -like "*\article") {
            $articlePagesChanged++
        } else {
            # Other HTML files, maybe count as main or separate
            $mainPagesChanged++
        }
    }
}

# Process CSS files
$cssFiles = Get-ChildItem -Path "css\*.css" -File
foreach ($file in $cssFiles) {
    $content = Get-Content -Path $file.FullName -Encoding UTF8 -Raw
    $originalContent = $content

    # Replace CSS variables
    $content = $content -replace '--primary: #[0-9A-Fa-f]{6};', '--primary: #1E3A8A;'
    $content = $content -replace '--dark: #[0-9A-Fa-f]{6};', '--dark: #3F0F1F;'
    $content = $content -replace '--secondary: #[0-9A-Fa-f]{6};', '--secondary: #0B1120;'

    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
        $cssChanged++
    }
}

# Process package.json
$packageFiles = Get-ChildItem -Path "package.json", "tools\package.json" -File
foreach ($file in $packageFiles) {
    $content = Get-Content -Path $file.FullName -Encoding UTF8 -Raw
    $originalContent = $content

    $content = $content -replace '"name": "kilasjanten"', '"name": "kilasjanten"'
    $content = $content -replace '"name": "kilasjanten-article-generator"', '"name": "kilasjanten-article-generator"'
    $content = $content -replace '"kilasjanten"', '"kilasjanten"'
    $content = $content -replace 'Kilas Janten', 'Kilas Janten'
    $content = $content -replace '"author": "Kilas Janten Team"', '"author": "Kilas Janten Team"'

    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
        $packageChanged++
    }
}

# Process docs
$docFiles = Get-ChildItem -Path "." -Recurse -Include "*.md", "*.toml", "*.ps1", "*.txt", "*.log", "*.json" -File | Where-Object { $_.FullName -notlike "*node_modules*" }
foreach ($file in $docFiles) {
    $content = Get-Content -Path $file.FullName -Encoding UTF8 -Raw
    $originalContent = $content

    $content = $content -replace 'Kilas Janten', 'Kilas Janten'
    $content = $content -replace 'kilasjanten', 'kilasjanten'
    $content = $content -replace 'kilasjanten', 'KilasJanten'

    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
        $docsChanged++
    }
}

# Verification
$kilasjantenCount = (Get-ChildItem -Recurse -Include *.html,*.css,*.json,*.md,*.toml | Select-String -Pattern "Kilas Janten" -CaseSensitive).Count
$kilasjantenCount = (Get-ChildItem -Recurse -Include *.html,*.css,*.json,*.md,*.toml | Select-String -Pattern "kilasjanten" -CaseSensitive).Count
$kilasjantenCamelCount = (Get-ChildItem -Recurse -Include *.html,*.css,*.json,*.md,*.toml | Select-String -Pattern "kilasjanten" -CaseSensitive).Count
$logoPngCount = (Get-ChildItem -Recurse -Include *.html | Select-String -Pattern "logo\.png").Count

# Output
Write-Host "main pages: $mainPagesChanged"
Write-Host "article pages: $articlePagesChanged"
Write-Host "css: $cssChanged"
Write-Host "package: $packageChanged"
Write-Host "docs: $docsChanged"
Write-Host ""
Write-Host "Rebrand Kilas Janten selesai ✅"
