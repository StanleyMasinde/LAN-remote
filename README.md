# LAN Media Remote

A **mobile-friendly web interface** to control media playback on your PC over your local network (LAN).

The server displays your PC’s **LAN IP and port** on startup so you can open the remote on your phone immediately.

Works on **Windows, macOS, and Linux** using **Enigo** for cross-platform media key support.

---

## Features

* Mobile-optimized interface
* Media controls:

  * Play / Pause
  * Seek Forward / Back
  * Volume Up / Down
  * Mute (toggle)
* Minimal, fast, and responsive
* Works over LAN — no internet required
* Displays your PC’s LAN IP on startup
* Backend built with **Rust + Axum + Enigo**

---

## Requirements

* LAN connection between PC and mobile device

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
iwr https://raw.githubusercontent.com/StanleyMasinde/LAN-remote/main/install.ps1 -OutFile install.ps1
.\install.ps1
```

**Windows PowerShell (specific version):**

```powershell
iwr https://raw.githubusercontent.com/StanleyMasinde/LAN-remote/main/install.ps1 -OutFile install.ps1
.\install.ps1 -Version v1.0.0
```

Custom install directory:

- Unix: set `LAN_REMOTE_INSTALL`, example:

```bash
curl -fsSL https://raw.githubusercontent.com/StanleyMasinde/LAN-remote/main/install.sh | LAN_REMOTE_INSTALL=~/.local/bin sh
```

- PowerShell: use `-InstallDir` or set `LAN_REMOTE_INSTALL`, example:

```powershell
.\install.ps1 -InstallDir "$HOME\\bin"
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

---

### Open the remote

* On your phone (connected to the same LAN), open:

  ```
  http://<PC_LAN_IP>:3000
  ```
* Use the buttons to control media on your PC.

---

## Supported Media Actions

| Button / Action | Function             |
| --------------- | -------------------- |
| Play / Pause    | Start or pause media |
| Seek Backward   | Skip backward        |
| Seek Forward    | Skip forward         |
| Volume Up       | Increase volume      |
| Volume Down     | Decrease volume      |
| Mute Toggle     | Toggle mute on/off   |

---

## Notes

* The **Mute button is stateless** — it always sends a toggle command.
* Your phone and PC must be **on the same LAN**.
* Designed for LAN use only; not exposed to the internet.
* Works on **Windows, macOS, and Linux**.
* **Rust toolchain is only required when building from source**.
* `install.ps1` adds the install directory to user `PATH` on Windows if missing.

---

## Tips

* Keep the remote open on your phone for instant media control.
* Works with music players, video players, and streaming apps that respond to standard media keys.

---

## License

MIT License
