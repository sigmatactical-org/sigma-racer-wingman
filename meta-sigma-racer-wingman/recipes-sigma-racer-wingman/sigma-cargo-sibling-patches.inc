# Patch git sibling deps to EXTERNALSRC paths for --frozen cargo builds.
# Sibling crates use mixed SSH/HTTPS git URLs in Cargo.toml; patch both schemes
# so transitive deps (e.g. telemetry -> sidearm) resolve offline in Yocto.

do_configure:append() {
	cat >> ${CARGO_HOME}/config <<-EOF

	[patch."ssh://git@github.com/sigmatactical-org/sigma-racer-sidearm.git"]
	sigma-racer-sidearm = { path = "${SIGMA_RACER_SIDEARM_SRC}" }

	[patch."https://github.com/sigmatactical-org/sigma-racer-sidearm.git"]
	sigma-racer-sidearm = { path = "${SIGMA_RACER_SIDEARM_SRC}" }

	[patch."ssh://git@github.com/sigmatactical-org/sigma-racer-telemetry.git"]
	sigma-racer-telemetry = { path = "${SIGMA_RACER_TELEMETRY_SRC}" }

	[patch."https://github.com/sigmatactical-org/sigma-racer-telemetry.git"]
	sigma-racer-telemetry = { path = "${SIGMA_RACER_TELEMETRY_SRC}" }
	EOF
}
