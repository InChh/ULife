use prost::Message;
use reqwest::Client;

async fn post_protobuf<T, R>(
    client: &Client,
    url: &str,
    request: &T,
) -> Result<R, Box<dyn std::error::Error>>
where
    T: Message,           // 请求体必须实现 Prost Message
    R: Message + Default, // 响应体必须实现 Prost Message
{
    let mut buf = Vec::new();
    request.encode(&mut buf)?;

    let resp = client
        .post(url)
        .header("Content-Type", "application/x-protobuf")
        .body(buf)
        .send()
        .await?;

    let bytes = resp.bytes().await?;
    let response = R::decode(bytes)?;

    Ok(response)
}
