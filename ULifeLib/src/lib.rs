use std::sync::Arc;

use foyer::{
    BlockEngineBuilder, DeviceBuilder, FsDeviceBuilder, HybridCache, HybridCacheBuilder, Throttle,
};
use once_cell::sync::OnceCell;

use crate::{error::Result, fs::FsHandle, persistence::PersistenceManager};

pub mod api;
pub mod error;
pub mod fs;
pub mod hybrid_cache;
pub mod pb;
pub mod persistence;

pub use hybrid_cache::{CacheOptions, HybridCacheConfig};

uniffi::setup_scaffolding!();

static PERSISTENCE_MANAGER: OnceCell<Arc<PersistenceManager>> = OnceCell::new();

static ASYNC_RUNTIME: OnceCell<Arc<tokio::runtime::Runtime>> = OnceCell::new();

static API_CACHE: OnceCell<Arc<HybridCache<String, Vec<u8>>>> = OnceCell::new();

#[uniffi::export(async_runtime = "tokio")]
pub async fn init_persistence_manager(base_folder: String, fs: FsHandle) -> Result<()> {
    let mut manager = PersistenceManager::new(base_folder, fs)?;
    manager.load_file_mapping().await?;
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

pub fn get_async_runtime() -> Result<Arc<tokio::runtime::Runtime>> {
    let runtime = ASYNC_RUNTIME.get_or_try_init(|| {
        let rt = Arc::new(
            tokio::runtime::Builder::new_multi_thread()
                .enable_all()
                .build()?,
        );
        Ok::<_, error::Error>(rt)
    })?;
    Ok(runtime.clone())
}

#[uniffi::export(async_runtime = "tokio")]
pub async fn init_api_cache(cache_folder: String, cache_size: u64) -> Result<()> {
    let cache_dir = std::path::PathBuf::from(cache_folder).join("api_cache");
    let device = FsDeviceBuilder::new(cache_dir)
        .with_capacity((cache_size * 10) as usize)
        .with_throttle(
            Throttle::new()
                .with_read_iops(4000)
                .with_write_iops(2000)
                .with_read_throughput(800 * 1024 * 1024)
                .with_write_throughput(100 * 1024 * 1024),
        )
        .build()?;
    let cache: HybridCache<String, Vec<u8>> = HybridCacheBuilder::new()
        .memory(cache_size as usize)
        .storage()
        .with_engine_config(BlockEngineBuilder::new(device))
        .build()
        .await?;

    let _ = API_CACHE.set(Arc::new(cache));
    Ok(())
}
