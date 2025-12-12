use std::sync::Arc;

use async_trait::async_trait;
use tokio::runtime::Handle;

use crate::error::Result;

pub type FsHandle = Arc<dyn FileSystem>;

#[uniffi::export(with_foreign)]
#[async_trait]
pub trait FileSystem: Send + Sync {
    async fn create_dir_all(&self, path: String) -> Result<()>;
    async fn file_exists(&self, path: String) -> Result<bool>;
    async fn write(&self, path: String, data: Vec<u8>) -> Result<()>;
    async fn read(&self, path: String) -> Result<Vec<u8>>;
    async fn remove_file(&self, path: String) -> Result<()>;
    async fn rename(&self, from: String, to: String) -> Result<()>;
    async fn remove_dir_all(&self, path: String) -> Result<()>;
    fn read_blocking(&self, path: String) -> Result<Vec<u8>>;
}

#[derive(Clone, Default)]
pub struct DefaultFileSystem;

#[async_trait]
impl FileSystem for DefaultFileSystem {
    async fn create_dir_all(&self, path: String) -> Result<()> {
        tokio::fs::create_dir_all(path).await?;
        Ok(())
    }

    async fn file_exists(&self, path: String) -> Result<bool> {
        Ok(tokio::fs::metadata(path).await.is_ok())
    }

    async fn write(&self, path: String, data: Vec<u8>) -> Result<()> {
        tokio::fs::write(path, data).await?;
        Ok(())
    }

    async fn read(&self, path: String) -> Result<Vec<u8>> {
        let bytes = tokio::fs::read(path).await?;
        Ok(bytes)
    }

    async fn remove_file(&self, path: String) -> Result<()> {
        tokio::fs::remove_file(path).await?;
        Ok(())
    }

    async fn rename(&self, from: String, to: String) -> Result<()> {
        tokio::fs::rename(from, to).await?;
        Ok(())
    }

    async fn remove_dir_all(&self, path: String) -> Result<()> {
        tokio::fs::remove_dir_all(path).await?;
        Ok(())
    }

    fn read_blocking(&self, path: String) -> Result<Vec<u8>> {
        let bytes = std::fs::read(path)?;
        Ok(bytes)
    }
}

pub fn default_fs() -> FsHandle {
    Arc::new(DefaultFileSystem)
}

pub fn block_on_fs<F, T>(future: F) -> Result<T>
where
    F: std::future::Future<Output = Result<T>>,
{
    if let Ok(handle) = Handle::try_current() {
        tokio::task::block_in_place(|| handle.block_on(future))
    } else {
        tokio::runtime::Runtime::new()?.block_on(future)
    }
}
