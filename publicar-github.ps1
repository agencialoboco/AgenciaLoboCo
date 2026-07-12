# =====================================================================
#  Agencia Lobo & Co - Publicar o site no GitHub (conta: agencialoboco)
#
#  Faz tudo: adiciona git/gh portateis ao PATH, copia os PDFs, git init,
#  commit e push para  https://github.com/agencialoboco/AgenciaLoboCo
#
#  Uso:  powershell -ExecutionPolicy Bypass -File .\publicar-github.ps1
#
#  Autenticacao (uma vez):  gh auth login
#     -> GitHub.com > HTTPS > Login with a web browser
#  Sem browser: gerar Personal Access Token (classic) com escopo "repo"
#     em github.com/settings/tokens e cola-lo como senha no push.
# =====================================================================

$ErrorActionPreference = "Stop"
$projeto = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -LiteralPath $projeto

$owner = "agencialoboco"
$repo  = "AgenciaLoboCo"

# 0) git/gh portateis no PATH (instalados em %USERPROFILE%\Tools) ------
$tools = Join-Path $env:USERPROFILE "Tools"
$env:Path = (Join-Path $tools "MinGit\cmd") + ";" + (Join-Path $tools "gh\bin") + ";" + $env:Path

# 1) Assets binarios (PDFs) ------------------------------------------
Write-Host "== 1/4 Preparando assets ==" -ForegroundColor Cyan
& (Join-Path $projeto "preparar-assets.ps1")

# 2) Checagens -------------------------------------------------------
Write-Host "`n== 2/4 Checando ferramentas ==" -ForegroundColor Cyan
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "git nao encontrado (nem no PATH nem em $tools\MinGit). Instale o Git e rode de novo."
}
$temGh = [bool](Get-Command gh -ErrorAction SilentlyContinue)
Write-Host ("git: OK   gh: {0}" -f ($(if ($temGh) {"OK"} else {"nao encontrado"})))

# 3) Commit local ----------------------------------------------------
Write-Host "`n== 3/4 Commit local ==" -ForegroundColor Cyan
if (-not (Test-Path (Join-Path $projeto ".git"))) { git init | Out-Null; git branch -M main }
git add .
git diff --cached --quiet
if ($LASTEXITCODE -ne 0) {
    git commit -m "Site institucional da Agencia Lobo & Co" | Out-Null
    Write-Host "Commit criado."
} else { Write-Host "Nada novo para commitar." }

# 4) Publicar no GitHub ----------------------------------------------
Write-Host "`n== 4/4 Publicando em github.com/$owner/$repo ==" -ForegroundColor Cyan
if ($temGh) {
    gh auth status 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Nao logado no gh. Rode 'gh auth login' e execute este script de novo."
        return
    }
    gh repo view "$owner/$repo" 1>$null 2>$null
    $existe = ($LASTEXITCODE -eq 0)
    if ($existe) {
        if (-not (git remote | Select-String -Quiet origin)) { git remote add origin "https://github.com/$owner/$repo.git" }
        git push -u origin main
    } else {
        gh repo create "$owner/$repo" --public --source . --remote origin --push
    }
    Write-Host "`nPublicado: https://github.com/$owner/$repo" -ForegroundColor Green
} else {
    Write-Host "gh nao encontrado. Opcoes:" -ForegroundColor Yellow
    Write-Host "  A) Instale o GitHub CLI (cli.github.com), rode 'gh auth login' e este script de novo."
    Write-Host "  B) Crie o repo '$repo' vazio em github.com/$owner e rode:"
    Write-Host "       git remote add origin https://github.com/$owner/$repo.git"
    Write-Host "       git push -u origin main   (senha = Personal Access Token com escopo 'repo')"
}
