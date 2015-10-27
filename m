From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-review:Neil-Armstrong/net-dsa-cleanup-dsa-driver/20151028-003842] 943beed83806cdd6149e6cf69db108f4c0b6fe31 BUILD DONE
Date: Wed, 28 Oct 2015 01:55:56 +0800
Message-ID: <562fbaac.v+bXfY57XhxnYKjG%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Joe Perches <joe@perches.com>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Fabian Frederick <fabf@skynet.be>,
	vivien.didelot@savoirfairelinux.com,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

https://github.com/0day-ci/linux  Neil-Armstrong/net-dsa-cleanup-dsa-dr=
iver/20151028-003842
943beed83806cdd6149e6cf69db108f4c0b6fe31  net: dsa: make usage of mv88e=
6xxx common remove function

drivers/net/dsa/bcm_sf2.c:1077:14: warning: initialization from incompa=
tible pointer type [-Wincompatible-pointer-types]
drivers/net/dsa/bcm_sf2.c:1077:2: error: unknown field 'remove' specifi=
ed in initializer
drivers/net/dsa/mv88e6123_61_65.c:125:14: warning: initialization from =
incompatible pointer type [-Wincompatible-pointer-types]
drivers/net/dsa/mv88e6123_61_65.c:125:2: error: unknown field 'remove' =
specified in initializer
drivers/net/dsa/mv88e6123_61_65.c:125:2: warning: initialization from i=
ncompatible pointer type
drivers/net/dsa/mv88e6123_61_65.c:125:2: warning: initialization from i=
ncompatible pointer type [enabled by default]
drivers/net/dsa/mv88e6131.c:185:14: warning: initialization from incomp=
atible pointer type [-Wincompatible-pointer-types]
drivers/net/dsa/mv88e6131.c:185:2: error: unknown field 'remove' specif=
ied in initializer
drivers/net/dsa/mv88e6171.c:104:14: warning: initialization from incomp=
atible pointer type [-Wincompatible-pointer-types]
drivers/net/dsa/mv88e6171.c:104:2: error: unknown field 'remove' specif=
ied in initializer
drivers/net/dsa/mv88e6352.c:324:14: warning: initialization from incomp=
atible pointer type [-Wincompatible-pointer-types]
drivers/net/dsa/mv88e6352.c:324:2: error: unknown field 'remove' specif=
ied in initializer
drivers/net/dsa/mv88e6352.c:324:2: warning: initialization from incompa=
tible pointer type
drivers/net/dsa/mv88e6352.c:324:2: warning: initialization from incompa=
tible pointer type [enabled by default]

Error ids grouped by kconfigs:

recent_errors
=E2=94=9C=E2=94=80=E2=94=80 alpha-allyesconfig
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6123_61_65.c:error:unknown-field-remove-specified-in-initializer
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6123_61_65.c:warning:initialization-from-incompatible-pointer-type
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6352.c:error:unknown-field-remove-specified-in-initializer
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6352.c:warning:initialization-from-incompatible-pointer-type
=E2=94=9C=E2=94=80=E2=94=80 blackfin-allyesconfig
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6123_61_65.c:error:unknown-field-remove-specified-in-initializer
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6123_61_65.c:warning:initialization-from-incompatible-pointer-type
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6352.c:error:unknown-field-remove-specified-in-initializer
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6352.c:warning:initialization-from-incompatible-pointer-type
=E2=94=9C=E2=94=80=E2=94=80 cris-allyesconfig
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6123_61_65.c:error:unknown-field-remove-specified-in-initializer
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6123_61_65.c:warning:initialization-from-incompatible-pointer-type
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6352.c:error:unknown-field-remove-specified-in-initializer
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6352.c:warning:initialization-from-incompatible-pointer-type
=E2=94=9C=E2=94=80=E2=94=80 i386-allmodconfig
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-bcm_s=
f2.c:error:unknown-field-remove-specified-in-initializer
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-bcm_s=
f2.c:warning:initialization-from-incompatible-pointer-type
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6123_61_65.c:error:unknown-field-remove-specified-in-initializer
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6123_61_65.c:warning:initialization-from-incompatible-pointer-type
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6171.c:error:unknown-field-remove-specified-in-initializer
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6171.c:warning:initialization-from-incompatible-pointer-type
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6352.c:error:unknown-field-remove-specified-in-initializer
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6352.c:warning:initialization-from-incompatible-pointer-type
=E2=94=9C=E2=94=80=E2=94=80 i386-randconfig-sb0-10280000
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6131.c:error:unknown-field-remove-specified-in-initializer
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6131.c:warning:initialization-from-incompatible-pointer-type
=E2=94=9C=E2=94=80=E2=94=80 ia64-allyesconfig
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6123_61_65.c:error:unknown-field-remove-specified-in-initializer
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6123_61_65.c:warning:initialization-from-incompatible-pointer-type
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6352.c:error:unknown-field-remove-specified-in-initializer
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6352.c:warning:initialization-from-incompatible-pointer-type
=E2=94=9C=E2=94=80=E2=94=80 m68k-allyesconfig
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6123_61_65.c:error:unknown-field-remove-specified-in-initializer
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6123_61_65.c:warning:initialization-from-incompatible-pointer-type
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6352.c:error:unknown-field-remove-specified-in-initializer
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6352.c:warning:initialization-from-incompatible-pointer-type
=E2=94=9C=E2=94=80=E2=94=80 mips-allyesconfig
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6123_61_65.c:error:unknown-field-remove-specified-in-initializer
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6123_61_65.c:warning:initialization-from-incompatible-pointer-type
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6352.c:error:unknown-field-remove-specified-in-initializer
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6352.c:warning:initialization-from-incompatible-pointer-type
=E2=94=9C=E2=94=80=E2=94=80 parisc-allyesconfig
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6123_61_65.c:error:unknown-field-remove-specified-in-initializer
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6123_61_65.c:warning:initialization-from-incompatible-pointer-type
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6352.c:error:unknown-field-remove-specified-in-initializer
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6352.c:warning:initialization-from-incompatible-pointer-type
=E2=94=9C=E2=94=80=E2=94=80 sh-allyesconfig
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6123_61_65.c:error:unknown-field-remove-specified-in-initializer
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6123_61_65.c:warning:initialization-from-incompatible-pointer-type
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6352.c:error:unknown-field-remove-specified-in-initializer
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6352.c:warning:initialization-from-incompatible-pointer-type
=E2=94=9C=E2=94=80=E2=94=80 sparc64-allyesconfig
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6123_61_65.c:error:unknown-field-remove-specified-in-initializer
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6123_61_65.c:warning:initialization-from-incompatible-pointer-type
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6352.c:error:unknown-field-remove-specified-in-initializer
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6352.c:warning:initialization-from-incompatible-pointer-type
=E2=94=9C=E2=94=80=E2=94=80 sparc-allyesconfig
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6123_61_65.c:error:unknown-field-remove-specified-in-initializer
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6123_61_65.c:warning:initialization-from-incompatible-pointer-type
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6352.c:error:unknown-field-remove-specified-in-initializer
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6352.c:warning:initialization-from-incompatible-pointer-type
=E2=94=9C=E2=94=80=E2=94=80 tile-allyesconfig
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6123_61_65.c:error:unknown-field-remove-specified-in-initializer
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6123_61_65.c:warning:initialization-from-incompatible-pointer-type
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6352.c:error:unknown-field-remove-specified-in-initializer
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6352.c:warning:initialization-from-incompatible-pointer-type
=E2=94=9C=E2=94=80=E2=94=80 x86_64-allmodconfig
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-bcm_s=
f2.c:error:unknown-field-remove-specified-in-initializer
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-bcm_s=
f2.c:warning:initialization-from-incompatible-pointer-type
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6123_61_65.c:error:unknown-field-remove-specified-in-initializer
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6123_61_65.c:warning:initialization-from-incompatible-pointer-type
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6171.c:error:unknown-field-remove-specified-in-initializer
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6171.c:warning:initialization-from-incompatible-pointer-type
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6352.c:error:unknown-field-remove-specified-in-initializer
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6352.c:warning:initialization-from-incompatible-pointer-type
=E2=94=9C=E2=94=80=E2=94=80 x86_64-allyesconfig
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6123_61_65.c:error:unknown-field-remove-specified-in-initializer
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6123_61_65.c:warning:initialization-from-incompatible-pointer-type
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6352.c:error:unknown-field-remove-specified-in-initializer
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6352.c:warning:initialization-from-incompatible-pointer-type
=E2=94=9C=E2=94=80=E2=94=80 x86_64-randconfig-x010-201543
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6123_61_65.c:error:unknown-field-remove-specified-in-initializer
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6123_61_65.c:warning:initialization-from-incompatible-pointer-type
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6352.c:error:unknown-field-remove-specified-in-initializer
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 drivers-net-dsa-mv88e=
6352.c:warning:initialization-from-incompatible-pointer-type
=E2=94=94=E2=94=80=E2=94=80 xtensa-allyesconfig
    =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e6123_61_65.c:error=
:unknown-field-remove-specified-in-initializer
    =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e6123_61_65.c:warni=
ng:initialization-from-incompatible-pointer-type
    =E2=94=9C=E2=94=80=E2=94=80 drivers-net-dsa-mv88e6352.c:error:unkno=
wn-field-remove-specified-in-initializer
    =E2=94=94=E2=94=80=E2=94=80 drivers-net-dsa-mv88e6352.c:warning:ini=
tialization-from-incompatible-pointer-type

elapsed time: 76m

configs tested: 130

i386                   randconfig-a0-10252128
x86_64                 randconfig-a0-10280012
blackfin                BF526-EZBRD_defconfig
blackfin                BF533-EZKIT_defconfig
blackfin            BF561-EZKIT-SMP_defconfig
blackfin                  TCM-BF537_defconfig
cris                 etrax-100lx_v2_defconfig
sh                                allnoconfig
sh                          rsk7269_defconfig
sh                  sh7785lcr_32bit_defconfig
sh                            titan_defconfig
i386                   randconfig-c0-10280031
powerpc                           allnoconfig
powerpc                             defconfig
powerpc                       ppc64_defconfig
x86_64                 randconfig-v0-10272326
x86_64                             acpi-redef
x86_64                           allyesdebian
x86_64                                nfsroot
alpha                               defconfig
parisc                            allnoconfig
parisc                         b180_defconfig
parisc                        c3000_defconfig
parisc                              defconfig
arm                        realview_defconfig
frv                               allnoconfig
mips                           xway_defconfig
sparc                            allyesconfig
x86_64                 randconfig-x015-201543
x86_64                 randconfig-x019-201543
x86_64                 randconfig-x014-201543
x86_64                 randconfig-x016-201543
x86_64                 randconfig-x018-201543
x86_64                 randconfig-x011-201543
x86_64                 randconfig-x013-201543
x86_64                 randconfig-x010-201543
x86_64                 randconfig-x017-201543
x86_64                 randconfig-x012-201543
i386                             alldefconfig
i386                              allnoconfig
i386                                defconfig
m68k                       m5475evb_defconfig
m68k                          multi_defconfig
m68k                           sun3_defconfig
i386                     randconfig-s0-201543
i386                     randconfig-s1-201543
x86_64                 randconfig-s0-10280019
x86_64                 randconfig-s1-10280019
x86_64                 randconfig-s2-10280019
avr32                      atngw100_defconfig
avr32                     atstk1006_defconfig
frv                                 defconfig
mn10300                     asb2364_defconfig
openrisc                    or1ksim_defconfig
tile                         tilegx_defconfig
um                             i386_defconfig
um                           x86_64_defconfig
i386                               tinyconfig
i386                             allmodconfig
mips                              allnoconfig
mips                      fuloong2e_defconfig
mips                                   jz4740
mips                                     txx9
x86_64                   randconfig-i0-201543
blackfin                BF537-STAMP_defconfig
powerpc                 mpc834x_itx_defconfig
powerpc                    mvme5100_defconfig
sh                         ap325rxa_defconfig
m68k                        m5272c3_defconfig
mips                            e55_defconfig
powerpc                  iss476-smp_defconfig
sh                           se7619_defconfig
microblaze                      mmu_defconfig
microblaze                    nommu_defconfig
i386                     randconfig-i0-201543
i386                     randconfig-i1-201543
sparc                               defconfig
sparc64                           allnoconfig
sparc64                             defconfig
x86_64                           allmodconfig
m32r                       m32104ut_defconfig
m32r                     mappi3.smp_defconfig
m32r                         opsput_defconfig
m32r                           usrv_defconfig
xtensa                       common_defconfig
xtensa                          iss_defconfig
x86_64                                    lkp
x86_64                                   rhel
i386                   randconfig-n0-10260618
ia64                             alldefconfig
ia64                              allnoconfig
ia64                                defconfig
x86_64                 randconfig-h0-10272348
arm                        multi_v5_defconfig
x86_64                 randconfig-n0-10280034
x86_64                 randconfig-n0-10280100
arm                               allnoconfig
arm                         at91_dt_defconfig
arm                                  at_hdmac
arm                                    ep93xx
arm                       imx_v6_v7_defconfig
arm                                  iop-adma
arm                          marzen_defconfig
arm                          prima2_defconfig
arm                                    sa1100
arm                                   samsung
arm                                        sh
arm                       spear13xx_defconfig
i386                  randconfig-sb0-10280000
x86_64               randconfig-x008-10252017
x86_64               randconfig-x007-10252017
x86_64               randconfig-x001-10252017
x86_64               randconfig-x005-10252017
x86_64               randconfig-x004-10252017
x86_64               randconfig-x000-10252017
x86_64               randconfig-x002-10252017
x86_64               randconfig-x006-10252017
x86_64               randconfig-x009-10252017
x86_64               randconfig-x003-10252017
i386                   randconfig-r0-10252017
i386                   randconfig-x004-201543
i386                   randconfig-x003-201543
i386                   randconfig-x009-201543
i386                   randconfig-x007-201543
i386                   randconfig-x008-201543
i386                   randconfig-x005-201543
i386                   randconfig-x006-201543
i386                   randconfig-x001-201543
i386                   randconfig-x002-201543
i386                   randconfig-x000-201543

Thanks,
=46engguang
