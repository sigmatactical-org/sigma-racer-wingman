SUMMARY = "Sigma Racer Wingman OTA install daemon (RAUC front-end)"
DESCRIPTION = "Watches /run/sigma-ota/request for a bundle URL from the \
cluster UI, downloads it, and applies it with `rauc install`, reporting \
progress through /run/sigma-ota/status."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SIGMA_RACER_WINGMAN_SERVICE_NAME = "ota"

inherit sigma-racer-wingman-stub-service

RDEPENDS:${PN} += "curl rauc"
