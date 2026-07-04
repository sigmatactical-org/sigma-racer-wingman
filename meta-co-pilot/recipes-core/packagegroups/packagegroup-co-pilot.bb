SUMMARY = "Co-Pilot core system packages"
LICENSE = "MIT"

inherit packagegroup

PACKAGES = " \
    packagegroup-co-pilot-core \
    packagegroup-co-pilot-graphics \
    packagegroup-co-pilot-vehicle \
    packagegroup-co-pilot-navigation \
    packagegroup-co-pilot-connectivity \
    packagegroup-co-pilot-diagnostics \
    packagegroup-co-pilot-ota \
    packagegroup-co-pilot-camera \
"

RDEPENDS:${PN}-core = " \
    systemd \
    systemd-analyze \
    udev \
    bash \
    coreutils \
    iproute2 \
    connman \
    connman-client \
    sqlite3 \
    tzdata \
    co-pilot-user \
"

RDEPENDS:${PN}-graphics = " \
    weston \
    weston-init \
    co-pilot-services \
    instrumentation \
    liberation-fonts \
"

RDEPENDS:${PN}-vehicle = " \
    can-utils \
    iproute2 \
    vehicle-service \
"

RDEPENDS:${PN}-navigation = " \
    gpsd \
    gps-utils \
    navigation-service \
    gps-service \
"

RDEPENDS:${PN}-connectivity = " \
    bluez5 \
    bluez5-obex \
    wpa-supplicant \
    iw \
    bluetooth-service \
"

RDEPENDS:${PN}-diagnostics = " \
    strace \
    htop \
    logger-service \
    diagnostics-service \
"

RDEPENDS:${PN}-ota = " \
    rauc \
    rauc-conf-co-pilot \
    ota-service \
"

RDEPENDS:${PN}-camera = " \
    v4l-utils \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    camera-service \
"
