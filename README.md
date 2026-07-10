# Sigma Racer Wingman — Motorcycle Instrument Cluster Yocto Distribution

Custom Yocto Project distribution for an offline-first motorcycle instrument cluster on NXP i.MX 8M Plus / i.MX 95 class hardware.

## Overview

| Item | Value |
|------|-------|
| Distro | `sigma-racer-wingman` |
| Yocto LTS | Scarthgap (5.0) |
| Init | systemd |
| Display | Wayland + Weston (kiosk) |
| UI | Rust + Slint (`sigma-racer-cluster`) |
| BSP | NXP meta-imx (i.MX 8M Plus / i.MX 95) or QEMU x86-64 (virt testing) |
| OTA | RAUC A/B (optional, production) |

## Repository layout

```
sigma-racer-wingman/
├── sigma-instrumentation/  → symlink to ../sigma-instrumentation (UI library)
├── sigma-racer-cluster/    → symlink to ../sigma-racer-cluster (sole UI binary)
├── sigma-racer-vehicle/    → symlink to ../sigma-racer-vehicle (vehicle daemon)
├── sigma-racer-telemetry/  → symlink to ../sigma-racer-telemetry (VSS / IPC library)
├── sigma-racer-sidearm/    → symlink to ../sigma-racer-sidearm (M7 firmware + CAN contract)
├── conf/                        Sample bblayers.conf and local.conf
├── docs/                        Architecture and requirements
├── meta-sigma-racer-wingman/     Custom Yocto layer
│   ├── recipes-sigma-racer-wingman/sigma-racer-cluster/   sigma-racer-cluster binary + cluster-ui.service
│   └── ...
├── setup-environment.sh
└── build/
```

## UI

**sigma-racer-cluster** (`sigma-racer-cluster`) is the only UI on the device. Weston runs as a headless Wayland compositor; the cluster app fills the screen via `cluster-ui.service`.

Boot chain: `sysinit` (psplash — grey Sigma on black) → `graphical.target` → `sigma-racer-wingman-ui.target` → `weston.service` + `cluster-ui.service` → `/usr/bin/sigma-racer-cluster`

Framebuffer splash assets live in `meta-sigma-racer-wingman/recipes-core/psplash/` (mark from `Source/sigma/sigma.svg`).

## Quick start

### 1. Clone dependent layers (sibling to `sigma-racer-wingman/` under `embedded/`)

```bash
cd ~/Source/sigma/embedded

git clone -b scarthgap https://git.yoctoproject.org/poky
git clone -b scarthgap https://github.com/openembedded/meta-openembedded
git clone -b scarthgap https://github.com/Freescale/meta-freescale
git clone -b scarthgap https://github.com/Freescale/meta-freescale-3rdparty
git clone -b scarthgap https://github.com/meta-rust/meta-rust
git clone -b scarthgap https://github.com/kraj/meta-clang
git clone -b scarthgap https://github.com/rauc/meta-rauc

# NXP i.MX BSP — download from NXP matching Scarthgap release
# Extract meta-imx into embedded/meta-imx
```

### 2. Initialize build environment

```bash
cd ~/Source/sigma/embedded/sigma-racer-wingman
chmod +x setup-environment.sh
source setup-environment.sh sigma-racer-wingman-imx8mp
```

### 3. Build

```bash
# Accept NXP EULA in conf/local.conf if required:
# ACCEPT_FSL_EULA = "1"

bitbake sigma-racer-wingman-image
```

Output: `build/tmp/deploy/images/sigma-racer-wingman-imx8mp/sigma-racer-wingman-image-sigma-racer-wingman-imx8mp.wic.gz`

### Virtual testing (800×480 QEMU)

Run the full Sigma Racer Wingman stack locally without NXP hardware — same panel resolution as `sigma-racer-wingman-imx8mp`:

```bash
source setup-environment.sh sigma-racer-wingman-qemu
bitbake sigma-racer-wingman-image
../scripts/run-qemu.sh
```

Uses `build-virt/` (separate from hardware `build/`) and a slimmer layer set — no meta-imx or meta-freescale. The QEMU SDL window is fixed at **800×480**. For the slimmer virt-only image: `IMAGE=sigma-racer-wingman-image-virt ../scripts/run-qemu.sh`.

For UI-only iteration without Yocto:

```bash
cd ../sigma-instrumentation && cargo virt
```

### 4. Flash

```bash
zcat tmp/deploy/images/sigma-racer-wingman-imx8mp/sigma-racer-wingman-image-sigma-racer-wingman-imx8mp.wic.gz | sudo dd of=/dev/sdX bs=4M status=progress
```

## System services

| Service | Purpose |
|---------|---------|
| `weston.service` | Wayland compositor (no UI of its own) |
| `cluster-ui.service` | **sigma-racer-cluster** — sole UI (`/usr/bin/sigma-racer-cluster`) |
| `sigma-racer-vehicle.service` | CAN → VSS telemetry publisher (`sigma-racer-vehicle`) |
| `navigation.service` | Turn-by-turn / map window |
| `gps.service` | GNSS input |
| `bluetooth.service` | BlueZ companion phone interface |
| `camera.service` | V4L2 camera / PiP |
| `logger.service` | Ride logs, CAN capture |
| `ota.service` | RAUC update orchestration |
| `diagnostics.service` | DTC / health monitoring |

Stub services (`navigation`, etc.) install placeholder daemons until real implementations land. `sigma-racer-vehicle` is the real vehicle signal daemon.

## Production options

Enable in `conf/local.conf`:

```bitbake
DISTRO_FEATURES:append = " rauc read-only-rootfs tpm2"
EXTRA_IMAGE_FEATURES += " read-only-rootfs"
```

Configure RAUC signing keys (never commit production keys):

```bitbake
RAUC_KEY_FILE = "${TOPDIR}/../keys/rauc/development-key.pem"
RAUC_CERT_FILE = "${TOPDIR}/../keys/rauc/development-ca.cert.pem"
```

## Instrumentation UI integration

The **sigma-racer-cluster** product app is linked at `sigma-racer-wingman/sigma-racer-cluster` (symlink to `../sigma-racer-cluster`) and built as the `sigma-racer-cluster` Yocto package. It is the only UI on the image. The **sigma-instrumentation** library repo remains a sibling dependency for the Rust build.

Override source paths in `local.conf`:

```bitbake
SIGMA_INSTRUMENTATION_SRC = "/path/to/sigma-instrumentation"
SIGMA_RACER_CLUSTER_SRC = "/path/to/sigma-racer-cluster"
SIGMA_RACER_VEHICLE_SRC = "/path/to/sigma-racer-vehicle"
```

Desktop dev (windowed):

```bash
cd ../sigma-racer-cluster && cargo run --bin sigma-racer-cluster
```

Panel-accurate local testing (800×480, matches imx8mp / QEMU virt):

```bash
cd ../sigma-instrumentation && cargo virt
```

Target kiosk (fullscreen, set automatically when built with `--cfg sigma_racer_wingman_embedded` or `SLINT_FULLSCREEN=1`):

```bash
SLINT_FULLSCREEN=1 cargo run --bin sigma-racer-cluster
```

## UI window model

The cluster application implements:

- **Persistent layer** — speed, RPM, warnings (always visible)
- **Windowed content** — Navigation, Connectivity, Diagnostics, Camera, Systems, Fuel, Maintenance, Security, GPS/Compass

See `docs/ARCHITECTURE.md` for service boundaries and data flow.

## Requirements traceability

Full specification: `docs/REQUIREMENTS.md`

## License

Layer metadata: MIT. Image contents inherit respective upstream licenses. NXP BSP components require EULA acceptance.
