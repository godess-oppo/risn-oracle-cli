//! Real-time project state management

use crate::risn_infrastructure::sync::StateSynchronizer;
use risn_utils::error::RisnError;
use serde::{Deserialize, Serialize};
use std::path::PathBuf;
use tokio::sync::RwLock;

#[derive(Clone)]
pub struct ProjectStateManager {
    state: RwLock<ProjectState>,
    synchronizer: StateSynchronizer,
}

#[derive(Debug, Serialize, Deserialize, Default)]
struct ProjectState {
    path: PathBuf,
    security_policy: String,
    last_build_hash: Option<String>,
    deployment_targets: Vec<String>,
}

impl ProjectStateManager {
    pub async fn new() -> Result<Self, RisnError> {
        let synchronizer = StateSynchronizer::connect().await?;
        let state = RwLock::new(ProjectState::default());
        
        Ok(Self {
            state,
            synchronizer,
        })
    }
    
    pub async fn track_new_project(&mut self, path: &PathBuf) -> Result<(), RisnError> {
        let mut state = self.state.write().await;
        state.path = path.clone();
        
        // Sync initial state to cloud
        self.synchronizer.sync_state(&state).await?;
        
        Ok(())
    }
    
    pub async fn update_security_policy(&self, policy: &str) -> Result<(), RisnError> {
        let mut state = self.state.write().await;
        state.security_policy = policy.to_string();
        
        // Validate and sync
        self.synchronizer.sync_state(&state).await
    }
    
    pub async fn record_build(&self, build_hash: &str) -> Result<(), RisnError> {
        let mut state = self.state.write().await;
        state.last_build_hash = Some(build_hash.to_string());
        self.synchronizer.sync_state(&state).await
    }
}
