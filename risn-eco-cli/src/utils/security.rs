//! Security validation subsystem

use super::error::RisnError;

/// Validate project name meets security requirements
pub fn validate_project_name(name: &str) -> Result<(), RisnError> {
    if name.is_empty() {
        return Err(RisnError::SecurityViolation(
            "Project name cannot be empty".into(),
        ));
    }
    
    if name.chars().any(|c| !c.is_ascii_alphanumeric() && c != '_' && c != '-') {
        return Err(RisnError::SecurityViolation(
            "Project name contains invalid characters".into(),
        ));
    }
    
    // Block reserved names
    let reserved = ["risn", "system", "config", "root"];
    if reserved.contains(&name.to_lowercase().as_str()) {
        return Err(RisnError::SecurityViolation(
            "Project name uses reserved word".into(),
        ));
    }
    
    Ok(())
}

/// Validate file paths to prevent directory traversal
pub fn validate_file_path(base: &std::path::Path, path: &std::path::Path) -> Result<(), RisnError> {
    if !path.starts_with(base) {
        return Err(RisnError::SecurityViolation(
            "Path traversal attempt detected".into(),
        ));
    }
    Ok(())
}
