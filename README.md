# LAN Media Remote

A **mobile-friendly web interface** to control media playback on your PC over your local network (LAN).

The server displays your PC’s **LAN IP and port** on startup so you can open the remote on your phone immediately.

Works on **Windows, macOS, and Linux** using **Enigo** for cross-platform media key support.

---

## Features

* Mobile-optimized interface
* Playback and media controls:
  * Play / Pause
  * Volume Up / Down
  * Mute (toggle)
  * Seek Forward / Back (**macOS-only in current build**)
  * Previous / Next track
* Navigation controls:
  * Up / Down / Left / Right
  * Enter
* App-specific remotes:
  * YouTube remote with playback, full screen/theatre/captions/mini player, mute, search, and playlist shortcuts
  * Switch remotes from the dropdown in the header, or open `/youtube` directly
* Minimal, fast, and responsive
* Works over LAN
* Displays your PC’s LAN IP on startup
* Supports a custom port via first CLI argument
* Backend built with **Rust + Axum + Enigo**

---

## Requirements

* LAN connection between PC and mobile device
* Start up IP detection currently probes route info via `8.8.8.8:80`; if that path is blocked, start up may fail in the current version

---

## Installation

### Option a: Install Prebuilt Binaries (Recommended)

**macOS / Linux (latest):**

```bash
curl -fsSL https://raw.githubusercontent.com/StanleyMasinde/LAN-remote/main/install.sh | sh
```

**macOS / Linux (specific version):**

```bash
curl -fsSL https://raw.githubusercontent.com/StanleyMasinde/LAN-remote/main/install.sh | sh -s v1.0.0
```

**Windows PowerShell (latest):**

```powershell
& ([scriptblock]::Create((irm "https://raw.githubusercontent.com/StanleyMasinde/LAN-remote/main/install.ps1")))
```

**Windows PowerShell (specific version):**

```powershell
& ([scriptblock]::Create((irm "https://raw.githubusercontent.com/StanleyMasinde/LAN-remote/main/install.ps1"))) -Version v1.0.0
```

Custom install directory:

- Unix: set `LAN_REMOTE_INSTALL`, example:

```bash
curl -fsSL https://raw.githubusercontent.com/StanleyMasinde/LAN-remote/main/install.sh | LAN_REMOTE_INSTALL=~/.local/bin sh
```

- PowerShell: use `-InstallDir` or set `LAN_REMOTE_INSTALL`, example:

```powershell
& ([scriptblock]::Create((irm "https://raw.githubusercontent.com/StanleyMasinde/LAN-remote/main/install.ps1"))) -InstallDir "$HOME\\bin"
```

---

### Option B: Build from Source

1. Install Rust from [rustup.rs](https://rustup.rs/).
2. Build:

```bash
cargo build --release
```

3. Run:

```bash
cargo run --release
```

Run on a custom port:

```bash
cargo run --release -- 8080
```

---

### Open the Remote

* On your phone (connected to the same LAN), open:

  ```
  http://<PC_LAN_IP>:<PORT>
  ```
* Use the buttons to control media on your PC.
* YouTube remote: open `http://<PC_LAN_IP>:<PORT>/youtube`, or pick "YouTube" in the header dropdown on the main remote. Your browser must be focused on the YouTube tab, since the remote types shortcuts into the focused window.
* Default port is `3000` if you do not pass an argument.

---

## Supported Actions

| Button / Action | Function | Availability |
| --------------- | -------- | ------------ |
| Play / Pause | Start or pause media | Windows / macOS / Linux |
| Seek Backward | Skip backward | macOS only (current build) |
| Seek Forward | Skip forward | macOS only (current build) |
| Volume Up | Increase volume | Windows / macOS / Linux |
| Volume Down | Decrease volume | Windows / macOS / Linux |
| Mute Toggle | Toggle mute on/off | Windows / macOS / Linux |
| Previous | Previous track/chapter | Windows / macOS / Linux |
| Next | Next track/chapter | Windows / macOS / Linux |
| Up / Down / Left / Right | Directional navigation | Windows / macOS / Linux |
| Enter | Confirm/select | Windows / macOS / Linux |

### YouTube Remote (`/youtube`)

Sends YouTube keyboard shortcuts to the focused window, so keep your browser focused on the YouTube tab. Buttons post a single character to `POST /custom` (example: `{"key": "k"}`).

| Button | Shortcut sent | Function |
| ------ | ------------- | -------- |
| Back 10 seconds | J | Skip backward 10 seconds |
| Play / Pause | K | Start or pause video |
| Forward 10 seconds | L | Skip forward 10 seconds |
| Full screen | F | Toggle full screen |
| Theatre | T | Toggle theatre mode |
| Captions | C | Toggle captions |
| Mini-player | I | Toggle mini player |
| Mute | M | Mute/unmute the YouTube player |
| Search | / | Focus search |
| Previous | ⇧ P | Previous video in playlist |
| Next | ⇧ N | Next video in playlist |

---

## Notes

* The **Mute button is stateless** — it always sends a toggle command.
* App-specific remotes (like YouTube) type keystrokes into **whichever window is focused** — they do not target an app directly, so keep the right window focused.
* Your phone and PC must be **on the same LAN**.
* Designed for LAN use only; not intended to be exposed to the internet.
* Works on **Windows, macOS, and Linux**.
* **Rust toolchain is only required when building from source**.
* `install.ps1` adds the install directory to user `PATH` on Windows if missing.
* On startup, the server accepts one optional positional argument: `port`.
* If binding fails, the app exits with a clear error for:
  * permission denied (for example, privileged ports)
  * address already in use

---

## Tips

* Keep the remote open on your phone for instant media control.
* Works with music players, video players, and streaming apps that respond to standard media keys.

---

## License

MIT License
