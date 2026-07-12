# =====================================================================
#  Agência Lobo & Co - Preparar assets do site
#  Copia e otimiza (redimensiona) as logos oficiais e os PDFs para
#  dentro de /assets, com nomes prontos para URL (sem espaços/acentos).
#
#  Como usar (PowerShell, na pasta do projeto):
#     powershell -ExecutionPolicy Bypass -File .\preparar-assets.ps1
#
#  Requisitos: Windows PowerShell 5.1+ (System.Drawing disponível).
# =====================================================================

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

# Pasta de origem das artes oficiais da marca
$origem  = "D:\ÁREA DE TRABALHO\AGÊNCIA LOBO & CO\Agência"
# Pasta do projeto (onde este script está)
$projeto = Split-Path -Parent $MyInvocation.MyCommand.Path
$imgDir  = Join-Path $projeto "assets\img"
$docDir  = Join-Path $projeto "assets\docs"

New-Item -ItemType Directory -Force -Path $imgDir | Out-Null
New-Item -ItemType Directory -Force -Path $docDir | Out-Null

# --- Função: redimensiona um PNG mantendo proporção e transparência ---
function Resize-Png {
    param([string]$src, [string]$dst, [int]$maxW)
    if (-not (Test-Path $src)) { Write-Warning "Origem não encontrada: $src"; return }
    $img = [System.Drawing.Image]::FromFile($src)
    try {
        $scale = [Math]::Min(1.0, $maxW / [double]$img.Width)
        $w = [int]([Math]::Round($img.Width  * $scale))
        $h = [int]([Math]::Round($img.Height * $scale))
        $bmp = New-Object System.Drawing.Bitmap $w, $h
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $g.Clear([System.Drawing.Color]::Transparent)
        $g.DrawImage($img, 0, 0, $w, $h)
        $g.Dispose()
        $bmp.Save($dst, [System.Drawing.Imaging.ImageFormat]::Png)
        $bmp.Dispose()
        Write-Host "OK  -> $dst  (${w}x${h})"
    } finally { $img.Dispose() }
}

# --- Função: gera og-image 1200x630 (fundo grafite + logo centralizada) ---
function New-OgImage {
    param([string]$logoSrc, [string]$dst)
    if (-not (Test-Path $logoSrc)) { Write-Warning "Logo p/ OG não encontrada: $logoSrc"; return }
    $W = 1200; $H = 630
    $bmp = New-Object System.Drawing.Bitmap $W, $H
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $bg = [System.Drawing.ColorTranslator]::FromHtml("#0E1217")
    $g.Clear($bg)
    $logo = [System.Drawing.Image]::FromFile($logoSrc)
    try {
        $maxW = 760
        $scale = [Math]::Min(1.0, $maxW / [double]$logo.Width)
        $lw = [int]($logo.Width * $scale); $lh = [int]($logo.Height * $scale)
        $x = [int](($W - $lw) / 2); $y = [int](($H - $lh) / 2)
        $g.DrawImage($logo, $x, $y, $lw, $lh)
    } finally { $logo.Dispose() }
    $g.Dispose()
    $bmp.Save($dst, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host "OK  -> $dst  (og-image 1200x630)"
}

Write-Host "`n== Logos ==" -ForegroundColor Cyan
# Header e rodapé: horizontal positiva (branca) sobre fundo escuro
Resize-Png (Join-Path $origem "LOGO HORIZONTAL POSITIVA.png") (Join-Path $imgDir "logo-horizontal-positiva.png") 600
# Emblema quadrado positivo (branco) para a seção "Sobre"
Resize-Png (Join-Path $origem "LOGO POSITIVA.png")            (Join-Path $imgDir "logo-positiva.png")            480
# Favicon / ícone: foto de perfil positiva
Resize-Png (Join-Path $origem "LOGO POSITIVA FOTO DE PERFIL.png") (Join-Path $imgDir "favicon.png")             512

Write-Host "`n== Open Graph ==" -ForegroundColor Cyan
New-OgImage (Join-Path $origem "LOGO HORIZONTAL POSITIVA.png") (Join-Path $imgDir "og-image.png")

Write-Host "`n== PDFs ==" -ForegroundColor Cyan
Copy-Item (Join-Path $origem "Mídia Kit Agência Lobo & Co.pdf")   (Join-Path $docDir "midia-kit-agencia-lobo-co.pdf") -Force
Write-Host "OK  -> midia-kit-agencia-lobo-co.pdf"
Copy-Item (Join-Path $origem "Portfolio Agência Lobo & Co.pdf")   (Join-Path $docDir "portfolio-agencia-lobo-co.pdf") -Force
Write-Host "OK  -> portfolio-agencia-lobo-co.pdf"

Write-Host "`nAssets prontos em /assets. Agora e so publicar (ver README.md)." -ForegroundColor Green
