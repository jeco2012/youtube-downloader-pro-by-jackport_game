import os, sys, subprocess, urllib.request, zipfile, shutil

BIN_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "bin")
YTDLP_URL = "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"
FFMPEG_URL = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"

def setup():
    if not os.path.exists(BIN_DIR): os.makedirs(BIN_DIR)
    try: import webview
    except ImportError:
        print(" Menginstall komponen UI (pywebview)...")
        subprocess.run([sys.executable, "-m", "pip", "install", "pywebview", "requests"], stdout=subprocess.DEVNULL)
    if not os.path.exists(os.path.join(BIN_DIR, "yt-dlp.exe")):
        print(" Mendownload YT-DLP (16MB)...")
        urllib.request.urlretrieve(YTDLP_URL, os.path.join(BIN_DIR, "yt-dlp.exe"))
    if not os.path.exists(os.path.join(BIN_DIR, "ffmpeg.exe")):
        print(" Mendownload FFmpeg (~80MB, sekali saja)...")
        tmp = os.path.join(BIN_DIR, "ffmpeg.zip")
        urllib.request.urlretrieve(FFMPEG_URL, tmp)
        with zipfile.ZipFile(tmp, 'r') as z:
            for f in z.infolist():
                if f.filename.endswith('bin/ffmpeg.exe') or f.filename.endswith('bin/ffprobe.exe'):
                    p = z.extract(f)
                    shutil.move(p, os.path.join(BIN_DIR, os.path.basename(f.filename)))
        os.remove(tmp)

if __name__ == "__main__":
    setup()
    subprocess.run([sys.executable, "main.py"])