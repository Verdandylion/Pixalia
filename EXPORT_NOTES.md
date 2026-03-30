# Export Notes

## Windows Desktop Export

### One-Time Setup

1. Open your project in **Godot 4**.
2. Go to **Project → Export…**
3. If no export templates are installed, click **Manage Export Templates** and download the templates matching your Godot version.
4. Click **Add…** and select **Windows Desktop**.

### Exporting

1. In the Export dialog, select the **Windows Desktop** preset.
2. Set **Export Path** (e.g., `build/windows/Pixalia.exe`).
3. Make sure **Embed PCK** is enabled if you want a single `.exe` file.
4. Click **Export Project**.
5. Distribute the `.exe` (and any `.pck` if not embedded) to players.

### Notes

- You do **not** need Visual Studio or any compiler. Godot provides self-contained export templates.
- For a Windows build on Linux/macOS, the Windows export template handles cross-compilation automatically.
- The game uses only Godot built-in features — no DLLs or addons to bundle.

---

## Web Export (Optional)

### One-Time Setup

1. Download the **Web** export template from Godot's template manager.
2. Add a **Web** preset in the Export dialog.

### Exporting

1. Select the **Web** preset and set an export path (e.g., `build/web/index.html`).
2. Click **Export Project**.
3. Upload all generated files (`index.html`, `index.js`, `index.wasm`, `index.pck`, `index.audio.worklet.js`) to your web server.

### CORS / Browser Requirements

The Godot 4 Web export requires the following HTTP headers on the server to function correctly:

```
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Embedder-Policy: require-corp
```

Without these headers, `SharedArrayBuffer` (required by the Web export) will not be available and the game will fail to load.

For quick local testing, use Python:

```bash
# Python 3.11+ simple CORS server
python -m http.server 8000
```

Or use the [Godot Web Serve](https://godotengine.org/article/godot-web-export/) script from the official docs.

### GitHub Pages / Netlify

- **GitHub Pages**: Does not support the required COOP/COEP headers without a service-worker workaround.
- **Netlify**: Add a `_headers` file to set the required headers.
- **itch.io**: Supports SharedArrayBuffer via their iframe sandbox.
