pub type Result<T> = std::result::Result<T, Error>;

#[derive(Debug, uniffi::Error, thiserror::Error)]
#[uniffi(flat_error)]
pub enum Error {
    #[error("IO error: {0}")]
    IoError(#[from] std::io::Error),
    #[error("HTTP request error: {0}")]
    ReqwestError(#[from] reqwest::Error),
    #[error("Protobuf decode error: {0}")]
    ProstDecodeError(#[from] prost::DecodeError),
    #[error("Protobuf encode error: {0}")]
    ProstEncodeError(#[from] prost::EncodeError),
    #[error("Cache serialization error: {0}")]
    CacheSerdeError(String),
    #[error("ULifeLib is not initialized")]
    Uninitialized,
    #[error("Unknown error occurred")]
    UnknownError,
    #[error("HTTP error with status: {0}")]
    HttpError(reqwest::StatusCode),
    #[error("Unauthorized access")]
    UnAuthorized,
}
