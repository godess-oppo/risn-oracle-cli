use serde::{Deserialize, Serialize};
use std::path::PathBuf;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Config {
    pub ai_service_url: String,
    pub gateway_url: String,
    pub data_dir: PathBuf,
    pub temp_dir: PathBuf,
    pub android_optimized: bool,
    pub low_power_mode: bool,
}

impl Config {
    pub async fn load_default() -> Result<Self, Box<dyn std::error::Error>> {
        let data_dir = dirs::data_dir()
            .unwrap_or_else(|| PathBuf::from("/data/data/com.termux/files/home"))
            .join("fashionforge");
        
        let temp_dir = dirs::cache_dir()
            .unwrap_or_else(|| PathBuf::from("/data/data/com.termux/files/home"))
            .join("fashionforge-temp");
        
        // Create directories
        tokio::fs::create_dir_all(&data_dir).await?;
        tokio::fs::create_dir_all(&temp_dir).await?;
        
        Ok(Config {
            ai_service_url: "http://localhost:8080".to_string(),
            gateway_url: "http://localhost:8081".to_string(),
            data_dir,
            temp_dir,
            android_optimized: true,
            low_power_mode: false,
        })
    }
}
