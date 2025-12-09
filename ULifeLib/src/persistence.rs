use std::path::PathBuf;

use dashmap::DashMap;
use prost::Message;

use crate::{error::Result, profile::CurrentUser};

#[derive(uniffi::Object)]
pub struct PersistenceManager {
    base_folder: String,
    key_to_file: DashMap<String, String>,
}

#[uniffi::export]
impl PersistenceManager {
    /// 创建 PersistenceManager 实例
    #[uniffi::constructor]
    pub fn new(base_folder: String) -> Result<Self> {
        std::fs::create_dir_all(&base_folder)?;
        let key_to_file = DashMap::new();
        Ok(PersistenceManager { base_folder, key_to_file })
    }

    /// 保存当前用户信息到本地存储
    pub async fn save_current_user(&self, current_user: CurrentUser) -> Result<()> {
        // encode and save the token to a file
        let file_path = PathBuf::from(&self.base_folder).join("current_user");
        // encode to protobuf
        let mut buf = Vec::new();
        current_user.encode(&mut buf)?;
        tokio::fs::write(&file_path, buf).await?;
        self.key_to_file.insert("current_user".to_string(), file_path.to_string_lossy().to_string());
        Ok(())
    }

    /// 获取当前用户信息
    pub async fn get_current_user(&self) -> Result<Option<CurrentUser>> {
        if let Some(file_path) = self.key_to_file.get("current_user") {
            let data = tokio::fs::read(&*file_path).await?;
            let current_user = CurrentUser::decode(&*data)?;
            return Ok(Some(current_user));
        }
        Ok(None)
    }

    /// 获取当前用户的 Token
    pub fn get_current_user_token(&self) -> Result<Option<String>> {
        if let Some(file_path) = self.key_to_file.get("current_user") {
            let data = std::fs::read(&*file_path)?;
            let current_user = CurrentUser::decode(&*data)?;
            return Ok(Some(current_user.token));
        }
        Ok(None)
    }
}
