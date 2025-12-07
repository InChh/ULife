use moka::future::Cache;
use moka::notification::RemovalCause;
use std::{
    collections::hash_map::DefaultHasher,
    hash::{Hash, Hasher},
    marker::PhantomData,
    path::{Path, PathBuf},
    sync::Arc,
    time::{Duration, SystemTime, UNIX_EPOCH},
};
use tokio::{fs, runtime::Handle};

use crate::error::{Error, Result};

/// Global cache configuration.
#[derive(Clone, Debug)]
pub struct HybridCacheConfig {
    /// Directory used to store disk cache entries.
    pub disk_dir: PathBuf,
    /// Maximum number of entries retained in memory.
    pub memory_capacity: u64,
    /// Optional default TTL applied to inserts that omit a TTL.
    pub default_ttl: Option<Duration>,
    /// Time to idle before an entry is evicted from memory (and migrated to disk).
    pub memory_time_to_idle: Option<Duration>,
}

/// Per-insert options.
#[derive(Clone, Debug)]
pub struct CacheOptions {
    pub ttl: Option<Duration>,
}

impl CacheOptions {
    pub fn no_expiry() -> Self {
        Self { ttl: None }
    }

    pub fn with_ttl(ttl: Duration) -> Self {
        Self { ttl: Some(ttl) }
    }
}

impl Default for CacheOptions {
    fn default() -> Self {
        Self {
            ttl: Some(Duration::from_secs(60)),
        }
    }
}

#[derive(Clone, Debug)]
struct CacheEntry {
    bytes: Arc<Vec<u8>>,
    expires_at: Option<SystemTime>,
}

impl CacheEntry {
    fn is_expired(&self, now: SystemTime) -> bool {
        match self.expires_at {
            Some(ts) => ts <= now,
            None => false,
        }
    }

    fn remaining_ttl(&self, now: SystemTime) -> Option<Duration> {
        self.expires_at.and_then(|ts| ts.duration_since(now).ok())
    }
}

#[derive(Debug)]
/// Hybrid cache backed by an in-memory moka cache plus a disk layer.
pub struct HybridCache<K, V>
where
    K: Eq + Hash + Clone + Send + Sync + 'static + ToString,
    V: Send + Sync + 'static + Into<Vec<u8>> + From<Vec<u8>>,
{
    memory: Cache<K, CacheEntry>,
    disk_dir: PathBuf,
    default_ttl: Option<Duration>,
    _value: PhantomData<V>,
}

impl<K, V> HybridCache<K, V>
where
    K: Eq + Hash + Clone + Send + Sync + 'static + ToString,
    V: Send + Sync + 'static + Into<Vec<u8>> + From<Vec<u8>>,
{
    pub fn new(config: HybridCacheConfig) -> Result<Self> {
        std::fs::create_dir_all(&config.disk_dir)?;

        let disk_dir = config.disk_dir.clone();
        let eviction_dir = config.disk_dir.clone();
        let builder = {
            let mut b = Cache::builder()
                .max_capacity(config.memory_capacity)
                .expire_after(PerEntryExpiry);
            if let Some(idle) = config.memory_time_to_idle {
                b = b.time_to_idle(idle);
            }
            b.async_eviction_listener(
                move |key: Arc<K>, entry: CacheEntry, _cause: RemovalCause| {
                    let path_root = eviction_dir.clone();
                    Box::pin(async move {
                        if entry.is_expired(SystemTime::now()) {
                            return;
                        }
                        if let Err(err) = persist_entry(&path_root, &*key, &entry).await {
                            eprintln!("hybrid cache: failed to persist evicted entry: {err}");
                        }
                    })
                },
            )
            .build()
        };

        Ok(Self {
            memory: builder,
            disk_dir,
            default_ttl: config.default_ttl,
            _value: PhantomData,
        })
    }

    /// Insert or update an entry with optional TTL.
    pub async fn insert(&self, key: K, value: V, options: CacheOptions) -> Result<()> {
        let ttl = options.ttl.or(self.default_ttl);
        let expires_at = ttl.map(|ttl| SystemTime::now() + ttl);
        let bytes: Vec<u8> = value.into();
        let entry = CacheEntry {
            bytes: Arc::new(bytes),
            expires_at,
        };
        self.memory.insert(key, entry).await;
        Ok(())
    }

    /// Get an entry; load from disk on miss and refresh memory.
    pub async fn get(&self, key: &K) -> Result<Option<V>> {
        let now = SystemTime::now();

        if let Some(entry) = self.memory.get(key).await {
            if entry.is_expired(now) {
                self.memory.invalidate(key).await;
                let _ = self.remove_from_disk(key).await;
                return Ok(None);
            }
            return Ok(Some(V::from((*entry.bytes).clone())));
        }

        if let Some(entry) = self.read_from_disk(key).await? {
            if entry.is_expired(now) {
                let _ = self.remove_from_disk(key).await;
                return Ok(None);
            }
            self.memory.insert(key.clone(), entry.clone()).await;
            return Ok(Some(V::from((*entry.bytes).clone())));
        }

        Ok(None)
    }

    pub async fn remove(&self, key: &K) -> Result<()> {
        self.memory.invalidate(key).await;
        self.remove_from_disk(key).await
    }

    /// Flush in-memory entries to disk (clears memory).
    pub async fn flush(&self) -> Result<()> {
        self.memory.invalidate_all();
        self.memory.run_pending_tasks().await;
        Ok(())
    }

    async fn read_from_disk(&self, key: &K) -> Result<Option<CacheEntry>> {
        let path = key_to_path(&self.disk_dir, key);
        let bytes = match fs::read(&path).await {
            Ok(data) => data,
            Err(err) if err.kind() == std::io::ErrorKind::NotFound => return Ok(None),
            Err(err) => return Err(err.into()),
        };
        deserialize_entry(&bytes)
    }

    async fn remove_from_disk(&self, key: &K) -> Result<()> {
        let path = key_to_path(&self.disk_dir, key);
        match fs::remove_file(path).await {
            Ok(()) => Ok(()),
            Err(err) if err.kind() == std::io::ErrorKind::NotFound => Ok(()),
            Err(err) => Err(err.into()),
        }
    }
}

impl<K, V> Drop for HybridCache<K, V>
where
    K: Eq + Hash + Clone + Send + Sync + 'static + ToString,
    V: Send + Sync + 'static + Into<Vec<u8>> + From<Vec<u8>>,
{
    fn drop(&mut self) {
        let memory = self.memory.clone();
        let flush = async move {
            memory.invalidate_all();
            memory.run_pending_tasks().await;
        };
        if let Ok(handle) = Handle::try_current() {
            handle.spawn(flush);
        } else if let Ok(rt) = tokio::runtime::Runtime::new() {
            rt.block_on(flush);
        }
    }
}

async fn persist_entry<K>(disk_dir: &Path, key: &K, entry: &CacheEntry) -> Result<()>
where
    K: ToString + ?Sized,
{
    let path = key_to_path(disk_dir, key);
    let temp_path = temp_path_for(&path);
    let data = serialize_entry(entry)?;
    fs::write(&temp_path, data).await?;
    fs::rename(&temp_path, &path).await?;
    Ok(())
}

fn serialize_entry(entry: &CacheEntry) -> Result<Vec<u8>> {
    let mut buf = Vec::with_capacity(entry.bytes.len() + 9);
    match entry.expires_at {
        Some(ts) => {
            let dur = ts
                .duration_since(UNIX_EPOCH)
                .map_err(|e| Error::CacheSerdeError(e.to_string()))?;
            buf.push(1);
            let millis = dur.as_millis();
            if millis > u64::MAX as u128 {
                return Err(Error::CacheSerdeError(
                    "expiry timestamp exceeds supported range".into(),
                ));
            }
            buf.extend_from_slice(&(millis as u64).to_le_bytes());
        }
        None => buf.push(0),
    }
    buf.extend_from_slice(&entry.bytes);
    Ok(buf)
}

fn deserialize_entry(data: &[u8]) -> Result<Option<CacheEntry>> {
    if data.is_empty() {
        return Ok(None);
    }
    let has_expiry = data[0];
    let (expires_at, payload_start) = if has_expiry == 1 {
        if data.len() < 1 + 8 {
            return Err(Error::CacheSerdeError("Corrupted cache entry".into()));
        }
        let mut millis_bytes = [0u8; 8];
        millis_bytes.copy_from_slice(&data[1..9]);
        let millis = u64::from_le_bytes(millis_bytes);
        let ts = UNIX_EPOCH + Duration::from_millis(millis);
        (Some(ts), 9)
    } else {
        (None, 1)
    };

    let payload = data[payload_start..].to_vec();
    Ok(Some(CacheEntry {
        bytes: Arc::new(payload),
        expires_at,
    }))
}

fn key_to_path<K: ToString + ?Sized>(root: &Path, key: &K) -> PathBuf {
    let string = key.to_string();
    let hash = blake3::hash(string.as_bytes());
    root.join(format!("{}.bin", to_hex(hash)))
}

fn temp_path_for(path: &Path) -> PathBuf {
    let mut hasher = DefaultHasher::new();
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or(Duration::ZERO)
        .hash(&mut hasher);
    std::process::id().hash(&mut hasher);
    let suffix = hasher.finish();
    path.with_extension(format!("tmp.{suffix}"))
}

fn to_hex(hash: blake3::Hash) -> String {
    let mut out = String::with_capacity(64);
    for b in hash.as_bytes() {
        out.push_str(&format!("{:02x}", b));
    }
    out
}

struct PerEntryExpiry;

impl<K> moka::policy::Expiry<K, CacheEntry> for PerEntryExpiry {
    fn expire_after_create(
        &self,
        _key: &K,
        value: &CacheEntry,
        _created_at: std::time::Instant,
    ) -> Option<Duration> {
        value.remaining_ttl(SystemTime::now())
    }

    fn expire_after_read(
        &self,
        _key: &K,
        value: &CacheEntry,
        _read_at: std::time::Instant,
        _duration_until_expiry: Option<Duration>,
        _last_modified_at: std::time::Instant,
    ) -> Option<Duration> {
        value.remaining_ttl(SystemTime::now())
    }

    fn expire_after_update(
        &self,
        _key: &K,
        value: &CacheEntry,
        _updated_at: std::time::Instant,
        _duration_until_expiry: Option<Duration>,
    ) -> Option<Duration> {
        value.remaining_ttl(SystemTime::now())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use tokio::time::{Duration, sleep};

    fn temp_root(name: &str) -> PathBuf {
        let mut path = std::env::temp_dir();
        path.push(format!("hybrid_cache_{name}_{}", std::process::id()));
        let _ = std::fs::remove_dir_all(&path);
        path
    }

    #[tokio::test]
    async fn insert_and_get_round_trip() {
        let root = temp_root("basic");
        let cache: HybridCache<String, Vec<u8>> = HybridCache::new(HybridCacheConfig {
            disk_dir: root.clone(),
            memory_capacity: 10,
            default_ttl: None,
            memory_time_to_idle: None,
        })
        .unwrap();

        cache
            .insert(
                "key1".to_string(),
                b"hello".to_vec(),
                CacheOptions::default(),
            )
            .await
            .unwrap();

        let got = cache.get(&"key1".to_string()).await.unwrap();
        assert_eq!(got, Some(b"hello".to_vec()));
    }

    #[tokio::test]
    async fn ttl_expires() {
        let root = temp_root("ttl");
        let cache: HybridCache<String, Vec<u8>> = HybridCache::new(HybridCacheConfig {
            disk_dir: root.clone(),
            memory_capacity: 10,
            default_ttl: None,
            memory_time_to_idle: None,
        })
        .unwrap();

        cache
            .insert(
                "exp".to_string(),
                b"bytes".to_vec(),
                CacheOptions {
                    ttl: Some(Duration::from_millis(50)),
                },
            )
            .await
            .unwrap();

        sleep(Duration::from_millis(80)).await;
        let got = cache.get(&"exp".to_string()).await.unwrap();
        assert!(got.is_none());
    }

    #[tokio::test]
    async fn evicted_entry_persists_to_disk() {
        let root = temp_root("evict");
        let cache: HybridCache<String, Vec<u8>> = HybridCache::new(HybridCacheConfig {
            disk_dir: root.clone(),
            memory_capacity: 1,
            default_ttl: None,
            memory_time_to_idle: None,
        })
        .unwrap();

        cache
            .insert("k1".to_string(), b"v1".to_vec(), CacheOptions::default())
            .await
            .unwrap();
        cache
            .insert("k2".to_string(), b"v2".to_vec(), CacheOptions::default())
            .await
            .unwrap();

        cache.memory.run_pending_tasks().await;

        let got_disk = cache.get(&"k1".to_string()).await.unwrap();
        assert_eq!(got_disk, Some(b"v1".to_vec()));
    }
}
