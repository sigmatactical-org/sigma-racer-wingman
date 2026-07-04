SUMMARY = "Dedicated cluster UI user account"
LICENSE = "MIT"

inherit useradd

ALLOW_EMPTY:${PN} = "1"

USERADD_PACKAGES = "${PN}"
USERADD_PARAM:${PN} = "-r -s /bin/false -d /var/lib/cluster -g ${CO_PILOT_GROUP} ${CO_PILOT_USER}"
GROUPADD_PARAM:${PN} = "-r ${CO_PILOT_GROUP}"

do_install[noexec] = "1"
