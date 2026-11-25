# Anki Desktop Docker (KasmVNC)

[![Build and Push](https://github.com/SomeonesGon/anki-desktop-docker/actions/workflows/build.yml/badge.svg)](https://github.com/SomeonesGon/anki-desktop-docker/actions/workflows/build.yml)

> Forked from [chrislongros/anki-desktop-docker](https://github.com/chrislongros/anki-desktop-docker), updated for Anki 26.x with auto-installed AnkiConnect, Anki Beacon, and Local Audio for Yomichan.

High-performance browser-accessible Anki Desktop using [LinuxServer's KasmVNC](https://github.com/linuxserver/docker-baseimage-kasmvnc) for optimal streaming performance.

**🆕 Supports Anki 26.x with its self-contained bundle format (no launcher, no system Python required).**

![Anki Desktop Docker Screenshot](https://raw.githubusercontent.com/chrislongros/anki-desktop-docker/main/.github/screenshot.png)

## Features

- 🚀 **High Performance** - KasmVNC provides WebP compression and adaptive encoding for smooth browser experience
- 🆕 **Anki 26.x** - Uses Anki's self-contained bundle (no system Python, no launcher)
- 🌐 **Browser Access** - No VNC client needed, just open your browser
- 🔄 **Custom Sync Server** - Configure your own Anki sync server via environment variable
- 🔌 **AnkiConnect Built-in** - Auto-installed and pre-configured on port 8765
- 📡 **Anki Beacon Built-in** - Auto-installed webhook emitter for event-driven integrations
- 🔊 **Local Audio for Yomichan Built-in** - Auto-installed and pre-configured on port 5050
- 📦 **Multi-arch** - Supports both amd64 and arm64 platforms
- 🔒 **Secure** - Optional HTTPS support on port 3001
- 💾 **Persistent Data** - Volume mount preserves all Anki data
- ❤️ **Healthcheck** - Built-in container health monitoring

## Comparison with Other Projects

| Feature | This Project | Others |
|---------|--------------|--------|
| Anki Version | **26.x (latest)** | Pinned to old versions |
| VNC Technology | **KasmVNC** (high performance) | noVNC (basic) |
| AnkiConnect | **Auto-installed & pre-configured** | Manual setup |
| Anki Beacon | **Auto-installed** | ❌ None |
| Local Audio (Yomichan/Yomitan) | **Auto-installed & pre-configured** | Manual setup |
| System Python | **Not required** (self-contained) | Required |
| Healthcheck | **✅ Built-in** | ❌ None |
| Multi-arch | **✅ amd64 + arm64** | Often amd64 only |

## Quick Start

### Docker Run

```bash
docker run -d \
  --name anki-desktop \
  -p 3000:3000 \
  -p 8765:8765 \
  -p 5050:5050 \
  -v anki_data:/config \
  --security-opt seccomp=unconfined \
  --shm-size=1gb \
  ghcr.io/someonesgon/anki-desktop-docker:latest
```

Then open **http://localhost:3000** in your browser.

### Docker Compose

```yaml
services:
  anki-desktop:
    image: ghcr.io/someonesgon/anki-desktop-docker:latest
    container_name: anki-desktop
    ports:
      - "3000:3000"    # HTTP
      - "3001:3001"    # HTTPS (optional)
      - "8765:8765"    # AnkiConnect API
      - "7275:7275"    # Anki Beacon webhook (optional)
      - "5050:5050"    # Local Audio Server (Yomichan/Yomitan)
    volumes:
      - anki_data:/config
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Berlin
      # Optional: Custom sync server
      # - ANKI_SYNC_SERVER=http://your-sync-server:8080
    security_opt:
      - seccomp=unconfined
    shm_size: 1gb
    restart: unless-stopped

volumes:
  anki_data:
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PUID` | `1000` | User ID for file permissions |
| `PGID` | `1000` | Group ID for file permissions |
| `TZ` | `UTC` | Timezone |
| `ANKI_SYNC_SERVER` | - | Custom Anki sync server URL (e.g., `http://192.168.1.100:8080`) |
| `CUSTOM_PORT` | `3000` | HTTP port |
| `CUSTOM_HTTPS_PORT` | `3001` | HTTPS port |
| `ANKICONNECT_ENABLED` | `true` | Auto-install and configure AnkiConnect |
| `ANKICONNECT_PORT` | `8765` | Port AnkiConnect listens on |
| `ANKIBEACON_ENABLED` | `true` | Auto-install Anki Beacon |
| `ANKIBEACON_URL` | - | Webhook URL Anki Beacon posts events to (uses addon default if unset) |
| `LOCALAUDIO_ENABLED` | `true` | Auto-install Local Audio Server for Yomichan |
| `LOCALAUDIO_PORT` | `5050` | Port Local Audio Server listens on |

## Ports

| Port | Description |
|------|-------------|
| `3000` | HTTP web interface |
| `3001` | HTTPS web interface |
| `8765` | AnkiConnect API |
| `7275` | Anki Beacon webhook (default; expose only if your receiver is on the host) |
| `5050` | Local Audio Server for Yomichan/Yomitan |

## Volumes

| Path | Description |
|------|-------------|
| `/config` | Anki data and settings - **must be persisted** |

## Upgrading Anki Version

To upgrade to a newer Anki release, rebuild the image with the new version:

```bash
docker build --build-arg ANKI_VERSION=26.09.4 -t anki-desktop .
```

Or set it in `docker-compose.yml`:

```yaml
build:
  context: ./
  args:
    ANKI_VERSION: "26.09.4"
```

## Custom Sync Server

To use your own [anki-sync-server](https://github.com/ankitects/anki/tree/main/rslib/sync), set the `ANKI_SYNC_SERVER` environment variable:

```bash
docker run -d \
  --name anki-desktop \
  -p 3000:3000 \
  -v anki_data:/config \
  -e ANKI_SYNC_SERVER=http://192.168.1.100:8080 \
  --security-opt seccomp=unconfined \
  --shm-size=1gb \
  ghcr.io/someonesgon/anki-desktop-docker:latest
```

## CJK Font Support

To add Chinese, Japanese, or Korean font support:

```yaml
environment:
  - DOCKER_MODS=linuxserver/mods:universal-package-install
  - INSTALL_PACKAGES=fonts-noto-cjk
```

## Building Locally

```bash
git clone https://github.com/SomeonesGon/anki-desktop-docker.git
cd anki-desktop-docker
docker build -t anki-desktop .
```

## TrueNAS SCALE Deployment

For TrueNAS SCALE users, create a custom app with these settings:

```yaml
Container Image: ghcr.io/someonesgon/anki-desktop-docker:latest
Security Context:
  - seccomp: unconfined
Resources:
  - Shared Memory Size: 1Gi
Ports:
  - 3000:3000 (Web UI)
  - 8765:8765 (AnkiConnect)
  - 7275:7275 (Anki Beacon, optional)
  - 5050:5050 (Local Audio Server, optional)
Storage:
  - Host Path or PVC → /config
Environment:
  - PUID: 1000
  - PGID: 1000
  - TZ: Europe/Berlin
  - ANKI_SYNC_SERVER: http://your-sync-server:8080 (optional)
```

## Technical Details

### Why KasmVNC?

Traditional noVNC setups suffer from high latency and poor image quality. KasmVNC provides:
- WebP adaptive compression
- Low-latency streaming optimized for web browsers
- Better color reproduction
- Reduced bandwidth usage

### Anki 26.x Bundle Format

Anki 26.x ships as a self-contained tarball with:
- A native ELF binary (`anki`) that embeds its own Python 3.13 launcher
- A bundled `python/` runtime (no system Python needed)
- All app packages included

This project installs the bundle to `/opt/anki/` at build time. No launcher download step, no first-run setup dialog.

### Required Docker Flags

- `--security-opt seccomp=unconfined` - Required for Qt/Chromium sandboxing
- `--shm-size=1gb` - Prevents shared memory issues with Qt WebEngine

## Troubleshooting

### Black screen / Anki won't start
Check container logs: `docker logs anki-desktop`

Common fixes:
- Ensure `--security-opt seccomp=unconfined` is set
- Ensure `--shm-size=1gb` is set
- Try restarting the container

### Slow performance
- Click the gear icon in KasmVNC toolbar to adjust quality settings
- Reduce video quality for slower networks

### AnkiConnect

AnkiConnect is **auto-installed and pre-configured**. Port 8765 is already exposed. No manual steps required.

Test it:
```bash
curl http://localhost:8765 -X POST -d '{"action": "version", "version": 6}'
```

To disable AnkiConnect:
```yaml
environment:
  - ANKICONNECT_ENABLED=false
```

### Anki Beacon

[Anki Beacon](https://ankiweb.net/shared/info/1577021707) is **auto-installed**. It emits webhook events (e.g. `note_added`) to configurable HTTP endpoints, so external tools can react to Anki events without polling AnkiConnect.

By default it uses the addon's own built-in config (`http://127.0.0.1:7275/anki/events`). To point it at a different URL, set `ANKIBEACON_URL`:

```yaml
environment:
  - ANKIBEACON_URL=http://my-automation-server:7275/anki/events
```

Anki Beacon POSTs JSON events like:
```json
{"type": "note_added", "note_id": 123456789}
```

For advanced configuration (multiple URLs, heartbeat intervals, custom headers), edit the config directly at `anki_data/.local/share/Anki2/addons21/1577021707/config.json` or via **Tools → Add-ons → Anki Beacon → Config** inside Anki.

To disable Anki Beacon:
```yaml
environment:
  - ANKIBEACON_ENABLED=false
```

### Local Audio Server for Yomichan

[Local Audio Server for Yomichan](https://github.com/yomidevs/local-audio-yomichan) is **auto-installed** and configured to bind to `0.0.0.0:5050` so it works with Docker port mapping (`-p 5050:5050`) while still returning `http://127.0.0.1:5050/...` URLs to Yomitan/Yomichan on your host browser.

When upgrading from an older image, the add-on is added into your existing `/config` volume on startup without modifying your profiles, decks, or other add-ons. Any custom keys in `config.json` (such as `sources`) are preserved while `port` stays synced to `LOCALAUDIO_PORT`.

#### Setup

1. **Expose port `5050`** in your `docker run` command or `docker-compose.yml` (`-p 5050:5050`).
2. **Download your audio collections** (e.g., `nhk16_files`, `shinmeikai8_files`, `forvo_files`, `jpod_files`, `jpod_alternate_files`, `ozk5_files`, and optionally `jmdict_forms.json`) following the [yomidevs/local-audio-yomichan](https://github.com/yomidevs/local-audio-yomichan#installation) instructions.
3. **Place the extracted folders/files** inside your persistent `/config` volume under:
   ```
   anki_data/.local/share/Anki2/addons21/local-audio-yomichan/user_files/
   ```
   For example:
   ```
   anki_data/.local/share/Anki2/addons21/local-audio-yomichan/user_files/
   ├── forvo_files/
   ├── jmdict_forms.json        # optional
   ├── jpod_alternate_files/
   ├── jpod_files/
   ├── nhk16_files/
   ├── ozk5_files/
   └── shinmeikai8_files/
   ```
4. **Regenerate the audio database**:
   - In Anki (via the web UI at `http://localhost:3000`), go to **Tools → Local Audio Server → Regenerate database** (or **Show statistics** to verify indexed entries).
   - If you placed the files before starting the container for the first time, the database is generated automatically on startup.
5. **Configure Yomitan / Yomichan** in your browser:
   - Open Yomitan Settings → **Audio** → **Configure audio playback sources**.
   - Add a **Custom URL (JSON)** source with URL:
     ```
     http://localhost:5050/?term={term}&reading={reading}
     ```

#### Testing & Customization

Test the server from your host:
```bash
curl http://localhost:5050/
curl "http://localhost:5050/?term=読む&reading=よむ"
```

To use a custom port (updates `config.json` `"port"` without overwriting custom `"sources"`):
```yaml
environment:
  - LOCALAUDIO_PORT=5051
ports:
  - "5051:5051"
```

To disable it:
```yaml
environment:
  - LOCALAUDIO_ENABLED=false
```

## License

MIT License - see [LICENSE](LICENSE)

## Credits

- [Anki](https://apps.ankiweb.net/) - Powerful, intelligent flashcards
- [LinuxServer.io](https://www.linuxserver.io/) - KasmVNC base image
- [KasmVNC](https://kasmweb.com/kasmvnc) - High-performance VNC
- [AnkiConnect](https://github.com/FooSoft/anki-connect) - Anki API addon by FooSoft
- [Anki Beacon](https://github.com/bpwhelan/AnkiBeacon) - Webhook event emitter by bpwhelan
- [Local Audio for Yomichan](https://github.com/yomidevs/local-audio-yomichan) - Local audio server addon by yomidevs
