@echo off
title YouTube Downloader Pro v21
color 0B
echo ===================================================
echo    YOUTUBE DOWNLOADER PRO v21 - LIQUID EDITION
echo ===================================================
echo.
py -3 --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python tidak ditemukan. Install Python 3.12 dari python.org
    pause
    exit /b
)
py -3 launcher.py
if %errorlevel% neq 0 pause