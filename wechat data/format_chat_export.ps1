# Reads raw paste (UTF-8), writes organized .txt and print-friendly .html (open in browser -> Print -> Save as PDF)
param(
    [string]$InputFile = "$PSScriptRoot\chat_raw_paste.txt",
    [string]$OutTxt = "$PSScriptRoot\family_chat_organized.txt",
    [string]$OutHtml = "$PSScriptRoot\family_chat_organized.html"
)

if (-not (Test-Path -LiteralPath $InputFile)) {
    Write-Error "Missing input file: $InputFile`nSave your full chat paste there as UTF-8, then run this script again."
    exit 1
}

$raw = Get-Content -LiteralPath $InputFile -Raw -Encoding UTF8
$raw = $raw.Trim()

function Escape-Html([string]$s) {
    if ($null -eq $s) { return '' }
    $s = $s -replace '&', '&amp;'
    $s = $s -replace '<', '&lt;'
    $s = $s -replace '>', '&gt;'
    $s = $s -replace '"', '&quot;'
    return $s
}

$linkMatches = [regex]::Matches($raw, 'https?://[^\s\]\)>"''`]+')
$links = @($linkMatches | ForEach-Object { $_.Value.TrimEnd('.', ';') }) | Sort-Object -Unique

$lines = $raw -split "`r?`n"
$bodyTxt = New-Object System.Text.StringBuilder
[void]$bodyTxt.AppendLine('FAMILY / GROUP CHAT - ORGANIZED EXPORT')
[void]$bodyTxt.AppendLine('=======================================')
[void]$bodyTxt.AppendLine('')
[void]$bodyTxt.AppendLine('Sticker placeholders like [ThumbsUp] are kept as in the original paste.')
[void]$bodyTxt.AppendLine('')
[void]$bodyTxt.AppendLine('--- LINKS FOUND IN THIS PASTE (deduped) ---')
[void]$bodyTxt.AppendLine('')
if ($links.Count -eq 0) {
    [void]$bodyTxt.AppendLine('(none detected)')
} else {
    foreach ($l in $links) { [void]$bodyTxt.AppendLine("- $l") }
}
[void]$bodyTxt.AppendLine('')
[void]$bodyTxt.AppendLine('--- TRANSCRIPT (one line per bubble, blank line between) ---')
[void]$bodyTxt.AppendLine('')
foreach ($line in $lines) {
    $t = $line.TrimEnd()
    if ($t.Length -eq 0) { continue }
    [void]$bodyTxt.AppendLine($t)
    [void]$bodyTxt.AppendLine('')
}

[System.IO.File]::WriteAllText($OutTxt, $bodyTxt.ToString(), [System.Text.UTF8Encoding]::new($false))

$sbHtml = New-Object System.Text.StringBuilder
[void]$sbHtml.AppendLine('<!DOCTYPE html>')
[void]$sbHtml.AppendLine('<html lang="en"><head><meta charset="utf-8">')
[void]$sbHtml.AppendLine('<title>Family chat - organized export</title>')
[void]$sbHtml.AppendLine('<style>')
[void]$sbHtml.AppendLine('@media print { body { font-size: 11pt; } .noprint { display: none; } }')
[void]$sbHtml.AppendLine('body{font-family:Georgia,Cambria,serif;max-width:44rem;margin:1.5rem auto;padding:0 1rem;line-height:1.55;color:#111;}')
[void]$sbHtml.AppendLine('h1,h2{font-family:system-ui,-apple-system,sans-serif;font-weight:650;}')
[void]$sbHtml.AppendLine('h1{font-size:1.35rem;margin-bottom:0.25rem;}')
[void]$sbHtml.AppendLine('h2{font-size:1.1rem;margin-top:1.75rem;border-bottom:1px solid #ccc;padding-bottom:0.25rem;}')
[void]$sbHtml.AppendLine('ul.links{word-break:break-all;padding-left:1.2rem;}')
[void]$sbHtml.AppendLine('ul.links li{margin:0.35rem 0;}')
[void]$sbHtml.AppendLine('.msg{margin:0 0 0.9rem 0;white-space:pre-wrap;}')
[void]$sbHtml.AppendLine('.hint{color:#444;font-size:0.95rem;}')
[void]$sbHtml.AppendLine('</style></head><body>')
[void]$sbHtml.AppendLine('<p class="noprint hint">Print this page: <strong>Ctrl+P</strong> then <strong>Save as PDF</strong>.</p>')
[void]$sbHtml.AppendLine('<h1>Family / group chat - organized export</h1>')
[void]$sbHtml.AppendLine('<p class="hint">Sticker tags like [ThumbsUp] preserved from the original paste.</p>')
[void]$sbHtml.AppendLine('<h2>Links in this paste</h2>')
[void]$sbHtml.AppendLine('<ul class="links">')
if ($links.Count -eq 0) {
    [void]$sbHtml.AppendLine('<li>(none detected)</li>')
} else {
    foreach ($l in $links) {
        $e = Escape-Html $l
        [void]$sbHtml.AppendLine("<li><a href=`"$e`">$e</a></li>")
    }
}
[void]$sbHtml.AppendLine('</ul>')
[void]$sbHtml.AppendLine('<h2>Transcript</h2>')
foreach ($line in $lines) {
    $t = $line.TrimEnd()
    if ($t.Length -eq 0) { continue }
    $esc = Escape-Html $t
    [void]$sbHtml.AppendLine("<div class=`"msg`">$esc</div>")
}
[void]$sbHtml.AppendLine('</body></html>')

[System.IO.File]::WriteAllText($OutHtml, $sbHtml.ToString(), [System.Text.UTF8Encoding]::new($false))

Write-Host "Wrote:`n  $OutTxt`n  $OutHtml"

# Optional PDF via Chromium headless (Edge or Chrome)
$OutPdf = [System.IO.Path]::ChangeExtension($OutHtml, '.pdf')
$browser = $null
foreach ($c in @(
        "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
        "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
        "$env:ProgramFiles\Google\Chrome\Application\chrome.exe"
    )) {
    if (Test-Path -LiteralPath $c) { $browser = $c; break }
}
if ($browser) {
    $fullHtml = (Resolve-Path -LiteralPath $OutHtml).Path
    $uri = 'file:///' + ($fullHtml -replace '\\', '/' -replace ' ', '%20')
    & $browser --headless=new --disable-gpu --no-pdf-header-footer "--print-to-pdf=$OutPdf" $uri 2>$null
    Start-Sleep -Milliseconds 800
    if (Test-Path -LiteralPath $OutPdf) {
        Write-Host "  $OutPdf"
    } else {
        Write-Warning "PDF not created (open the .html in a browser and use Print -> Save as PDF)."
    }
} else {
    Write-Warning "Edge/Chrome not found; open $OutHtml and Print -> Save as PDF."
}
