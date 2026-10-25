import subprocess, os, re, sys, json, shutil, urllib.request

class Engine:
    def __init__(self, app_dir):
        self.app_dir = app_dir
        self.ytdlp = os.path.join(app_dir, "bin", "yt-dlp.exe")
        self.ffmpeg = os.path.join(app_dir, "bin", "ffmpeg.exe")
        self.ffprobe = os.path.join(app_dir, "bin", "ffprobe.exe")
        self.backsound_path = os.path.join(app_dir, "backsound.mp3")
        self.config_file = os.path.join(app_dir, "cinnamon_config_pro.json")
        self.version_file = os.path.join(app_dir, "version.json")
        
        self.current_process = None
        self.current_urls = ""
        self.current_opts = {}
        self.is_paused = False
        self.is_cancelled = False
        
        self.load_config()

    def load_config(self):
        self.config = {
            "ModeVideo": True, "VidResIdx": 3, "VidFmtIdx": 0, "AudFmtIdx": 0,
            "AudBitIdx": 0, "DubIdx": 0, "SubIdx": 3, "Playlist": False,
            "Resume": True, "Sponsorblock": False, "SubOnly": False,
            "UseCookies": False, "BrowserIdx": 0, "ForceMode": True,
            "KeepVideo": False, "OutPath": os.path.join(self.app_dir, "downloads"),
            "ThemeIdx": 0, "OverwriteIdx": 0, "IsMuted": False, "SmartMode": True,
            "TrimStart": "00:00", "TrimEnd": "00:00", "AutoShutdown": False,
            "MaxThreads": 5, "DefaultMode": "video"
        }
        if os.path.exists(self.config_file):
            try:
                with open(self.config_file, 'r', encoding='utf-8') as f:
                    self.config.update(json.load(f))
            except: pass
        if not os.path.exists(self.config["OutPath"]): os.makedirs(self.config["OutPath"])

    def save_config(self, data):
        self.config.update(data)
        with open(self.config_file, 'w', encoding='utf-8') as f: json.dump(self.config, f, indent=4)
        return True

    def check_update(self):
        try:
            local_ver = "21.0.0"
            if os.path.exists(self.version_file):
                with open(self.version_file, 'r', encoding='utf-8') as f:
                    local_ver = json.load(f).get("version", "21.0.0")
            
            remote_url = "https://raw.githubusercontent.com/jeco2012/youtube-downloader-pro-by-jackport_game/main/version.json"
            req = urllib.request.Request(remote_url, headers={'User-Agent': 'Mozilla/5.0'})
            with urllib.request.urlopen(req, timeout=5) as response:
                remote_data = json.loads(response.read().decode())
                
            if remote_data["version"] != local_ver:
                return {
                    "status": "update_available",
                    "version": remote_data["version"],
                    "changelog": remote_data["changelog"],
                    "url": remote_data["download_url"]
                }
        except Exception as e:
            print(f"Check update error: {e}")
        return {"status": "latest"}

    def download_and_apply_update(self, download_url):
        try:
            zip_path = os.path.join(self.app_dir, "update.zip")
            urllib.request.urlretrieve(download_url, zip_path)
            
            bat_content = f"""@echo off
timeout /t 2 /nobreak >nul
taskkill /F /IM YouTubeDownloaderPro.exe >nul 2>&1
taskkill /F /IM python.exe >nul 2>&1
taskkill /F /IM py.exe >nul 2>&1

echo Mengekstrak update...
powershell -command "Expand-Archive -Path '{zip_path}' -DestinationPath '{self.app_dir}' -Force"

echo Membersihkan...
del "{zip_path}"

echo Membuka aplikasi baru...
if exist "{os.path.join(self.app_dir, 'YouTubeDownloaderPro.exe')}" (
    start "" "{os.path.join(self.app_dir, 'YouTubeDownloaderPro.exe')}"
) else (
    start "" "{os.path.join(self.app_dir, 'Start.bat')}"
)

del "%~f0"
"""
            bat_path = os.path.join(self.app_dir, "updater.bat")
            with open(bat_path, "w") as f:
                f.write(bat_content)
                
            subprocess.Popen([bat_path], shell=True, creationflags=subprocess.CREATE_NO_WINDOW)
            os._exit(0)
            return True
        except Exception as e:
            return f"Gagal update: {e}"

    def clear_cache(self):
        try:
            cache_dir = os.path.join(os.environ.get('LOCALAPPDATA', ''), 'yt-dlp')
            if os.path.exists(cache_dir):
                shutil.rmtree(cache_dir, ignore_errors=True)
            for f in os.listdir(self.config["OutPath"]):
                if f.endswith('.part') or f.endswith('.ytdl'):
                    try: os.remove(os.path.join(self.config["OutPath"], f))
                    except: pass
            return "Cache berhasil dihapus!"
        except Exception as e:
            return f"Gagal hapus cache: {e}"

    def ensure_backsound(self, progress_cb):
        if os.path.exists(self.backsound_path) and os.path.getsize(self.backsound_path) > 100000:
            return "Exists"
        progress_cb(0, "Mendownload Backsound...", "-", "-")
        url = "https://youtu.be/47t_n529Jls"
        cmd = [self.ytdlp, "-x", "--audio-format", "mp3", "--no-warnings", "-o", self.backsound_path, url]
        try:
            si = subprocess.STARTUPINFO()
            si.dwFlags |= subprocess.STARTF_USESHOWWINDOW
            p = subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, startupinfo=si)
            p.wait()
            if os.path.exists(self.backsound_path): return "Success"
        except: pass
        return "Failed"

    def get_video_info(self, url):
        cmd = [self.ytdlp, "-J", "--no-warnings", url]
        try:
            si = subprocess.STARTUPINFO()
            si.dwFlags |= subprocess.STARTF_USESHOWWINDOW
            res = subprocess.run(cmd, capture_output=True, text=True, startupinfo=si, encoding='utf-8', errors='replace', timeout=30)
            if res.returncode == 0:
                data = json.loads(res.stdout)
                return {
                    "title": data.get("title", "Unknown"),
                    "thumbnail": data.get("thumbnail", ""),
                    "uploader": data.get("uploader", "Unknown"),
                    "duration": data.get("duration_string", "0:00"),
                    "views": f"{data.get('view_count', 0):,}",
                    "likes": f"{data.get('like_count', 0):,}",
                    "desc": (data.get("description", "")[:150] + "...") if data.get("description") else ""
                }
        except Exception: pass
        return None

    def get_media_info(self, filepath):
        try:
            si = subprocess.STARTUPINFO()
            si.dwFlags |= subprocess.STARTF_USESHOWWINDOW
            cmd = [self.ffmpeg, "-i", filepath]
            res = subprocess.run(cmd, capture_output=True, text=True, startupinfo=si, encoding='utf-8', errors='replace')
            info_text = res.stderr
            size_mb = os.path.getsize(filepath) / (1024*1024)
            header = f"File Name: {os.path.basename(filepath)}\nFile Size: {size_mb:.2f} MB\n\n"
            return header + info_text
        except Exception as e: return f"Error: {e}"

    def import_txt(self, filepath):
        try:
            with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
                lines = f.readlines()
            urls = [l.strip() for l in lines if l.strip()]
            return "\n".join(urls)
        except Exception as e: return f"Error: {e}"

    def estimate_size(self, urls):
        url = urls.split("\n")[0].strip()
        if not url: return "URL kosong"
        cmd = [self.ytdlp, "--print", "%(title)s|%(filesize_approx)s|%(duration_string)s", "--no-warnings", url]
        try:
            si = subprocess.STARTUPINFO()
            si.dwFlags |= subprocess.STARTF_USESHOWWINDOW
            res = subprocess.run(cmd, capture_output=True, text=True, startupinfo=si, encoding='utf-8', errors='replace')
            out = res.stdout.strip()
            if out and "|" in out:
                parts = out.split("|")
                size_mb = int(parts[1]) / (1024*1024) if parts[1].isdigit() else 0
                return f"Judul: {parts[0]}\nUkuran: {size_mb:.2f} MB\nDurasi: {parts[2]}"
            return "Gagal mengambil info estimasi."
        except Exception as e: return str(e)

    def list_formats(self, urls, opts):
        url = urls.split("\n")[0].strip()
        if not url: return "URL kosong"
        cmd = [self.ytdlp, "--list-formats", "--no-warnings"]
        if opts.get("UseCookies", False):
            cmd.extend(["--cookies-from-browser", ["chrome", "edge", "firefox", "brave", "opera"][opts.get("BrowserIdx", 0)]])
        cmd.append(url)
        try:
            si = subprocess.STARTUPINFO()
            si.dwFlags |= subprocess.STARTF_USESHOWWINDOW
            res = subprocess.run(cmd, capture_output=True, text=True, startupinfo=si, encoding='utf-8', errors='replace')
            return res.stdout
        except Exception as e: return str(e)

    def run_tool(self, action, filepath, out_fmt="mp4", extra_path=""):
        if not os.path.exists(filepath):
            return "GAGAL: File tidak ditemukan."
        out_dir = os.path.abspath(self.config["OutPath"])
        if not os.path.exists(out_dir): os.makedirs(out_dir, exist_ok=True)
        base = os.path.splitext(os.path.basename(filepath))[0]
        
        if action == "convert":
            out_file = os.path.join(out_dir, f"{base}_conv.{out_fmt}")
            cmd = [self.ffmpeg, "-y", "-i", filepath, out_file]
        elif action == "thumb":
            out_file = os.path.join(out_dir, f"{base}.jpg")
            cmd = [self.ffmpeg, "-y", "-i", filepath, "-ss", "00:00:01", "-vframes", "1", out_file]
        elif action == "mute":
            out_file = os.path.join(out_dir, f"{base}_muted.mp4")
            cmd = [self.ffmpeg, "-y", "-i", filepath, "-an", "-c:v", "copy", out_file]
        elif action == "extract":
            out_file = os.path.join(out_dir, f"{base}_audio.mp3")
            cmd = [self.ffmpeg, "-y", "-i", filepath, "-vn", "-acodec", "libmp3lame", "-q:a", "2", out_file]
        elif action == "merge":
            out_file = os.path.join(out_dir, f"{base}_merged.mp4")
            cmd = [self.ffmpeg, "-y", "-i", filepath, "-i", extra_path, "-c:v", "copy", "-c:a", "aac", out_file]
        elif action == "info":
            return self.get_media_info(filepath)
        else:
            return "Aksi tidak valid."
        
        try:
            si = subprocess.STARTUPINFO()
            si.dwFlags |= subprocess.STARTF_USESHOWWINDOW
            res = subprocess.run(cmd, startupinfo=si, capture_output=True, text=True, encoding='utf-8', errors='replace')
            if res.returncode == 0:
                return f"✅ BERHASIL!\nFile disimpan di:\n{out_file}"
            else:
                return f"❌ GAGAL (Code {res.returncode}):\n{res.stderr[-400:]}"
        except Exception as e: 
            return f"❌ Error Eksekusi: {e}"

    def download(self, urls, opts, progress_cb):
        self.current_urls = urls
        self.current_opts = opts
        self.is_paused = False
        self.is_cancelled = False
        
        out_dir = opts.get("OutPath", self.config["OutPath"])
        cmd = [self.ytdlp, "--newline", "--ffmpeg-location", self.ffmpeg, "-o", os.path.join(out_dir, "%(title)s.%(ext)s")]
        
        if not opts.get("Playlist", False): cmd.append("--no-playlist")
        if opts.get("Resume", True): cmd.append("--continue")
        if opts.get("OverwriteIdx", 0) == 0: cmd.append("--no-overwrites")
        else: cmd.append("--force-overwrites")
        
        if opts.get("UseCookies", False):
            cmd.extend(["--cookies-from-browser", ["chrome", "edge", "firefox", "brave", "opera"][opts.get("BrowserIdx", 0)]])
        if opts.get("Sponsorblock", False):
            cmd.extend(["--sponsorblock-remove", "sponsor,selfpromo,interaction"])
            
        t_start, t_end = opts.get("TrimStart", "00:00"), opts.get("TrimEnd", "00:00")
        if t_start != "00:00" and t_end != "00:00":
            cmd.extend(["--download-sections", f"*{t_start}-{t_end}", "--force-keyframes-at-cuts"])
            
        if opts.get("SubOnly", False):
            cmd.extend(["--skip-download", "--write-subs", "--write-auto-subs", "--sub-langs", "all,en,id", "--convert-subs", "srt"])
        elif opts.get("ModeVideo", True):
            res = [4320, 2160, 1440, 1080, 720, 480, 360][opts.get("VidResIdx", 3)]
            fmt = ["mp4", "mkv", "webm", "avi"][opts.get("VidFmtIdx", 0)]
            dub = opts.get("DubIdx", 0)
            
            fmt_str = f"bv*[height<={res}]+ba/b[height<={res}]/b"
            if dub == 1: cmd.extend(["--audio-multistreams", "-f", f"bv*[height<={res}]+allaudio/b[height<={res}]/b"])
            elif dub == 2: cmd.extend(["-f", f"bv*[height<={res}]+ba[language=id]/bv*[height<={res}]+ba/b"])
            elif dub == 3: cmd.extend(["-f", f"bv*[height<={res}]+ba[language=en]/bv*[height<={res}]+ba/b"])
            elif dub == 4: cmd.extend(["-f", f"bv*[height<={res}]+ba[language=zh]/bv*[height<={res}]+ba/b"])
            else: cmd.extend(["-f", fmt_str])
            
            if fmt == "mp4": cmd.extend(["--merge-output-format", "mp4", "--postprocessor-args", "Merger:-c:v copy -c:a aac -b:a 192k"])
            elif fmt == "mkv": cmd.extend(["--merge-output-format", "mkv"])
            else: cmd.extend(["--remux-video", fmt])
            
            sub_idx = opts.get("SubIdx", 0)
            if sub_idx != 3:
                subs = "all" if sub_idx == 0 else ("id,id-ID,ind" if sub_idx == 1 else "en,en-US,eng")
                cmd.extend(["--write-subs", "--write-auto-subs", "--sub-langs", subs, "--embed-subs", "--compat-options", "no-keep-subs"])
            cmd.append("--embed-metadata")
            cmd.append("--embed-thumbnail")
        else:
            a_fmt = ["mp3", "wav", "flac", "m4a", "ogg"][opts.get("AudFmtIdx", 0)]
            a_bit = ["320", "256", "192", "128"][opts.get("AudBitIdx", 0)]
            cmd.extend(["-x", "--audio-format", a_fmt])
            if a_fmt in ["mp3", "m4a", "ogg"]: cmd.extend(["--audio-quality", a_bit])
            if opts.get("KeepVideo", False): cmd.append("-k")

        threads = str(opts.get("MaxThreads", 5))
        if opts.get("ForceMode", True): cmd.extend(["-N", threads, "--concurrent-fragments", threads])
        cmd.append("--ignore-errors")
        cmd.extend(urls.split("\n"))

        success = False
        try:
            si = subprocess.STARTUPINFO()
            si.dwFlags |= subprocess.STARTF_USESHOWWINDOW
            self.current_process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, encoding='utf-8', errors='replace', startupinfo=si)
            
            for line in self.current_process.stdout:
                if self.is_paused or self.is_cancelled: break
                match_q = re.search(r'Downloading (?:item|video) (\d+) of (\d+)', line)
                if match_q:
                    progress_cb(-1, f"{match_q.group(1)} / {match_q.group(2)}", "-", "-")
                    continue
                
                match = re.search(r'\[download\]\s+([\d\.]+)%\s+of\s+([\d\.\w]+)(?:\s+at\s+([\d\.\w/]+)\s+ETA\s+([\d:]+))?', line)
                if match: 
                    progress_cb(float(match.group(1)), f"Download {match.group(2)}", match.group(3) or "-", match.group(4) or "-")
                elif "[Merger]" in line or "[ExtractAudio]" in line: 
                    progress_cb(100, "Proses FFmpeg...", "-", "-")
            
            self.current_process.wait()
            success = (self.current_process.returncode == 0)
            self.current_process = None
            
            if success and opts.get("AutoShutdown", False) and not self.is_paused and not self.is_cancelled:
                os.system("shutdown /s /t 60")
        except: pass
        return success

    def pause_download(self):
        self.is_paused = True
        if self.current_process:
            subprocess.run(["taskkill", "/F", "/T", "/PID", str(self.current_process.pid)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return True