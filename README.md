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
* Minimal, fast, and responsive
* Works over LAN
* Displays your PC’s LAN IP on startup
* Supports a custom port via first CLI argument
* Backend built with **Rust + Axum + Enigo**

---

## Requirements

* LAN connection between PC and mobile device
* Startup IP detection currently probes route info via `8.8.8.8:80`; if that path is blocked, startup may fail in the current version

---

## Installation

### Option A: Install prebuilt binaries (recommended)

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

### Option B: Build from source

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

### Open the remote

* On your phone (connected to the same LAN), open:

  ```
  http://<PC_LAN_IP>:<PORT>
  ```
* Use the buttons to control media on your PC.
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

---

## Notes

* The **Mute button is stateless** — it always sends a toggle command.
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
