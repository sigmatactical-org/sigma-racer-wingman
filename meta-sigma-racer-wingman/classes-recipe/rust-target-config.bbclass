# Shadow poky/meta/classes-recipe/rust-target-config.bbclass (BBPATH prefers meta-sigma-racer-wingman).
# Rust 1.80+ rejects the legacy x86_64 data-layout string when building libstd-rs 1.86.
require ${COREBASE}/meta/classes-recipe/rust-target-config.bbclass

DATA_LAYOUT[x86_64] = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
DATA_LAYOUT[aarch64] = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128-Fn32"

# Rust 1.97 gates custom target JSON (RUST_TARGET_PATH lookup) behind
# -Zunstable-options, and only accepts -Z flags on a stable compiler when
# RUSTC_BOOTSTRAP is set. Applies to every class-target rust build that uses
# the generated sigma triple; native builds use real triples and stay clean.
RUSTFLAGS:append:class-target = " -Zunstable-options"
RUSTC_BOOTSTRAP:class-target = "1"
export RUSTC_BOOTSTRAP

# Rust 1.90+ expects numeric target-c-int-width / target-pointer-width in custom target JSON.
python do_rust_gen_targets:append () {
    import json
    import glob
    import os

    wd = d.getVar('RUST_TARGETS_DIR')
    for path in glob.glob(os.path.join(wd, '*.json')):
        with open(path, 'r') as f:
            tspec = json.load(f)
        changed = False
        for key in ('target-c-int-width', 'target-pointer-width'):
            if key in tspec and isinstance(tspec[key], str):
                tspec[key] = int(tspec[key])
                changed = True
        if changed:
            with open(path, 'w') as f:
                json.dump(tspec, f, indent=4)
}
