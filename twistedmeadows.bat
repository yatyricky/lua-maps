@echo off
copy .\twistedmeadows.w3x\war3map.wts .\twistedmeadows.w3x\_Locales\zhCN.w3mod /y
node ./lua-bundler/bin.js ./Main.lua ./twistedmeadows.w3x/war3map.lua -e "Api;lua-bundler"
if %errorlevel% equ 0 (
    "Warcraft III.exe" -launch -window -loadfile "%~dp0\twistedmeadows.w3x"
)
