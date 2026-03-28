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

#[derive(Deserialize)]
struct KeyRequest {
    key: String,
}

async fn handle_keys(Json(payload): Json<KeyRequest>) -> String {
    let mut enigo = Enigo::new(&Settings::default()).unwrap();

    let key = match payload.key.as_str() {
        "space" => Key::Space,
        "enter" => Key::Return,
        "left" => Key::LeftArrow,
        "right" => Key::RightArrow,
        "volume_up" => Key::VolumeUp,
        "volume_down" => Key::VolumeDown,
        "mute_toggle" => Key::VolumeMute,
        _ => return "Unknown".to_string(),
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
