# =====================================================================
#  Agencia Lobo & Co - Preparar assets binarios do site
#
#  Logos, favicon e og-image ja estao no projeto em SVG (marca vetorial
#  conforme agencia.md) e funcionam sem nenhum passo. Este script so
#  copia os 2 PDFs (Midia Kit e Portfolio) da secao "Materiais".
#
#  Uso:  powershell -ExecutionPolicy Bypass -File .\preparar-assets.ps1
#  Opcional: -ComLogosReais  gera PNGs otimizados das logos oficiais.
#
#  Robustez: sem literais acentuados (evita mojibake se o .ps1 nao tiver
#  BOM) e busca por curinga (os nomes no D: usam Unicode NFD).
# =====================================================================

param([switch]$ComLogosReais)

$ErrorActionPreference = "Stop"
$projeto = Split-Path -Parent $MyInvocation.MyCommand.Path
$base    = Split-Path -Parent (Split-Path -Parent $projeto)   # ...\AGENCIA LOBO & CO
$origem  = (Get-ChildItem -LiteralPath $base -Directory | Where-Object { $_.Name -like 'Ag*ncia' } | Select-Object -First 1).FullName
if (-not $origem) { Write-Error "Pasta 'Agencia' de origem nao encontrada em $base"; return }

$imgDir = Join-Path $projeto "assets\img"
$docDir = Join-Path $projeto "assets\docs"
New-Item -ItemType Directory -Force -Path $imgDir | Out-Null
New-Item -ItemType Directory -Force -Path $docDir | Out-Null

function Copy-ByWildcard {
    param([string]$pattern, [string]$dst)
    $f = Get-ChildItem -LiteralPath $origem -File | Where-Object { $_.Name -like $pattern } | Select-Object -First 1
    if ($f) { Copy-Item -LiteralPath $f.FullName -Destination $dst -Force; Write-Host "OK  -> $dst" }
    else    { Write-Warning "Nao encontrado (padrao '$pattern') em $origem" }
}

Write-Host "== PDFs (Materiais) ==" -ForegroundColor Cyan
Copy-ByWildcard '*dia Kit*.pdf'  (Join-Path $docDir "midia-kit-agencia-lobo-co.pdf")
Copy-ByWildcard 'Portfolio*.pdf' (Join-Path $docDir "portfolio-agencia-lobo-co.pdf")

if ($ComLogosReais) {
    Write-Host "`n== Logos reais (PNG otimizado) ==" -ForegroundColor Cyan
    Add-Type -AssemblyName System.Drawing
    function Resize-Png {
        param([string]$namePattern, [string]$dst, [int]$maxW)
        $src = Get-ChildItem -LiteralPath $origem -File | Where-Object { $_.Name -like $namePattern } | Select-Object -First 1
        if (-not $src) { Write-Warning "Logo nao encontrada: $namePattern"; return }
        $img = [System.Drawing.Image]::FromFile($src.FullName)
        try {
            $scale = [Math]::Min(1.0, $maxW / [double]$img.Width)
            $w = [int]([Math]::Round($img.Width * $scale)); $h = [int]([Math]::Round($img.Height * $scale))
            $bmp = New-Object System.Drawing.Bitmap $w, $h
            $g = [System.Drawing.Graphics]::FromImage($bmp)
            $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $g.Clear([System.Drawing.Color]::Transparent); $g.DrawImage($img, 0, 0, $w, $h); $g.Dispose()
            $bmp.Save($dst, [System.Drawing.Imaging.ImageFormat]::Png); $bmp.Dispose()
            Write-Host "OK  -> $dst (${w}x${h})"
        } finally { $img.Dispose() }
    }
    Resize-Png 'LOGO HORIZONTAL POSITIVA.png' (Join-Path $imgDir "logo-horizontal-positiva.png") 600
    Resize-Png 'LOGO POSITIVA.png'            (Join-Path $imgDir "logo-positiva.png")            480
    Write-Host "Para usar as PNGs reais, troque os src .svg por estes .png no index.html." -ForegroundColor Yellow
}

Write-Host "`nPronto. Site pronto para commit/deploy." -ForegroundColor Green
