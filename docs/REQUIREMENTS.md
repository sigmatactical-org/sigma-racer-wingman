# Motorcycle Instrument Cluster — Ideal Yocto Distribution Requirements

This document is the authoritative requirements specification for the Sigma Sigma Racer Wingman Yocto distribution. Implementation status is tracked in `ARCHITECTURE.md`.

## 1. System Foundation

- The system SHALL be based on a Yocto Project LTS release (Poky-based).
- The system SHALL use systemd as the init and service manager.
- The system SHOULD support a read-only root filesystem for production.
- The system SHOULD support A/B partitioning for safe OTA updates.
- The system SHOULD support secure boot (hardware-dependent).
- The system MAY support TPM-based security features.

## 2. Hardware Platform Support (BSP)

- The system SHALL support NXP i.MX 8M Plus or i.MX 95 class SoCs.
- The system SHALL include a Linux LTS kernel provided via vendor BSP.
- The system SHALL support DRM/KMS display pipeline.
- The system SHALL support OpenGL ES 2.0+ (or Vulkan where available).
- The system SHALL support hardware video decoding where available.
- The system SHALL support CAN bus via SocketCAN.
- The system SHALL support GPIO, I2C, SPI, UART, USB, and Ethernet.
- The system SHALL support Wi-Fi and Bluetooth via standard Linux drivers.

## 3. Graphics & Display Subsystem

- The system SHALL use Wayland as the display protocol.
- The system SHALL use Weston as the reference compositor in kiosk mode.
- The system SHALL support EGL and GBM for buffer management.
- The system SHALL support GPU-accelerated rendering via vendor drivers.
- The system SHALL include font rendering via FreeType and HarfBuzz.
- The system SHOULD support deterministic frame rendering for UI stability.

## 4. Application UI Framework

- The system SHALL support Rust as the primary application language.
- The system SHALL support the Slint UI framework.
- The system SHALL support a single full-screen instrument cluster application.
- The system SHALL support modular UI windows within the application.
- The system SHOULD support GPU-accelerated UI rendering.
- The system SHOULD support reusable UI components (widgets).

## 5. Instrument Cluster UI Model

- The system SHALL implement a persistent instrument layer (speed, RPM, warnings).
- The system SHALL implement a windowed content system for secondary features.
- The system SHALL support the following UI windows:
  - Navigation
  - Connectivity
  - Diagnostics
  - Camera
  - Systems (default vehicle overview)
  - Fuel
  - Maintenance
  - Security
  - GPS / Compass
- The system SHALL ensure critical riding data is always visible.

## 6. Navigation Subsystem

- The system SHALL support offline navigation capabilities.
- The system SHALL support MapLibre Native or equivalent vector map rendering.
- The system SHALL support routing via Valhalla or equivalent routing engine.
- The system SHALL support GPS/GNSS input processing.
- The system SHALL support turn-by-turn navigation display.
- The system SHOULD support GPX route import/export.
- The system MAY support POI search and offline map databases.

## 7. Vehicle Interface Layer

- The system SHALL support CAN bus communication via SocketCAN.
- The system SHALL provide a vehicle signal abstraction layer.
- The system SHALL support real-time vehicle telemetry ingestion.
- The system SHOULD support ECU diagnostics (DTC reading).
- The system SHOULD support sensor fusion (IMU, speed, engine data).
- The system SHOULD support logging of vehicle state data.

## 8. Connectivity Subsystem

- The system SHALL support Bluetooth via BlueZ.
- The system SHALL support smartphone pairing.
- The system SHALL support notifications from mobile devices.
- The system SHALL support Wi-Fi networking.
- The system SHOULD support a companion mobile application interface.
- The system MAY support music metadata and media control.

## 9. Camera Subsystem

- The system MAY support front and/or rear camera input.
- The system SHOULD support V4L2-based camera interfaces.
- The system MAY support picture-in-picture display in UI.
- The system MAY support camera switching and snapshot capture.

## 10. Diagnostics & Logging

- The system SHALL support structured logging (journald).
- The system SHOULD support CAN traffic logging.
- The system SHOULD support system health monitoring.
- The system SHOULD support crash reporting and dump collection.
- The system MAY support performance telemetry (CPU/GPU/memory).

## 11. Update & Lifecycle Management

- The system SHALL support secure OTA updates.
- The system SHALL support A/B partition rollback.
- The system SHOULD use RAUC or equivalent update framework.
- The system SHOULD support signed update packages.
- The system SHOULD support delta updates where possible.

## 12. Storage & Data

- The system SHALL support persistent storage for configuration data.
- The system SHALL support SQLite or equivalent embedded database.
- The system SHALL support structured ride logs and trip data storage.
- The system SHOULD support offline navigation data storage.
- The system MAY support cloud synchronization via companion app.

## 13. System Services Architecture

- The system SHALL use modular systemd services.
- The system SHALL isolate major subsystems into separate services:
  - cluster-ui.service
  - sigma-racer-vehicle
  - navigation.service
  - gps.service
  - bluetooth.service
  - camera.service
  - logger.service
  - ota.service
  - diagnostics.service
- The system SHOULD support independent restart of services.

## 14. Boot & Runtime Behavior

- The system SHALL boot directly into the instrument cluster UI.
- The system SHALL display core riding information as early as possible.
- The system SHOULD initialize vehicle data acquisition in parallel with UI startup.
- The system SHOULD defer non-critical services after UI startup.
- The system SHALL recover gracefully from application failure (watchdog or restart).

## 15. Performance Requirements

- The system SHALL support smooth UI rendering at 60 FPS where possible.
- The system SHOULD maintain low input latency for rider interactions.
- The system SHALL prioritize deterministic rendering for speed/RPM indicators.
- The system SHOULD minimize boot-to-display time for critical UI.

## 16. Design Principles

- The system SHALL be offline-first for core riding functionality.
- The system SHALL prioritize safety-critical information visibility.
- The system SHOULD be modular and hardware-agnostic at the application layer.
- The system SHOULD minimize dependencies on large automotive middleware stacks.
- The system SHALL separate UI, vehicle logic, and navigation concerns cleanly.
