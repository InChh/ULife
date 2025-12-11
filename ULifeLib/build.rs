use std::path::PathBuf;

use walkdir::WalkDir;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let proto_root = PathBuf::from("../Protocol"); // 存放 .proto 的目录
    let out_dir = PathBuf::from("src/pb"); // 希望生成到的目录（相对工程根目录）

    // 收集所有 .proto
    let protos: Vec<_> = WalkDir::new(&proto_root)
        .into_iter()
        .filter_map(Result::ok)
        .filter(|e| e.path().extension().is_some_and(|ext| ext == "proto"))
        .map(|e| e.path().to_owned())
        .collect();

    // 生成
    let mut config = prost_build::Config::new();
    config.out_dir(&out_dir); // 默认是 OUT_DIR，这里改为自定义目录
    config.type_attribute(".", "#[derive(uniffi::Record)]");

    config
        .compile_protos(&protos, &[proto_root])
        .expect("compile protos");
    println!("cargo:rerun-if-changed=../Protocol");
    Ok(())
}
