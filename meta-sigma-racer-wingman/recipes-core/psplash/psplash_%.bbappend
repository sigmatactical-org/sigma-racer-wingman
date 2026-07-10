# Sigma Racer Wingman — black framebuffer splash with grey Sigma mark.
#
# Logo path comes from Source/sigma/sigma.svg (grey fill for black background).
# Regenerate the PNG after editing the SVG:
#   convert -background black -resize 240x240 files/sigma.svg \
#           -depth 8 PNG24:files/psplash-sigma-img.png

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
    file://psplash-colors.h \
    file://psplash-sigma-img.png \
"

SPLASH_IMAGES = "file://psplash-sigma-img.png;outsuffix=default"

# Clean brand frame: no progress bar / startup text over the mark.
PACKAGECONFIG:remove = "progress-bar startup-msg"

do_configure:prepend() {
    install -m 0644 ${WORKDIR}/psplash-colors.h ${S}/psplash-colors.h
}
