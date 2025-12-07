use std::collections::HashSet;
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

    // 给除 Common 包外的所有 message 添加自定义属性
    // prost 的 type_attribute 需要完整的 protobuf 路径，如 "Forum.ForumPost" 或 "Test"
    let mut targets = HashSet::new();
    for proto in &protos {
        let content = std::fs::read_to_string(proto)?;
        let package = content
            .lines()
            .find_map(|line| {
                let trimmed = line.trim();
                trimmed
                    .strip_prefix("package ")
                    .map(|pkg| pkg.trim_end_matches(';').trim().to_owned())
            });

        for line in content.lines() {
            let trimmed = line.trim();
            if let Some(rest) = trimmed.strip_prefix("message ")
                && let Some(name) = rest
                    .split_whitespace()
                    .next()
                    .map(|s| s.trim_end_matches('{').to_owned())
                {
                    let qualified = match &package {
                        Some(pkg) => format!("{pkg}.{name}"),
                        None => name,
                    };
                    if package.as_deref() != Some("Common") {
                        targets.insert(qualified);
                    }
                }
        }
    }
    for target in targets {
        config.type_attribute(target, "#[derive(uniffi::Record)]");
    }

    config
        .compile_protos(&protos, &[proto_root])
        .expect("compile protos");
    println!("cargo:rerun-if-changed=../Protocol");
    Ok(())
}
