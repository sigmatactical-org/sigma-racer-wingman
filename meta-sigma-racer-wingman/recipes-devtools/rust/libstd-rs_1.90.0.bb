require rust-source-${PV}.inc
require libstd-rs.inc

LIC_FILES_CHKSUM = "file://../../COPYRIGHT;md5=11a3899825f4376896e438c8c753f8dc"

# libstd moved from src/std to library/sysroot in 1.72+
S = "${RUSTSRC}/library/sysroot"

# ref: https://github.com/rust-lang/rust/issues/133857
RUSTFLAGS += "-Zforce-unstable-if-unmarked"
