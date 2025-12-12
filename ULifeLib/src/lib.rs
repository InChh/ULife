use std::sync::Arc;

use once_cell::sync::OnceCell;

use crate::{error::Result, fs::FsHandle, persistence::PersistenceManager};

pub mod error;
pub mod fs;
pub mod hybrid_cache;
pub mod pb;
pub mod persistence;

pub mod api;
pub mod model;
pub use hybrid_cache::{CacheOptions, HybridCache, HybridCacheConfig};

uniffi::setup_scaffolding!();

static PERSISTENCE_MANAGER: OnceCell<Arc<PersistenceManager>> = OnceCell::new();

#[uniffi::export]
pub fn init_persistence_manager(base_folder: String, fs: FsHandle) -> Result<()> {
    let manager = PersistenceManager::new(base_folder, fs)?;
    let _ = PERSISTENCE_MANAGER.set(Arc::new(manager));
    Ok(())
}

#[uniffi::export]
pub fn get_persistence_manager() -> Result<Arc<PersistenceManager>> {
    PERSISTENCE_MANAGER
        .get()
        .map(Arc::clone)
        .ok_or_else(|| error::Error::Uninitialized)
}
