<#
  DWG を DXF に一括変換する（AutoCAD レギュラー版の accoreconsole を使用）
  使い方:
    powershell -ExecutionPolicy Bypass -File dwg2dxf.ps1 -InDir "C:\図面\DWG" [-OutDir "C:\図面\DXF"] [-Version 2018] [-Recurse]
#>
param(
  [Parameter(Mandatory = $true)][string]$InDir,
  [string]$OutDir = "",
  [ValidateSet("R12", "2000", "2004", "2007", "2010", "2013", "2018")][string]$Version = "2018",
  [switch]$Recurse
)

$ErrorActionPreference = "Stop"

# accoreconsole.exe を探す（新しい AutoCAD を優先）
$exe = Get-ChildItem "C:\Program Files\Autodesk\AutoCAD *\accoreconsole.exe" -ErrorAction SilentlyContinue |
  Sort-Object FullName -Descending | Select-Object -First 1
if (-not $exe) { throw "accoreconsole.exe が見つかりません（AutoCAD レギュラー版が必要）" }
Write-Host "使用: $($exe.FullName)"

$InDir = (Resolve-Path $InDir).Path
if ($OutDir -eq "") { $OutDir = Join-Path $InDir "DXF" }
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$scr = Join-Path $PSScriptRoot "dwg2dxf.scr"
# スクリプト側（AutoLISP の getenv）で出力バージョンを読む
$env:DWG2DXF_VER = $Version

$files = Get-ChildItem -Path $InDir -Filter *.dwg -File -Recurse:$Recurse |
  Where-Object { $_.FullName -notlike "$OutDir*" }
if ($files.Count -eq 0) { Write-Host "DWG がありません: $InDir"; exit 0 }

$ok = 0; $ng = @()
foreach ($f in $files) {
  # DXF はいったん DWG と同じフォルダに書き出し、あとで出力先へ移す
  $tmp = [IO.Path]::ChangeExtension($f.FullName, ".dxf")
  if (Test-Path $tmp) { Remove-Item $tmp -Force }

  Write-Host "変換中: $($f.FullName)"
  & $exe.FullName /i "$($f.FullName)" /s "$scr" /l ja-JP | Out-Null

  if (Test-Path $tmp) {
    # サブフォルダ構成を保って出力
    $rel = $f.DirectoryName.Substring($InDir.Length).TrimStart("\")
    $dest = Join-Path $OutDir $rel
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    Move-Item $tmp (Join-Path $dest ([IO.Path]::GetFileName($tmp))) -Force
    $ok++
  } else {
    $ng += $f.FullName
  }
}

Write-Host ""
Write-Host "完了: $ok 件 / 失敗: $($ng.Count) 件  出力先: $OutDir"
$ng | ForEach-Object { Write-Host "  失敗: $_" }
