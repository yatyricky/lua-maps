@echo off
node ./lua-bundler/bin.js ./Main.lua ./anotherdemo.w3x/war3map.lua -e "Api;lua-bundler"
if %errorlevel% equ 0 (
    "Warcraft III.exe" -launch -window -loadfile "%~dp0\anotherdemo.w3x"
)