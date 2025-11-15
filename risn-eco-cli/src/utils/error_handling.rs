//! Comprehensive error handling system

use thiserror::Error;
use tracing_error::ErrorLayer;
use tracing_subscriber::prelude::*;

#[derive(Debug, Error)]
pub enum RisnError {
    #[error("Configuration error: {0}")]
    ConfigError(String),
    
    #[error("Security violation: {0}")]
    SecurityViolation(String),
    
    #[error("Offline operation failed")]
    OfflineOperationFailed,
    
    #[error("I/O error")]
    IoError(#[from] std::io::Error),
    
    #[error("AI engine failure")]
    AIEngineFailure(#[from] ort::Error),
    
    // Additional error variants
}

pub trait Context<T> {
    fn with_context<F, S>(self, f: F) -> Result<T, RisnError>
    where
        F: FnOnce() -> S,
        S: Into<String>;
}

impl<T, E> Context<T> for Result<T, E>
where
    E: Into<RisnError>,
{
    fn with_context<F, S>(self, f: F) -> Result<T, RisnError>
    where
        F: FnOnce() -> S,
        S: Into<String>,
    {
        self.map_err(|e| {
            let base_error: RisnError = e.into();
            base_error.add_context(f().into())
        })
    }
}

impl RisnError {
    pub fn add_context(self, context: String) -> Self {
        // Enhanced error chaining logic
    }
    
    pub fn log_error_chain(err: &dyn std::error::Error) {
        tracing::error!("{}", err);
        let mut source = err.source();
        while let Some(s) = source {
            tracing::error!("Caused by: {}", s);
            source = s.source();
        }
    }
}

