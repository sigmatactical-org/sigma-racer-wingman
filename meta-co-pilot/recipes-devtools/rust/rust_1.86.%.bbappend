# meta-rust setup_cargo_environment always appends SNAPSHOT_BUILD_SYS, but
# cargo_common_do_configure already writes the same Rust triple on native x86_64
# hosts — duplicate [target.*] tables break cargo 1.86+.
setup_cargo_environment () {
    cargo_common_do_configure

    if ! grep -qF "[target.${SNAPSHOT_BUILD_SYS}]" "${CARGO_HOME}/config"; then
        printf '[target.%s]\n' "${SNAPSHOT_BUILD_SYS}" >> ${CARGO_HOME}/config
        printf "linker = '%s'\n" "${RUST_BUILD_CCLD}" >> ${CARGO_HOME}/config
    fi
}

# rust.inc uses Yocto HOST_SYS for bootstrap build.host; rustc needs the LLVM triple.
# Keep TARGET_SYS as the Yocto triple — it must differ from SNAPSHOT_BUILD_SYS in config.toml.
HOST_SYS:class-native = "${RUST_HOST_SYS}"

# build.target defaults to TARGET_SYS (x86_64-linux) while build.host is RUST_HOST_SYS.
# Stdlib must match the host triple or cargo-native build scripts fail with E0463.
python do_configure:append:class-native () {
    import os
    import re

    target_sys = d.getVar('TARGET_SYS')
    rust_host = d.getVar('RUST_HOST_SYS')
    config = os.path.join(d.getVar('S'), 'config.toml')

    with open(config) as f:
        content = f.read()

    content = re.sub(
        r'^target = \["' + re.escape(target_sys) + r'"\]',
        'target = ["' + rust_host + '"]',
        content,
        flags=re.MULTILINE,
    )

    with open(config, 'w') as f:
        f.write(content)
}
