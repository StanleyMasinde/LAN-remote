use axum::{
    Json, Router,
    response::Html,
    routing::{get, post},
};
use enigo::{Enigo, Key, Keyboard, Settings};
use rust_embed::Embed;
use serde::Deserialize;
use serde_json::json;
use tokio::net::UdpSocket;

#[tokio::main(flavor = "current_thread")]
async fn main() {
    run_server().await
}

#[derive(Embed)]
#[folder = "src/assets/"]
struct Asset;

async fn get_local_ip() -> Option<String> {
    let socket = UdpSocket::bind("0.0.0.0:0")
        .await
        .expect("Failed to connect to the local DNS.");
    socket
        .connect("8.8.8.8:80")
        .await
        .expect("Could not connect to Google DNS");
    socket.local_addr().ok().map(|addr| addr.ip().to_string())
}

async fn index_handler() -> Html<Vec<u8>> {
    let index_page = Asset::get("index.html")
        .expect("Index.html is missing.")
        .data
        .to_vec();

    Html(index_page)
}

#[derive(Debug, Deserialize)]
pub enum RemoteKey {
    #[serde(rename = "volume_up")]
    VolumeUp,
    #[serde(rename = "volume_down")]
    VolumeDown,
    #[serde(rename = "PlayPause")]
    PlayPause,
    #[cfg(not(target_os = "windows"))]
    #[cfg(not(target_os = "linux"))]
    #[serde(rename = "seek_left")]
    SeekLeft,
    #[cfg(not(target_os = "windows"))]
    #[cfg(not(target_os = "linux"))]
    #[serde(rename = "seek_right")]
    SeekRight,
    #[serde(rename = "up")]
    Up,
    #[serde(rename = "down")]
    Down,
    #[serde(rename = "left")]
    Left,
    #[serde(rename = "right")]
    Right,
    #[serde(rename = "previous")]
    Previous,
    #[serde(rename = "next")]
    Next,
    #[serde(rename = "mute_toggle")]
    MuteToggle,
    #[serde(rename = "enter")]
    Enter,
}

#[derive(Deserialize)]
struct KeyRequest {
    key: RemoteKey,
}

async fn handle_keys(Json(payload): Json<KeyRequest>) -> String {
    let mut enigo = Enigo::new(&Settings::default()).unwrap();

    let key = match payload.key {
        RemoteKey::VolumeUp => Key::VolumeUp,
        RemoteKey::VolumeDown => Key::VolumeDown,
        RemoteKey::PlayPause => Key::MediaPlayPause,
        #[cfg(not(target_os = "windows"))]
        #[cfg(not(target_os = "linux"))]
        RemoteKey::SeekLeft => Key::MediaRewind,
        #[cfg(not(target_os = "windows"))]
        #[cfg(not(target_os = "linux"))]
        RemoteKey::SeekRight => Key::MediaFast,
        RemoteKey::Up => Key::UpArrow,
        RemoteKey::Down => Key::DownArrow,
        RemoteKey::Left => Key::LeftArrow,
        RemoteKey::Right => Key::RightArrow,
        RemoteKey::Previous => Key::MediaPrevTrack,
        RemoteKey::Next => Key::MediaNextTrack,
        RemoteKey::MuteToggle => Key::VolumeMute,
        RemoteKey::Enter => Key::Return,
    };

    enigo.key(key, enigo::Direction::Press).unwrap();

    json!({"message": "cool"}).to_string()
}

async fn run_server() {
    let mut local_ip = "0.0.0.0".to_string();

    if let Some(ip) = get_local_ip().await {
        local_ip = ip;
    }
    let app = Router::new()
        .route("/", get(index_handler))
        .route("/key", post(handle_keys));
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    let local_addr = listener.local_addr().unwrap();

    println!(
        "Server running on http://{}:{}",
        local_ip,
        local_addr.port()
    );

    axum::serve(listener, app).await.unwrap();
}
