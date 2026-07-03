# Shadow poky/meta/classes-recipe/rust-target-config.bbclass (BBPATH prefers meta-co-pilot).
# Rust 1.80+ rejects the legacy x86_64 data-layout string when building libstd-rs 1.86.
require ${COREBASE}/meta/classes-recipe/rust-target-config.bbclass

DATA_LAYOUT[x86_64] = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
