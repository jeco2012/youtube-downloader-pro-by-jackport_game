import webview, os, sys, threading, base64
from engine import Engine

class Api:
    def __init__(self):
        self._window = None
        self.app_dir = os.path.dirname(os.path.abspath(sys.argv[0]))
        self.engine = Engine(self.app_dir)

    def set_window(self, window): self._window = window
    def load_settings(self): return self.engine.config
    def save_settings(self, data): return self.engine.save_config(data)
    
    def get_backsound_b64(self):
        if os.path.exists(self.engine.backsound_path):
            try:
                with open(self.engine.backsound_path, "rb") as f:
                    return base64.b64encode(f.read()).decode('utf-8')
            except: return ""
        return ""

    def minimize_window(self): self._window.minimize()
    def close_window(self): self._window.destroy()

    def browse_folder(self):
        res = self._window.create_file_dialog(webview.FileDialog.FOLDER)
        if res and len(res) > 0:
            self.engine.config["OutPath"] = res[0]
            self.engine.save_config(self.engine.config)
            return res[0].replace("\\", "/")
        return ""

    def open_file_dialog(self, file_type="all"):
        if file_type == "text": filters = ("Text Files (*.txt)",)
        elif file_type == "video": filters = ("Video Files (*.mp4; *.mkv; *.webm)",)
        elif file_type == "audio": filters = ("Audio Files (*.mp3; *.m4a; *.wav)",)
        else: filters = ("All Files (*.*)",)
            
        res = self._window.create_file_dialog(webview.FileDialog.OPEN, file_types=filters)
        if res and len(res) > 0: return res[0]
        return ""

    def get_info(self, url):
        info = self.engine.get_video_info(url)
        if info: return info
        return {"title": "Gagal", "thumbnail": "", "uploader": "", "duration": "", "views": "", "likes": "", "desc": "Gagal mengambil info."}

    def check_update(self): return self.engine.check_update()
    def do_update(self, url):
        def task():
            self._window.evaluate_js("window.update_status('Mengunduh update...')")
            res = self.engine.download_and_apply_update(url)
            if res != True:
                self._window.evaluate_js(f"window.update_status('{res}')")
        threading.Thread(target=task, daemon=True).start()
        return "Updating"

    def clear_cache(self): return self.engine.clear_cache()
    def import_txt(self, path): return self.engine.import_txt(path)
    def estimate_size(self, urls): return self.engine.estimate_size(urls)
    def list_formats(self, urls, opts): return self.engine.list_formats(urls, opts)
    def run_tool(self, action, filepath, out_fmt="mp4", extra_path=""): return self.engine.run_tool(action, filepath, out_fmt, extra_path)
    def open_folder(self, path): os.startfile(path); return "Opened"

    def start_backsound(self):
        def task():
            res = self.engine.ensure_backsound(self._cb)
            if res in ["Success", "Exists"]:
                self._window.evaluate_js("window.init_backsound()")
        threading.Thread(target=task, daemon=True).start()
        return "Start"

    def start_download(self, urls, opts):
        threading.Thread(target=self._dl_thread, args=(urls, opts), daemon=True).start()
        return "Started"

    def _dl_thread(self, urls, opts):
        success = self.engine.download(urls, opts, self._cb)
        if not self.engine.is_paused and not self.engine.is_cancelled:
            if success: self._window.evaluate_js("window.dl_finish('Selesai!')")
            else: self._window.evaluate_js("window.dl_finish('Gagal.')")

    def _cb(self, percent, status, speed, eta):
        self._window.evaluate_js(f"window.up_prog({percent}, '{status}', '{speed}', '{eta}')")

    def pause_download(self):
        self.engine.pause_download()
        self._window.evaluate_js("window.update_ui_paused()")
        return "Paused"

    def resume_download(self):
        threading.Thread(target=self._dl_thread, args=(self.engine.current_urls, self.engine.current_opts), daemon=True).start()
        return "Resumed"

    def cancel_download(self):
        self.engine.is_cancelled = True
        if self.engine.current_process:
            import subprocess
            subprocess.run(["taskkill", "/F", "/T", "/PID", str(self.engine.current_process.pid)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        self._window.evaluate_js("window.dl_cancelled()")
        return "Cancelled"

    def get_clipboard(self):
        try:
            import tkinter as tk
            r = tk.Tk(); r.withdraw()
            c = r.clipboard_get(); r.destroy(); return c
        except: return ""

if __name__ == '__main__':
    api = Api()
    window = webview.create_window('YouTube Downloader Pro v21', 'web/index.html', js_api=api, width=950, height=850, frameless=True, transparent=True)
    api.set_window(window)
    webview.start()