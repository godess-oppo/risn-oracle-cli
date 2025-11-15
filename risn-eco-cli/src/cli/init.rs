//! Project initialization subsystem

use risn_ai::services::AIContext;
use risn_core::state::ProjectStateManager;
use risn_utils::error::{Context, RisnError};
use std::path::PathBuf;
use tracing::info;

#[derive(clap::Args)]
pub struct InitArgs {
    /// Project name (alphanumeric + underscores)
    #[arg(short, long)]
    name: String,
    
    /// Template to use (optional)
    #[arg(short, long)]
    template: Option<String>,
    
    /// Target directory
    #[arg(default_value = ".", value_parser)]
    path: PathBuf,
}

/// Initialize new RISN project
pub async fn execute(
    args: InitArgs,
    mut state: ProjectStateManager,
    mut ai_context: AIContext,
) -> Result<(), RisnError> {
    // Validate project name
    risn_utils::security::validate_project_name(&args.name)?;
    
    let project_path = args.path.join(&args.name);
    
    // AI-assisted template selection
    let template = match args.template {
        Some(t) => t,
        None => ai_context.recommend_template(&args.name).await?,
    };
    
    info!("Creating project '{}' with template '{}'", args.name, template);
    
    // Generate project structure
    risn_ai::services::codegen::scaffold_project(&project_path, &template)
        .await
        .with_context(|| format!("Scaffolding failed at {}", project_path.display()))?;
    
    // Initialize state tracking
    state.track_new_project(&project_path).await?;
    
    // Generate initial security policy using AI
    let security_policy = ai_context.generate_security_policy(&project_path).await?;
    state.update_security_policy(&security_policy).await?;
    
    info!("Project initialized successfully");
    Ok(())
}
