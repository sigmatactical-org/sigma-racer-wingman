## This is information on the rust-snapshot (binary) used to build our current release.
## snapshot info is taken from rust/src/stage0
## Rust is self-hosting and bootstraps itself with a pre-built previous version of itself.
## The exact (previous) version that has been used is specified in the source tarball.
## The version is replicated here.
## TODO: find a way to add additional SRC_URIs based on the contents of an
##       earlier SRC_URI.

SNAPSHOT_VERSION = "1.89.0"

# TODO: Add hashes for other architecture toolchains as well.

# You can use scripts/rust-get-stage0.sh to update hashes
SRC_URI[rust-std-snapshot-x86_64.sha256sum] = "2719470dcd78b3f97d78b978c8f85a1a58d84ff11b62558294621c01bca34d49"
SRC_URI[rustc-snapshot-x86_64.sha256sum] = "b42c254e1349df86bd40bc28fdf386172a1a46f2eeabe3c7a08a75cf1fb60e27"
SRC_URI[cargo-snapshot-x86_64.sha256sum] = "99fc10be2aeedf2c23a484f217bfa76458494495a0eee33e280d3616bb08282d"

SRC_URI[rust-std-snapshot-aarch64.sha256sum] = "abea0955dded88c68d731524ab9d29b162fae23bf5805b9f1dec063cba37c2aa"
SRC_URI[rustc-snapshot-aarch64.sha256sum] = "16ed8d8c7628a481c8501e7cd1022a123269b297bdedbb7f211f37a15e937e0e"
SRC_URI[cargo-snapshot-aarch64.sha256sum] = "f9df3ee6d55a2387459b843477743fa386c3c0f126bd0be01691ee49309681b8"

SRC_URI[rust-std-snapshot-powerpc64le.sha256sum] = "40123b87f0b909376d7f0bd291553b7e10aa637dd710f4bc698bcdcd0b08d21b"
SRC_URI[rustc-snapshot-powerpc64le.sha256sum] = "14b7a8b7b3951a59a765804e1dd2ad454d3412000e7166ad8f2f621e29a88941"
SRC_URI[cargo-snapshot-powerpc64le.sha256sum] = "764eb5f54c2b0779f9e84c6fb0763e45316d5a51fbd187b56f9f6d7a646272d4"

SRC_URI += " \
    https://static.rust-lang.org/dist/${RUST_STD_SNAPSHOT}.tar.xz;name=rust-std-snapshot-${RUST_BUILD_ARCH};subdir=rust-snapshot-components \
    https://static.rust-lang.org/dist/${RUSTC_SNAPSHOT}.tar.xz;name=rustc-snapshot-${RUST_BUILD_ARCH};subdir=rust-snapshot-components \
    https://static.rust-lang.org/dist/${CARGO_SNAPSHOT}.tar.xz;name=cargo-snapshot-${RUST_BUILD_ARCH};subdir=rust-snapshot-components \
"

RUST_STD_SNAPSHOT = "rust-std-${SNAPSHOT_VERSION}-${RUST_BUILD_ARCH}-unknown-linux-gnu"
RUSTC_SNAPSHOT = "rustc-${SNAPSHOT_VERSION}-${RUST_BUILD_ARCH}-unknown-linux-gnu"
CARGO_SNAPSHOT = "cargo-${SNAPSHOT_VERSION}-${RUST_BUILD_ARCH}-unknown-linux-gnu"
