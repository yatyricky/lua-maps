@echo off
node ./lua-bundler/bin.js ./Main.lua ./demo.w3x/war3map.lua -e "Api;lua-bundler;demo.w3x"
if %errorlevel% equ 0 (
    "C:\Users\nef\Games\Warcraft III\_retail_\x86_64\Warcraft III.exe" -launch -window -loadfile "%~dp0\demo.w3x"
)
