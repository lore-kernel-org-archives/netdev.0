From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-review:Andrew-Lunn/ethtool-Add-phy-statistics/20151223-195714] 5d5686595a5cbf1ccfd334bc472bfa1d1441b849 BUILD DONE
Date: Wed, 23 Dec 2015 21:38:21 +0800
Message-ID: <567aa3cd.9HXWI1UV0RsScC9J%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	David Miller <davem@davemloft.net>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:50206 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932242AbbLWNgz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2015 08:36:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

https://github.com/0day-ci/linux  Andrew-Lunn/ethtool-Add-phy-statistic=
s/20151223-195714
5d5686595a5cbf1ccfd334bc472bfa1d1441b849  phy: micrel: Add ethtool stat=
istics counters

ethtool.c:(.text+0x17a0a): undefined reference to `phy_get_sset_count'
ethtool.c:(.text+0x18b92): undefined reference to `phy_get_sset_count'
ethtool.c:(.text+0x18df4): undefined reference to `phy_get_stats'
ethtool.c:(.text+0x1a260): undefined reference to `phy_get_sset_count'
ethtool.c:(.text+0x1be0e): undefined reference to `phy_get_sset_count'
ethtool.c:(.text+0x1c0b6): undefined reference to `phy_get_strings'
ethtool.c:(.text+0x1c1f4): undefined reference to `phy_get_stats'
ethtool.c:(.text+0x1c79e): undefined reference to `phy_get_sset_count'
ethtool.c:(.text+0x1ca46): undefined reference to `phy_get_strings'
ethtool.c:(.text+0x1cb84): undefined reference to `phy_get_stats'
ethtool.c:(.text+0x1d330): undefined reference to `phy_get_sset_count'
ethtool.c:(.text+0x1d96c): undefined reference to `phy_get_sset_count'
ethtool.c:(.text+0x207f0): undefined reference to `phy_get_sset_count'
ethtool.c:(.text+0x23548): undefined reference to `phy_get_strings'
ethtool.c:(.text+0x24314): undefined reference to `phy_get_sset_count'
ethtool.c:(.text+0x25ad4): undefined reference to `phy_get_sset_count'
ethtool.c:(.text+0x275fc): undefined reference to `phy_get_sset_count'
ethtool.c:(.text+0x37b96): undefined reference to `phy_get_sset_count'
ethtool.c:(.text+0x3dd44): undefined reference to `phy_get_sset_count'
ethtool.c:(.text+0x3df06): undefined reference to `phy_get_strings'
ethtool.c:(.text+0x454af): undefined reference to `phy_get_sset_count'
net/core/ethtool.c:(.text+0x1696a): undefined reference to `phy_get_sse=
t_count'
net/core/ethtool.c:(.text+0x169d2): undefined reference to `phy_get_sta=
ts'
net/core/ethtool.c:(.text+0x16e52): undefined reference to `phy_get_str=
ings'
net/core/ethtool.o:(.text.dev_ethtool+0x1660): undefined reference to `=
phy_get_stats'
net/core/ethtool.o:(.text.dev_ethtool+0x1720): undefined reference to `=
phy_get_strings'
net/core/ethtool.o:(.text.dev_ethtool+0x3d8): undefined reference to `p=
hy_get_sset_count'
net/core/ethtool.o:(.text.__ethtool_get_sset_count+0x6c): undefined ref=
erence to `phy_get_sset_count'
net/core/.tmp_ethtool.o:(.text.dev_ethtool+0x1540): undefined reference=
 to `phy_get_stats'
net/core/.tmp_ethtool.o:(.text.dev_ethtool+0x15d4): undefined reference=
 to `phy_get_strings'
net/core/.tmp_ethtool.o:(.text.dev_ethtool+0x3d8): undefined reference =
to `phy_get_sset_count'
net/core/.tmp_ethtool.o:(.text.__ethtool_get_sset_count+0x68): undefine=
d reference to `phy_get_sset_count'
(.text+0x1b164): undefined reference to `phy_get_strings'
(.text+0x1bbfa): undefined reference to `phy_get_sset_count'
(.text+0x1becb): undefined reference to `phy_get_stats'
(.text+0x1d5a4): undefined reference to `phy_get_sset_count'
(.text+0x1dbdc): undefined reference to `phy_get_sset_count'
(.text+0x1e450): undefined reference to `phy_get_stats'
(.text+0x1e500): undefined reference to `phy_get_strings'
(.text+0x1ea60): undefined reference to `phy_get_stats'
(.text+0x1eb10): undefined reference to `phy_get_strings'
(.text+0x20b04): undefined reference to `phy_get_sset_count'
(.text+0x22028): undefined reference to `phy_get_stats'
(.text+0x221d4): undefined reference to `phy_get_strings'
(.text+0x24948): undefined reference to `phy_get_sset_count'
(.text+0x25dec): undefined reference to `phy_get_sset_count'
(.text+0x25e50): undefined reference to `phy_get_stats'
(.text+0x26288): undefined reference to `phy_get_strings'
(.text+0x26344): undefined reference to `phy_get_stats'
(.text+0x26998): undefined reference to `phy_get_strings'
(.text+0x27a14): undefined reference to `phy_get_sset_count'
(.text+0x2844c): undefined reference to `phy_get_strings'
(.text+0x28de8): undefined reference to `phy_get_stats'
(.text+0x38671): undefined reference to `phy_get_sset_count'
(.text+0x38770): undefined reference to `phy_get_stats'
(.text+0x39376): undefined reference to `phy_get_strings'
(.text+0x40a2f): undefined reference to `phy_get_sset_count'
(.text+0x40b04): undefined reference to `phy_get_stats'
(.text+0x439c): undefined reference to `phy_get_sset_count'
(.text+0x4548): undefined reference to `phy_get_strings'
(.text+0x4654): undefined reference to `phy_get_stats'
(.text+0x468c): undefined reference to `phy_get_sset_count'
(.text+0x476a8): undefined reference to `phy_get_strings'
(.text+0x47ec): undefined reference to `phy_get_strings'
(.text+0x48884): undefined reference to `phy_get_sset_count'
(.text+0x48940): undefined reference to `phy_get_stats'
(.text+0x48f8): undefined reference to `phy_get_stats'

Error ids grouped by kconfigs:

recent_errors
=E2=94=9C=E2=94=80=E2=94=80 blackfin-TCM-BF537_defconfig
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 net-core-ethtool.c:(.=
text):undefined-reference-to-phy_get_sset_count
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 net-core-ethtool.c:(.=
text):undefined-reference-to-phy_get_stats
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 net-core-ethtool.c:(.=
text):undefined-reference-to-phy_get_strings
=E2=94=9C=E2=94=80=E2=94=80 cris-etrax-100lx_v2_defconfig
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 ethtool.c:(.text):und=
efined-reference-to-phy_get_stats
=E2=94=9C=E2=94=80=E2=94=80 frv-defconfig
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 ethtool.c:(.text):und=
efined-reference-to-phy_get_sset_count
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 (.text):undefined-ref=
erence-to-phy_get_sset_count
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 (.text):undefined-ref=
erence-to-phy_get_stats
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 (.text):undefined-ref=
erence-to-phy_get_strings
=E2=94=9C=E2=94=80=E2=94=80 i386-allmodconfig
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 ethtool.c:(.text):und=
efined-reference-to-phy_get_sset_count
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 ethtool.c:(.text):und=
efined-reference-to-phy_get_strings
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 (.text):undefined-ref=
erence-to-phy_get_sset_count
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 (.text):undefined-ref=
erence-to-phy_get_stats
=E2=94=9C=E2=94=80=E2=94=80 i386-randconfig-i0-201551
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 ethtool.c:(.text):und=
efined-reference-to-phy_get_sset_count
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 (.text):undefined-ref=
erence-to-phy_get_sset_count
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 (.text):undefined-ref=
erence-to-phy_get_stats
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 (.text):undefined-ref=
erence-to-phy_get_strings
=E2=94=9C=E2=94=80=E2=94=80 m32r-m32104ut_defconfig
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 ethtool.c:(.text):und=
efined-reference-to-phy_get_sset_count
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 (.text):undefined-ref=
erence-to-phy_get_sset_count
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 (.text):undefined-ref=
erence-to-phy_get_stats
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 (.text):undefined-ref=
erence-to-phy_get_strings
=E2=94=9C=E2=94=80=E2=94=80 m32r-mappi3.smp_defconfig
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 ethtool.c:(.text):und=
efined-reference-to-phy_get_sset_count
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 (.text):undefined-ref=
erence-to-phy_get_sset_count
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 (.text):undefined-ref=
erence-to-phy_get_stats
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 (.text):undefined-ref=
erence-to-phy_get_strings
=E2=94=9C=E2=94=80=E2=94=80 m68k-multi_defconfig
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 ethtool.c:(.text):und=
efined-reference-to-phy_get_sset_count
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 ethtool.c:(.text):und=
efined-reference-to-phy_get_stats
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 ethtool.c:(.text):und=
efined-reference-to-phy_get_strings
=E2=94=9C=E2=94=80=E2=94=80 m68k-sun3_defconfig
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 ethtool.c:(.text):und=
efined-reference-to-phy_get_sset_count
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 ethtool.c:(.text):und=
efined-reference-to-phy_get_stats
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 ethtool.c:(.text):und=
efined-reference-to-phy_get_strings
=E2=94=9C=E2=94=80=E2=94=80 mips-fuloong2e_defconfig
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 ethtool.c:(.text):und=
efined-reference-to-phy_get_sset_count
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 (.text):undefined-ref=
erence-to-phy_get_sset_count
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 (.text):undefined-ref=
erence-to-phy_get_stats
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 (.text):undefined-ref=
erence-to-phy_get_strings
=E2=94=9C=E2=94=80=E2=94=80 parisc-b180_defconfig
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 net-core-.tmp_ethtool=
=2Eo:(.text.dev_ethtool):undefined-reference-to-phy_get_sset_count
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 net-core-.tmp_ethtool=
=2Eo:(.text.dev_ethtool):undefined-reference-to-phy_get_stats
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 net-core-.tmp_ethtool=
=2Eo:(.text.dev_ethtool):undefined-reference-to-phy_get_strings
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 net-core-.tmp_ethtool=
=2Eo:(.text.__ethtool_get_sset_count):undefined-reference-to-phy_get_ss=
et_count
=E2=94=9C=E2=94=80=E2=94=80 parisc-c3000_defconfig
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 net-core-ethtool.o:(.=
text.dev_ethtool):undefined-reference-to-phy_get_sset_count
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 net-core-ethtool.o:(.=
text.dev_ethtool):undefined-reference-to-phy_get_stats
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 net-core-ethtool.o:(.=
text.dev_ethtool):undefined-reference-to-phy_get_strings
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 net-core-ethtool.o:(.=
text.__ethtool_get_sset_count):undefined-reference-to-phy_get_sset_coun=
t
=E2=94=9C=E2=94=80=E2=94=80 sh-titan_defconfig
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 ethtool.c:(.text):und=
efined-reference-to-phy_get_strings
=E2=94=9C=E2=94=80=E2=94=80 sparc64-defconfig
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 ethtool.c:(.text):und=
efined-reference-to-phy_get_sset_count
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 (.text):undefined-ref=
erence-to-phy_get_sset_count
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 (.text):undefined-ref=
erence-to-phy_get_stats
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 (.text):undefined-ref=
erence-to-phy_get_strings
=E2=94=9C=E2=94=80=E2=94=80 sparc-defconfig
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 ethtool.c:(.text):und=
efined-reference-to-phy_get_sset_count
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 (.text):undefined-ref=
erence-to-phy_get_sset_count
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 (.text):undefined-ref=
erence-to-phy_get_stats
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 (.text):undefined-ref=
erence-to-phy_get_strings
=E2=94=9C=E2=94=80=E2=94=80 x86_64-allmodconfig
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 ethtool.c:(.text):und=
efined-reference-to-phy_get_sset_count
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 (.text):undefined-ref=
erence-to-phy_get_sset_count
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 (.text):undefined-ref=
erence-to-phy_get_stats
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 (.text):undefined-ref=
erence-to-phy_get_strings
=E2=94=9C=E2=94=80=E2=94=80 x86_64-randconfig-i0-201551
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 ethtool.c:(.text):und=
efined-reference-to-phy_get_sset_count
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 (.text):undefined-ref=
erence-to-phy_get_sset_count
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 (.text):undefined-ref=
erence-to-phy_get_stats
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 (.text):undefined-ref=
erence-to-phy_get_strings
=E2=94=9C=E2=94=80=E2=94=80 xtensa-common_defconfig
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 ethtool.c:(.text):und=
efined-reference-to-phy_get_sset_count
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 (.text):undefined-ref=
erence-to-phy_get_sset_count
=E2=94=82=C2=A0=C2=A0 =E2=94=9C=E2=94=80=E2=94=80 (.text):undefined-ref=
erence-to-phy_get_stats
=E2=94=82=C2=A0=C2=A0 =E2=94=94=E2=94=80=E2=94=80 (.text):undefined-ref=
erence-to-phy_get_strings
=E2=94=94=E2=94=80=E2=94=80 xtensa-iss_defconfig
    =E2=94=9C=E2=94=80=E2=94=80 ethtool.c:(.text):undefined-reference-t=
o-phy_get_sset_count
    =E2=94=9C=E2=94=80=E2=94=80 (.text):undefined-reference-to-phy_get_=
sset_count
    =E2=94=9C=E2=94=80=E2=94=80 (.text):undefined-reference-to-phy_get_=
stats
    =E2=94=94=E2=94=80=E2=94=80 (.text):undefined-reference-to-phy_get_=
strings

elapsed time: 100m

configs tested: 108

alpha                               defconfig
parisc                            allnoconfig
parisc                        c3000_defconfig
parisc                              defconfig
i386                   randconfig-a0-12222034
x86_64                             acpi-redef
x86_64                           allyesdebian
x86_64                                nfsroot
blackfin                BF526-EZBRD_defconfig
blackfin                BF533-EZKIT_defconfig
blackfin            BF561-EZKIT-SMP_defconfig
blackfin                  TCM-BF537_defconfig
cris                 etrax-100lx_v2_defconfig
sh                                allnoconfig
sh                          rsk7269_defconfig
sh                  sh7785lcr_32bit_defconfig
sh                            titan_defconfig
x86_64                           allmodconfig
powerpc                           allnoconfig
powerpc                             defconfig
powerpc                       ppc64_defconfig
parisc                         b180_defconfig
i386                             allmodconfig
x86_64                 randconfig-x015-201551
x86_64                 randconfig-x019-201551
x86_64                 randconfig-x010-201551
x86_64                 randconfig-x016-201551
x86_64                 randconfig-x012-201551
x86_64                 randconfig-x011-201551
x86_64                 randconfig-x013-201551
x86_64                 randconfig-x017-201551
x86_64                 randconfig-x014-201551
x86_64                 randconfig-x018-201551
i386                             alldefconfig
i386                              allnoconfig
i386                                defconfig
m68k                       m5475evb_defconfig
m68k                          multi_defconfig
m68k                           sun3_defconfig
i386                     randconfig-s0-201551
i386                     randconfig-s1-201551
avr32                      atngw100_defconfig
avr32                     atstk1006_defconfig
frv                                 defconfig
mn10300                     asb2364_defconfig
openrisc                    or1ksim_defconfig
tile                         tilegx_defconfig
um                             i386_defconfig
um                           x86_64_defconfig
mips                              allnoconfig
mips                      fuloong2e_defconfig
mips                                   jz4740
mips                                     txx9
x86_64                   randconfig-i0-201551
sparc                               defconfig
sparc64                           allnoconfig
sparc64                             defconfig
microblaze                      mmu_defconfig
microblaze                    nommu_defconfig
i386                     randconfig-i0-201551
i386                     randconfig-i1-201551
m32r                       m32104ut_defconfig
m32r                     mappi3.smp_defconfig
m32r                         opsput_defconfig
m32r                           usrv_defconfig
xtensa                       common_defconfig
xtensa                          iss_defconfig
i386                               tinyconfig
i386                     randconfig-n0-201551
ia64                             alldefconfig
ia64                              allnoconfig
ia64                                defconfig
x86_64                                   rhel
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
x86_64                 randconfig-x000-201551
x86_64                 randconfig-x001-201551
x86_64                 randconfig-x002-201551
x86_64                 randconfig-x003-201551
x86_64                 randconfig-x004-201551
x86_64                 randconfig-x005-201551
x86_64                 randconfig-x006-201551
x86_64                 randconfig-x007-201551
x86_64                 randconfig-x008-201551
x86_64                 randconfig-x009-201551
x86_64                                    lkp
i386                     randconfig-r0-201551
i386                 randconfig-x005-12222106
i386                 randconfig-x004-12222106
i386                 randconfig-x002-12222106
i386                 randconfig-x006-12222106
i386                 randconfig-x007-12222106
i386                 randconfig-x003-12222106
i386                 randconfig-x009-12222106
i386                 randconfig-x008-12222106
i386                 randconfig-x001-12222106
i386                 randconfig-x000-12222106
i386                   randconfig-x0-12231948

Thanks,
=46engguang
