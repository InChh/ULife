use std::path::PathBuf;
use std::sync::Arc;

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
        std::fs::create_dir_all(&base_folder)?;
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
    pub fn get_current_user_token(&self) -> Result<Option<String>> {
        if let Some(file_path) = self.key_to_file.get("current_user") {
            let data = self.fs.read_blocking(file_path.value().to_string())?;
            let current_user = LoginData::decode(&*data)?;
            return Ok(Some(current_user.token));
        }
        Ok(None)
    }
}
