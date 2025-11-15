//! Command processing and interface definitions

use crate::risn_core::state::ProjectStateManager;
use risn_ai::services::AIContext;
use risn_utils::error::RisnError;

pub mod analyze;
pub mod build;
pub mod deploy;
pub mod design;
pub mod init;

#[derive(clap::Subcommand)]
pub enum Command {
    /// Initialize new project
    Init(init::InitArgs),
    
    /// Build project assets
    Build(build::BuildArgs),
    
    /// Deploy to target environment
    Deploy(deploy::DeployArgs),
    
    /// Analyze code quality and security
    Analyze(analyze::AnalyzeArgs),
    
    /// Generate design system assets
    Design(design::DesignArgs),
}

/// Execute CLI commands with state and AI context
pub async fn execute_command(
    command: Command,
    state: ProjectStateManager,
    ai_context: AIContext,
) -> Result<(), RisnError> {
    match command {
        Command::Init(args) => init::execute(args, state, ai_context).await,
        Command::Build(args) => build::execute(args, state, ai_context).await,
        Command::Deploy(args) => deploy::execute(args, state, ai_context).await,
        Command::Analyze(args) => analyze::execute(args, state, ai_context).await,
        Command::Design(args) => design::execute(args, state, ai_context).await,
    }
}
