use std::{collections::HashMap, path::PathBuf};

use dashmap::DashMap;
use prost::Message;

use crate::fs::FsHandle;
use crate::{error::Result, pb::user::LoginData};

#[derive(uniffi::Object)]
pub struct PersistenceManager {
    base_folder: String,
    key_to_file: DashMap<String, String>,
    fs: FsHandle,
}

#[uniffi::export]
impl PersistenceManager {
    /// 创建 PersistenceManager 实例
    #[uniffi::constructor]
    pub fn new(base_folder: String, fs: FsHandle) -> Result<Self> {
        tokio::runtime::Handle::current()
            .block_on(async { fs.create_dir_all(base_folder.clone()).await })?;
        let key_to_file = DashMap::new();
        Ok(PersistenceManager {
            base_folder,
            key_to_file,
            fs,
        })
    }

    /// 保存当前用户信息到本地存储
    pub async fn save_current_user(&self, login_data: LoginData) -> Result<()> {
        let file_path = PathBuf::from(&self.base_folder).join("current_user");
        let mut buf = Vec::new();
        login_data.encode(&mut buf)?;
        self.fs
            .write(file_path.to_string_lossy().to_string(), buf)
            .await?;
        self.key_to_file.insert(
            "current_user".to_string(),
            file_path.to_string_lossy().to_string(),
        );
        Ok(())
    }

    /// 获取当前用户信息
    pub async fn get_current_user(&self) -> Result<Option<LoginData>> {
        if let Some(file_path) = self.key_to_file.get("current_user") {
            let data = self.fs.read(file_path.value().to_string()).await?;
            let current_user = LoginData::decode(&*data)?;
            return Ok(Some(current_user));
        }
        Ok(None)
    }

    /// 获取当前用户的 Token
    pub async fn get_current_user_token(&self) -> Result<Option<String>> {
        if let Some(file_path) = self.key_to_file.get("current_user") {
            let data = self.fs.read(file_path.value().to_string()).await?;
            let current_user = LoginData::decode(&*data)?;
            return Ok(Some(current_user.token));
        }
        Ok(None)
    }
}

impl PersistenceManager {
    fn get_mapping_file_path(base_folder: &str) -> PathBuf {
        PathBuf::from(base_folder).join("persistence_key_to_file.json")
    }

    pub async fn load_file_mapping(&mut self) -> Result<()> {
        let path = Self::get_mapping_file_path(&self.base_folder);
        if !self
            .fs
            .file_exists(path.to_string_lossy().to_string())
            .await
            .unwrap_or(false)
        {
            return Ok(());
        }
        match self.fs.read(path.to_string_lossy().to_string()).await {
            Ok(bytes) => {
                let map: HashMap<String, String> = serde_json::from_slice(&bytes)?;
                self.key_to_file = DashMap::from_iter(map);
                Ok(())
            }
            Err(err) => Err(err),
        }
    }
}

impl Drop for PersistenceManager {
    fn drop(&mut self) {
        tokio::runtime::Handle::current().block_on(async {
            let _ = self.fs.create_dir_all(self.base_folder.clone()).await;
            let path = Self::get_mapping_file_path(&self.base_folder);
            let snapshot: HashMap<String, String> = self
                .key_to_file
                .iter()
                .map(|entry| (entry.key().clone(), entry.value().clone()))
                .collect();

            if snapshot.is_empty()
                && self
                    .fs
                    .file_exists(path.to_string_lossy().to_string())
                    .await
                    .unwrap_or(false)
            {
                let _ = self
                    .fs
                    .remove_file(path.to_string_lossy().to_string())
                    .await;
                return;
            }

            if let Ok(bytes) = serde_json::to_vec(&snapshot) {
                let _ = self
                    .fs
                    .write(path.to_string_lossy().to_string(), bytes)
                    .await;
            }
        });
    }
}
