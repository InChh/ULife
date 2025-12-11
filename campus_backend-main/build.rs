fn main() {
    // 编译所有 proto 文件
    let proto_files = vec![
        "../Protocol/activity.proto",
        "../Protocol/user.proto",
        "../Protocol/forum.proto",
        "../Protocol/course.proto",
        "../Protocol/ai.proto",
    ];
    
    prost_build::Config::new()
        .out_dir("src/proto")
        .compile_protos(
            &proto_files,
            &["../Protocol/"],
        )
        .unwrap();
    
    // 监听 proto 文件变化
    for proto_file in proto_files {
        println!("cargo:rerun-if-changed={}", proto_file);
    }
}
