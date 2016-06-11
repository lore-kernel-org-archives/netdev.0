From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mac80211-next:master] e69f73bfecb0178ae6bd20eb778211739cd71fab
 BUILD DONE
Date: Sat, 11 Jun 2016 17:10:30 +0800
Message-ID: <575bd586.nMAa0lD24jskMir5%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:25865 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750878AbcFKIxf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Jun 2016 04:53:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

https://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.git=
  master
e69f73bfecb0178ae6bd20eb778211739cd71fab  Merge branch 'remove-qdisc-th=
rottle'

drivers/net/virtio_net.c:841:2-5: WARNING: Use BUG_ON instead of if con=
dition followed by BUG.

Error ids grouped by kconfigs:

recent_errors
=E2=94=94=E2=94=80=E2=94=80 i386-allmodconfig
    =E2=94=94=E2=94=80=E2=94=80 drivers-net-virtio_net.c:WARNING:Use-BU=
G_ON-instead-of-if-condition-followed-by-BUG.


i386-tinyconfig vmlinux size:

+-------+---------------+----------------------------------------------=
-----------------------------+
| DELTA |    SYMBOL     |                                  COMMIT      =
                             |
+-------+---------------+----------------------------------------------=
-----------------------------+
|  -163 | TOTAL         | 6b15d6650c53..e69f73bfecb0 (ALL COMMITS)     =
                             |
|  -168 | TOTAL         | 1578b0a5e928 Merge git://git.kernel.org/pub/s=
cm/linux/kernel/git/davem/ne |
|  -174 | TEXT          | 1578b0a5e928 Merge git://git.kernel.org/pub/s=
cm/linux/kernel/git/davem/ne |
|  +348 | mm/           | 1578b0a5e928 Merge git://git.kernel.org/pub/s=
cm/linux/kernel/git/davem/ne |
|   -65 | do_mount()    | 1578b0a5e928 Merge git://git.kernel.org/pub/s=
cm/linux/kernel/git/davem/ne |
|  -210 | path_openat() | 1578b0a5e928 Merge git://git.kernel.org/pub/s=
cm/linux/kernel/git/davem/ne |
|  -296 | fs/           | 1578b0a5e928 Merge git://git.kernel.org/pub/s=
cm/linux/kernel/git/davem/ne |
+-------+---------------+----------------------------------------------=
-----------------------------+

elapsed time: 113m

configs tested: 105

alpha                               defconfig
parisc                            allnoconfig
parisc                        c3000_defconfig
parisc                              defconfig
i386                     randconfig-a0-201623
blackfin                BF526-EZBRD_defconfig
blackfin                BF533-EZKIT_defconfig
blackfin            BF561-EZKIT-SMP_defconfig
blackfin                  TCM-BF537_defconfig
cris                 etrax-100lx_v2_defconfig
i386                             allyesconfig
x86_64                             acpi-redef
x86_64                           allyesdebian
x86_64                                nfsroot
parisc                         b180_defconfig
x86_64                 randconfig-x010-201623
x86_64                 randconfig-x011-201623
x86_64                 randconfig-x012-201623
x86_64                 randconfig-x013-201623
x86_64                 randconfig-x014-201623
x86_64                 randconfig-x015-201623
x86_64                 randconfig-x016-201623
x86_64                 randconfig-x017-201623
x86_64                 randconfig-x018-201623
x86_64                 randconfig-x019-201623
m68k                       m5475evb_defconfig
m68k                          multi_defconfig
m68k                           sun3_defconfig
i386                     randconfig-s0-201623
i386                     randconfig-s1-201623
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
powerpc                           allnoconfig
powerpc                             defconfig
powerpc                       ppc64_defconfig
s390                        default_defconfig
x86_64                   randconfig-i0-201623
microblaze                      mmu_defconfig
microblaze                    nommu_defconfig
i386                     randconfig-i0-201623
i386                     randconfig-i1-201623
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
ia64                             alldefconfig
ia64                              allnoconfig
ia64                                defconfig
x86_64                                   rhel
arm                               allnoconfig
arm                         at91_dt_defconfig
arm                           efm32_defconfig
arm                          exynos_defconfig
arm                        multi_v5_defconfig
arm                        multi_v7_defconfig
arm                        shmobile_defconfig
arm                           sunxi_defconfig
arm64                             allnoconfig
arm64                               defconfig
sh                                allnoconfig
sh                          rsk7269_defconfig
sh                  sh7785lcr_32bit_defconfig
sh                            titan_defconfig
x86_64                 randconfig-x007-201623
x86_64                 randconfig-x006-201623
x86_64                 randconfig-x003-201623
x86_64                 randconfig-x000-201623
x86_64                 randconfig-x008-201623
x86_64                 randconfig-x005-201623
x86_64                 randconfig-x004-201623
x86_64                 randconfig-x001-201623
x86_64                 randconfig-x002-201623
x86_64                 randconfig-x009-201623
i386                     randconfig-r0-201623
i386                   randconfig-x005-201623
i386                   randconfig-x008-201623
i386                   randconfig-x000-201623
i386                   randconfig-x009-201623
i386                   randconfig-x003-201623
i386                   randconfig-x006-201623
i386                   randconfig-x001-201623
i386                   randconfig-x004-201623
i386                   randconfig-x007-201623
i386                   randconfig-x002-201623
i386                              allnoconfig
i386                                defconfig
i386                             alldefconfig

Thanks,
=46engguang
