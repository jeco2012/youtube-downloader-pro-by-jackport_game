const audio = document.getElementById('bg-music');
let isMuted = false;
let audioUnlocked = false;
let currentMode = 'video';
let remoteUpdateUrl = "";

document.addEventListener('click', () => {
    if (!audioUnlocked && audio.src) {
        audio.volume = 0.35;
        audio.play().then(() => { audioUnlocked = true; }).catch(e => console.log("Audio blocked:", e));
    }
});

window.addEventListener('pywebviewready', async () => {
    let conf = await pywebview.api.load_settings();
    document.getElementById('out-path').value = conf.OutPath || "";
    document.getElementById('set-threads').value = conf.MaxThreads || 5;
    document.getElementById('set-def-mode').value = conf.DefaultMode || "video";
    
    document.getElementById('opt-cookie').checked = conf.UseCookies || false;
    document.getElementById('opt-subs').value = conf.SubIdx !== undefined ? conf.SubIdx : 3;
    document.getElementById('opt-dubbing').value = conf.DubIdx !== undefined ? conf.DubIdx : 0;
    
    setMode(conf.DefaultMode || "video");

    isMuted = conf.IsMuted || false;
    audio.muted = isMuted;
    document.getElementById('btn-music').innerText = isMuted ? "🔇" : "🔊";
    
    pywebview.api.start_backsound();

    let lastClip = "";
    setInterval(async () => {
        try {
            let clip = await pywebview.api.get_clipboard();
            if (clip && clip !== lastClip && clip.startsWith("http")) {
                lastClip = clip;
                let input = document.getElementById("url-input");
                input.value += (input.value ? "\n" : "") + clip;
            }
        } catch(e) {}
    }, 1500);

    // === AUTO UPDATE CHECKER ===
    let upd = await pywebview.api.check_update();
    if (upd.status === "update_available") {
        remoteUpdateUrl = upd.url;
        document.getElementById("update-changelog").innerText = `Versi Baru: ${upd.version}\n\nCatatan Rilis:\n${upd.changelog}`;
        document.getElementById("modal-update").classList.remove("hidden");
    }
});

window.init_backsound = async () => {
    let b64 = await pywebview.api.get_backsound_b64();
    if (b64) {
        audio.src = "data:audio/mp3;base64," + b64;
        audio.load();
        audio.play().then(() => audioUnlocked = true).catch(e => console.log("Menunggu klik user."));
    }
};

function toggleMusic() {
    const btn = document.getElementById('btn-music');
    if (isMuted) { audio.muted = false; isMuted = false; btn.innerText = "🔊"; }
    else { audio.muted = true; isMuted = true; btn.innerText = "🔇"; }
    pywebview.api.save_settings({ IsMuted: isMuted });
}

function setMode(mode) {
    currentMode = mode;
    const slider = document.getElementById('mode-slider');
    const btnVid = document.getElementById('btn-mode-video');
    const btnAud = document.getElementById('btn-mode-audio');
    
    if (mode === 'video') {
        slider.classList.remove('audio-mode');
        btnVid.classList.add('active'); btnAud.classList.remove('active');
        document.getElementById('grp-video').style.opacity = "1";
        document.getElementById('grp-video').style.pointerEvents = "auto";
        document.getElementById('grp-audio').style.opacity = "0.35";
        document.getElementById('grp-audio').style.pointerEvents = "none";
    } else {
        slider.classList.add('audio-mode');
        btnAud.classList.add('active'); btnVid.classList.remove('active');
        document.getElementById('grp-video').style.opacity = "0.35";
        document.getElementById('grp-video').style.pointerEvents = "none";
        document.getElementById('grp-audio').style.opacity = "1";
        document.getElementById('grp-audio').style.pointerEvents = "auto";
    }
}

function setTheme(t) { document.body.setAttribute('data-theme', t); }
function switchTab(id, btn) {
    document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
    document.querySelectorAll('.tab-btn').forEach(el => el.classList.remove('active'));
    document.getElementById('tab-' + id).classList.add('active');
    btn.classList.add('active');
}
function applyPreset() { setMode('video'); document.getElementById('vid-res').value = "3"; document.getElementById('opt-force').checked = true; }

async function browseFolder() {
    let path = await pywebview.api.browse_folder();
    if (path) document.getElementById('out-path').value = path;
}

async function fetchInfo() {
    let urls = document.getElementById('url-input').value.trim();
    if (!urls) return alert("Isi link dulu!");
    
    let firstUrl = urls.split("\n")[0].trim();
    document.getElementById('info-card').classList.remove('hidden');
    document.getElementById('info-title').innerText = "Memuat info...";
    document.getElementById('info-meta').innerText = "";
    document.getElementById('info-desc').innerText = "";
    document.getElementById('info-thumb').src = "";
    
    let info = await pywebview.api.get_info(firstUrl);
    if (info) {
        document.getElementById('info-thumb').src = info.thumbnail;
        document.getElementById('info-title').innerText = info.title;
        document.getElementById('info-meta').innerText = `${info.uploader} • ${info.views} views • ${info.duration}`;
        document.getElementById('info-desc').innerText = info.desc;
    } else {
        document.getElementById('info-title').innerText = "Gagal mengambil info.";
    }
}

async function importTxt() {
    let path = await pywebview.api.open_file_dialog("text");
    if (path) {
        let urls = await pywebview.api.import_txt(path);
        if (urls) document.getElementById('url-input').value = urls;
    }
}

function clearAll() {
    document.getElementById('url-input').value = "";
    document.getElementById('console-log').value = "";
    document.getElementById('prog-bar').style.width = "0%";
    document.getElementById('stat-text').innerText = "STANDBY";
    document.getElementById('speed-text').innerText = "0.00 MB/s";
    document.getElementById('eta-text').innerText = "0m 0d";
    document.getElementById('queue-text').innerText = "0 / 0";
    document.getElementById('info-card').classList.add('hidden');
}

async function runToolAction(action, type) {
    let path = await pywebview.api.open_file_dialog(type);
    if (!path) return;
    
    if (action === 'info') {
        document.getElementById('modal-info').classList.remove('hidden');
        document.getElementById('info-content').innerText = "Mengambil data...";
        let res = await pywebview.api.run_tool('info', path);
        document.getElementById('info-content').innerText = res;
    } else {
        let res = await pywebview.api.run_tool(action, path);
        alert(res);
    }
}

async function runMergeAction() {
    let vPath = await pywebview.api.open_file_dialog('video');
    if (!vPath) return;
    let aPath = await pywebview.api.open_file_dialog('audio');
    if (!aPath) return;
    let res = await pywebview.api.run_tool('merge', vPath, '', aPath);
    alert(res);
}

function closeModal() { document.getElementById('modal-info').classList.add('hidden'); }

async function saveSettings() {
    let threads = parseInt(document.getElementById('set-threads').value);
    let defMode = document.getElementById('set-def-mode').value;
    await pywebview.api.save_settings({ MaxThreads: threads, DefaultMode: defMode });
    alert("Pengaturan disimpan!");
}

async function clearCache() {
    let res = await pywebview.api.clear_cache();
    alert(res);
}

async function startDl() {
    const urls = document.getElementById('url-input').value.trim();
    if (!urls) return alert("Link kosong!");
    
    const opts = {
        ModeVideo: currentMode === 'video',
        VidResIdx: parseInt(document.getElementById('vid-res').value),
        VidFmtIdx: parseInt(document.getElementById('vid-fmt').value),
        AudFmtIdx: parseInt(document.getElementById('aud-fmt').value),
        AudBitIdx: parseInt(document.getElementById('aud-bit').value),
        DubIdx: parseInt(document.getElementById('opt-dubbing').value),
        SubIdx: parseInt(document.getElementById('opt-subs').value),
        Playlist: document.getElementById('opt-playlist').checked,
        Resume: document.getElementById('opt-resume').checked,
        Sponsorblock: document.getElementById('opt-sponsor').checked,
        SubOnly: document.getElementById('opt-subonly').checked,
        UseCookies: document.getElementById('opt-cookie').checked,
        BrowserIdx: parseInt(document.getElementById('opt-browser').value),
        ForceMode: document.getElementById('opt-force').checked,
        KeepVideo: document.getElementById('opt-keepvideo').checked,
        AutoShutdown: document.getElementById('opt-shutdown').checked,
        OverwriteIdx: parseInt(document.getElementById('opt-overwrite').value),
        OutPath: document.getElementById('out-path').value,
        TrimStart: document.getElementById('trim-start').value,
        TrimEnd: document.getElementById('trim-end').value,
        MaxThreads: parseInt(document.getElementById('set-threads').value)
    };

    pywebview.api.save_settings(opts);
    
    document.getElementById('btn-start').classList.add('hidden');
    document.getElementById('btn-pause').classList.remove('hidden');
    document.getElementById('btn-cancel').classList.remove('hidden');
    document.getElementById('stat-text').innerText = "PROCESSING";
    document.getElementById('stat-text').style.color = "#ff3333";
    
    await pywebview.api.start_download(urls, opts);
}

async function pauseDl() {
    await pywebview.api.pause_download();
    document.getElementById('btn-pause').classList.add('hidden');
    document.getElementById('btn-resume').classList.remove('hidden');
    document.getElementById('stat-text').innerText = "PAUSED";
    document.getElementById('stat-text').style.color = "#ffb627";
}

async function resumeDl() {
    document.getElementById('btn-resume').classList.add('hidden');
    document.getElementById('btn-pause').classList.remove('hidden');
    document.getElementById('stat-text').innerText = "RESUMING...";
    document.getElementById('stat-text').style.color = "#00ff88";
    await pywebview.api.resume_download();
}

window.update_ui_paused = () => {
    document.getElementById('btn-pause').classList.add('hidden');
    document.getElementById('btn-resume').classList.remove('hidden');
}

window.dl_cancelled = () => {
    document.getElementById('btn-start').classList.remove('hidden');
    document.getElementById('btn-pause').classList.add('hidden');
    document.getElementById('btn-resume').classList.add('hidden');
    document.getElementById('btn-cancel').classList.add('hidden');
    document.getElementById('stat-text').innerText = "STANDBY";
    document.getElementById('stat-text').style.color = "white";
    document.getElementById('prog-bar').style.width = "0%";
    document.getElementById('console-log').value += "\n[INFO] Download dibatalkan.\n";
}

window.up_prog = (percent, status, speed, eta) => {
    if (percent === -1) {
        document.getElementById('queue-text').innerText = status;
        return;
    }
    document.getElementById('prog-bar').style.width = percent + '%';
    document.getElementById('speed-text').innerText = speed;
    document.getElementById('eta-text').innerText = eta;
    
    const timeStr = new Date().toLocaleTimeString('en-GB', { hour12: false });
    let log = document.getElementById('console-log');
    log.value += `[${timeStr}] ${status} (${percent.toFixed(1)}%)\n`;
    log.scrollTop = log.scrollHeight;
};

window.dl_finish = (msg) => {
    document.getElementById('btn-start').classList.remove('hidden');
    document.getElementById('btn-pause').classList.add('hidden');
    document.getElementById('btn-resume').classList.add('hidden');
    document.getElementById('btn-cancel').classList.add('hidden');
    document.getElementById('stat-text').innerText = "SELESAI";
    document.getElementById('stat-text').style.color = "#00ff00";
    alert(msg);
};

function closeUpdateModal() {
    document.getElementById("modal-update").classList.add("hidden");
}

async function doUpdate() {
    if (!remoteUpdateUrl) return;
    document.getElementById("update-changelog").innerText = "Mengunduh update...\nAplikasi akan menutup dan membuka kembali secara otomatis. Jangan tutup paksa proses ini.";
    document.querySelector('#modal-update .btn.primary').style.display = 'none';
    document.querySelector('#modal-update .btn.secondary').style.display = 'none';
    
    await pywebview.api.do_update(remoteUpdateUrl);
}

window.update_status = (msg) => {
    document.getElementById("update-changelog").innerText = msg;
};