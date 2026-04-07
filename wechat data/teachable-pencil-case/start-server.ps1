$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$port = 8765
$prefix = "http://127.0.0.1:$port/"

$mimes = @{
  ".html" = "text/html; charset=utf-8"
  ".htm"  = "text/html; charset=utf-8"
  ".js"   = "application/javascript"
  ".json" = "application/json"
  ".css"  = "text/css"
  ".ico"  = "image/x-icon"
  ".png"  = "image/png"
  ".jpg"  = "image/jpeg"
  ".jpeg" = "image/jpeg"
  ".gif"  = "image/gif"
  ".svg"  = "image/svg+xml"
  ".woff2" = "font/woff2"
  ".woff"  = "font/woff"
  ".ttf"   = "font/ttf"
  ".bin"   = "application/octet-stream"
  ".wasm"  = "application/wasm"
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)
try {
  $listener.Start()
} catch {
  Write-Host "Could not bind $prefix — try running as admin once, or: netsh http add urlacl url=$prefix user=$env:USERNAME"
  throw
}

Write-Host "Serving: $root"
Write-Host "Open:    $prefix"
Write-Host "Ctrl+C to stop."

while ($listener.IsListening) {
  $ctx = $listener.GetContext()
  $req = $ctx.Request
  $res = $ctx.Response
  try {
    $path = [Uri]::UnescapeDataString($req.Url.LocalPath)
    if ($path -eq "/" -or $path -eq "") { $path = "/index.html" }
    $rel = $path.TrimStart("/").Replace("/", [IO.Path]::DirectorySeparatorChar)
    $file = [IO.Path]::GetFullPath((Join-Path $root $rel))
    $rootFull = [IO.Path]::GetFullPath($root)
    if (-not $file.StartsWith($rootFull, [StringComparison]::OrdinalIgnoreCase)) {
      $res.StatusCode = 403
      continue
    }
    if (-not (Test-Path -LiteralPath $file)) {
      $res.StatusCode = 404
      continue
    }
    $ext = [IO.Path]::GetExtension($file).ToLowerInvariant()
    $res.ContentType = if ($mimes.ContainsKey($ext)) { $mimes[$ext] } else { "application/octet-stream" }
    $bytes = [IO.File]::ReadAllBytes($file)
    $res.ContentLength64 = $bytes.Length
    $res.OutputStream.Write($bytes, 0, $bytes.Length)
  } finally {
    $res.Close()
  }
}
