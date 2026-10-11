# ============================================================
# subir-sitio.ps1 - publica ./_site en el servidor de webs estáticas
# Empaqueta, sube con barra de progreso (scp) y despliega.
# Autenticación por clave SSH (sin contraseñas).
#
# Uso (desde la carpeta del proyecto):
#   subir-sitio              publica _site como /<nombre-carpeta>/
#   subir-sitio -Eliminar    elimina el sitio del servidor
# ============================================================
param([switch]$Eliminar)

$ErrorActionPreference = "Stop"

# ---- CONFIGURACIÓN ------------------------------------------------
$RemoteUser = "webadmin"
$RemoteHost = "webs.fpgh.link"                 # debe resolver al LXC de Caddy (SSH, puerto 22)
$RemoteCmd  = "/usr/local/bin/deploy-site"
$BaseUrl    = "https://webs.fpgh.link"
# -------------------------------------------------------------------

$ProjectPath = (Get-Location).Path
$SiteName    = Split-Path $ProjectPath -Leaf
$SitePath    = Join-Path $ProjectPath "_site"
$SshTarget   = "$RemoteUser@$RemoteHost"

function Fail($msg) {
    Write-Host ""
    Write-Host "ERROR: $msg" -ForegroundColor Red
    Write-Host ""
    exit 1
}

if ($SiteName -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]*$') {
    Fail "El nombre de carpeta '$SiteName' no es válido (solo letras, números, '.', '_' y '-')."
}
foreach ($cmd in "tar", "ssh", "scp") {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) { Fail "No se encuentra $cmd.exe." }
}

# ---------------------------------------------------------------- eliminar
if ($Eliminar) {
    Write-Host ""
    Write-Host "Se eliminará del servidor: $SiteName"
    if ((Read-Host "¿Continuar? [S/N]") -notmatch '^[sS]$') { Write-Host "Cancelado."; exit 0 }

    ssh $SshTarget "$RemoteCmd --remove $SiteName"
    if ($LASTEXITCODE -ne 0) { Fail "No se pudo eliminar el sitio." }
    exit 0
}

# ---------------------------------------------------------------- publicar
if (-not (Test-Path $SitePath -PathType Container)) {
    Fail "No existe la carpeta _site en $ProjectPath"
}

Write-Host ""
Write-Host "============================================"
Write-Host " SUBIDA DE SITIO WEB ESTÁTICO"
Write-Host "============================================"
Write-Host "Proyecto : $SiteName"
Write-Host "Origen   : $SitePath"
Write-Host "Destino  : $BaseUrl/$SiteName/"
Write-Host ""

if ((Read-Host "¿Continuar con la subida? [S/N]") -notmatch '^[sS]$') {
    Write-Host "Operación cancelada."
    exit 0
}

$Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$Stamp     = Get-Date -Format "yyyyMMddHHmmss"
$LocalTar  = Join-Path $env:TEMP "subir-sitio-$SiteName-$Stamp.tar"
$RemoteTar = "/tmp/subir-sitio-$SiteName-$Stamp.tar"
$Failed    = $null

try {
    # ---- 1/3 Empaquetar ----------------------------------------------
    $Files = @(Get-ChildItem -Path $SitePath -Recurse -File -Force).Count
    Write-Host ""
    Write-Host "[1/3] Empaquetando $Files archivos..." -ForegroundColor Cyan

    Push-Location $SitePath
    try {
        tar -cf $LocalTar .
        $code = $LASTEXITCODE
    }
    finally {
        Pop-Location
    }
    if ($code -ne 0) { throw "No se pudo crear el paquete (tar, código $code)." }

    $Size = (Get-Item $LocalTar).Length / 1MB
    Write-Host ("      Paquete de {0:N2} MB" -f $Size)

    # ---- 2/3 Subir (scp muestra su barra de progreso) ------------------
    Write-Host ""
    Write-Host "[2/3] Subiendo al servidor..." -ForegroundColor Cyan

    scp $LocalTar "${SshTarget}:$RemoteTar"
    if ($LASTEXITCODE -ne 0) {
        try { ssh $SshTarget "rm -f $RemoteTar" | Out-Null } catch { }
        throw "La subida ha fallado (scp, código $LASTEXITCODE)."
    }

    # ---- 3/3 Desplegar -------------------------------------------------
    Write-Host ""
    Write-Host "[3/3] Instalando en el servidor..." -ForegroundColor Cyan

    # El paquete temporal se borra siempre, haya ido bien o mal el despliegue.
    $Remote = "$RemoteCmd $SiteName < $RemoteTar; rc=" + '$?' + "; rm -f $RemoteTar; exit " + '$rc'
    ssh $SshTarget $Remote
    if ($LASTEXITCODE -ne 0) { throw "El despliegue ha fallado (código $LASTEXITCODE)." }
}
catch {
    $Failed = $_.Exception.Message
}
finally {
    Remove-Item $LocalTar -Force -ErrorAction SilentlyContinue
}

if ($Failed) { Fail $Failed }

$Stopwatch.Stop()
Write-Host ""
Write-Host "============================================"
Write-Host " SITIO PUBLICADO"
Write-Host "============================================"
Write-Host "URL    : $BaseUrl/$SiteName/"
Write-Host ("Tiempo : {0:N1} s" -f $Stopwatch.Elapsed.TotalSeconds)
Write-Host ""
