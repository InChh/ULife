use crate::ApiClient;
use crate::error::Result;

#[uniffi::export]
impl ApiClient {
    pub async fn download_file(&self, url: String) -> Result<Vec<u8>> {
        if let Some(cached_data) = self.cache.get(&url).await? {
            return Ok(cached_data);
        }

        let response = self.client.get(&url).send().await?;
        if !response.status().is_success() {
            return Err(crate::error::Error::HttpError(response.status()));
        }

        let data = response.bytes().await?.to_vec();

        self.cache
            .insert(
                url.clone(),
                data.clone(),
                crate::CacheOptions::default(),
            )
            .await?;

        Ok(data)
    }
}
