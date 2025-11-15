//! RISN Ecosystem CLI - Autonomous Development Platform
//! Entry point for RISN CLI with AI-native command processing

use clap::Parser;
use risn_core::state::ProjectStateManager;
use risn_utils::error::RisnError;
use std::process::ExitCode;
use tracing_subscriber::{EnvFilter, fmt, prelude::*};

mod cli;

#[derive(Parser)]
#[command(name = "risn")]
#[command(version = "0.1.0")]
#[command(about = "RISN Autonomous Development Platform", long_about = None)]
struct RisnCli {
    #[command(subcommand)]
    command: cli::Command,
    
    #[arg(long, global = true, help = "Force offline mode")]
    offline: bool,
    
    #[arg(long, global = true, help = "Enable debug logging")]
    debug: bool,
}

#[tokio::main]
async fn main() -> ExitCode {
    // Initialize structured logging
    init_logging();
    
    let args = RisnCli::parse();
    let state = ProjectStateManager::new().await.unwrap_or_else(|e| {
        tracing::error!("State initialization failed: {}", e);
        std::process::exit(1);
    });
    
    let ai_context = risn_ai::services::AIContext::new(args.offline);
    
    match cli::execute_command(args.command, state, ai_context).await {
        Ok(_) => ExitCode::SUCCESS,
        Err(e) => {
            tracing::error!("Command failed: {}", e);
            risn_utils::error::log_error_chain(&e);
            ExitCode::FAILURE
        }
    }
}

fn init_logging() {
    let fmt_layer = fmt::layer()
        .with_target(false)
        .with_ansi(std::env::var("TERM").is_ok());
    
    let filter_layer = EnvFilter::try_from_default_env()
        .or_else(|_| EnvFilter::try_new("info"))
        .unwrap();
    
    tracing_subscriber::registry()
        .with(filter_layer)
        .with(fmt_layer)
        .with(tracing_error::ErrorLayer::default())
        .init();
}
