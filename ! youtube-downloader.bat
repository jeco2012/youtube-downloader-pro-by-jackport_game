@echo off
title YouTube Downloader Multi-Link
:menu
cls
echo ===========================================
echo    YouTube Downloader (yt-dlp + ffmpeg)
echo ===========================================
echo.

echo tunggu sebentar yaa...
echo jangan lupa update kodenya di link github ini ya https://github.com/jeco2012/youtube-downloader-pro-by-jackport_game
echo.
echo jika kamu baru perama kali membuka tool ini,ini baru download base toolnya (kayak yt-dlp,ffmpeg,dll)

:: Menjalankan PowerShell
powershell -ExecutionPolicy Bypass -File "downloader.ps1"

:: Jika PowerShell keluar dengan kode error (exit 1)
if %errorlevel% neq 0 (
    echo.
    echo -------------------------------------------
    echo [ERROR] Terdeteksi masalah sistem atau file.
    echo Sistem akan mencoba reset yt-dlp...
    echo -------------------------------------------
    timeout /t 5
    goto menu
)

echo.
echo Klik apa saja untuk kembali ke Menu Utama.
pause >nul
goto menu
