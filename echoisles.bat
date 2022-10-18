@echo off
copy .\echoisles.w3x\war3map.wts .\echoisles.w3x\_Locales\zhCN.w3mod /y
node ./lua-bundler/bin.js ./Main.lua ./echoisles.w3x/war3map.lua -e "Api;lua-bundler"
if %errorlevel% equ 0 (
    "Warcraft III.exe" -launch -window -loadfile "%~dp0\echoisles.w3x"
)
