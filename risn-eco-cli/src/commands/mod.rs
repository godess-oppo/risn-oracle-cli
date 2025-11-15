//! Command execution dispatcher

use crate::utils::error_handling::RisnError;
use risn_ai::AssistantContext;
use risn_state::StateManager;

pub mod analyze;
pub mod build;
pub mod deploy;
pub mod design;
pub mod init;

#[derive(clap::Subcommand)]
pub enum Command {
    Init(init::InitArgs),
    Build(build::BuildArgs),
    Deploy(deploy::DeployArgs),
    Analyze(analyze::AnalyzeArgs),
    Design(design::DesignArgs),
}

pub async fn execute(
    command: Command,
    state: StateManager,
    ai_context: AssistantContext,
) -> Result<(), RisnError> {
    match command {
        Command::Init(args) => init::execute(args, state, ai_context).await,
        Command::Build(args) => build::execute(args, state, ai_context).await,
        Command::Deploy(args) => deploy::execute(args, state, ai_context).await,
        Command::Analyze(args) => analyze::execute(args, state, ai_context).await,
        Command::Design(args) => design::execute(args, state, ai_context).await,
    }
}
