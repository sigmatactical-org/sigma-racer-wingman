# cargo.bbclass passes --target ${HOST_SYS}; match rust-native's LLVM host triple.
HOST_SYS:class-native = "${RUST_HOST_SYS}"
