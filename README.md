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

* Rust toolchain installed (via [rustup](https://rustup.rs/))
* LAN connection between PC and mobile device

---

## Installation

### 1. Install Rust

**Windows:**

* Download and run the installer from [rustup.rs](https://rustup.rs/)
* Follow the prompts to install Rust and Cargo

**macOS / Linux:**

* Open a terminal and run:

  ```bash
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  ```
* Follow the on-screen instructions

Verify installation:

```bash
rustc --version
cargo --version
```

---

### 2. Build the server

Open a terminal (or PowerShell on Windows) in the project directory:

```bash
cargo build --release
```

---

### 3. Run the server

```bash
cargo run --release
```

On startup, the terminal will display your LAN IP and port, for example:

```
Server running on http://192.168.100.27:3000
```

---

### 4. Open the remote

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
* **Rust toolchain is required** to build and run the server.

---

## Tips

* Keep the remote open on your phone for instant media control.
* Works with music players, video players, and streaming apps that respond to standard media keys.

---

## License

MIT License
