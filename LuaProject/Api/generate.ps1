#!/usr/bin/env pwsh
param(
    [switch]$Debug
)

$debugFlag = if ($Debug) { "--debug" } else { "" }

Write-Host "Generating Lua declaration files from Jass sources..." -ForegroundColor Green
if ($Debug) {
    Write-Host "Debug mode enabled - showing unprocessed lines" -ForegroundColor Yellow
}
Write-Host ""

Set-Location $PSScriptRoot

Write-Host "Processing common.j..." -ForegroundColor Yellow
if ($Debug) {
    node enhanced-parser.js common.j common --debug
} else {
    node enhanced-parser.js common.j common
}

Write-Host ""
Write-Host "Processing blizzard.j..." -ForegroundColor Yellow
if ($Debug) {
    node enhanced-parser.js blizzard.j blizzard --debug
} else {
    node enhanced-parser.js blizzard.j blizzard
}

Write-Host ""
Write-Host "Cleaning up old generated files..." -ForegroundColor Yellow
Remove-Item -Path "common.lua" -ErrorAction SilentlyContinue
Remove-Item -Path "blizzard.lua" -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "Generation complete!" -ForegroundColor Green
Write-Host "Files generated:" -ForegroundColor Cyan
Get-ChildItem -Path "common_*.lua", "blizzard_*.lua" | ForEach-Object { 
    $lines = (Get-Content $_.FullName | Measure-Object -Line).Lines
    Write-Host "  $($_.Name) ($lines lines)" -ForegroundColor White
}