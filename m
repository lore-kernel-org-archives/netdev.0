From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.28-rc1-git1: Reported regressions from 2.6.27
Date: Sat, 25 Oct 2008 22:02:47 +0200 (CEST)
Message-ID: <nw2Y6lk-0lG.A.VUB.RV5AJB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This message contains a list of some regressions from 2.6.27, for which=
 there
are no fixes in the mainline I know of.  If any of them have been fixed=
 already,
please let me know.

If you know of any other unresolved regressions from 2.6.27, please let=
 me know
either and I'll add them to the list.  Also, please let me know if any =
of the
entries below are invalid.

Each entry from the list will be sent additionally in an automatic repl=
y to
this message with CCs to the people involved in reporting and handling =
the
issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2008-10-25       26       25          20


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11854
Subject		: v2.6.28-rc1: readlink /proc/*/exe returns uninitialized data=
 to userspace
Submitter	: Vegard Nossum <vegard.nossum@gmail.com>
Date		: 2008-10-25 17:14 (1 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122495490201663&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11853
Subject		: Random problems with 2.6.28-rc1-git1
Submitter	: Mikko C. <mikko.cal@gmail.com>
Date		: 2008-10-25 14:53 (1 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122494643521893&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11852
Subject		: v2.6.28-rc1: Regression in ext3/jbd
Submitter	: Vegard Nossum <vegard.nossum@gmail.com>
Date		: 2008-10-25 11:22 (1 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122493379905812&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11849
Subject		: default IRQ affinity change in v2.6.27 (breaking several SMP=
 PPC based systems)
Submitter	: Kumar Gala <galak@kernel.crashing.org>
Date		: 2008-10-24 12:45 (2 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122485245924125&w=3D=
4
Handled-By	: Chris Snook <csnook@redhat.com>
		  Scott Wood <scottwood@freescale.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11848
Subject		: 2.6.28-rc1: NCQ devices connected to PMP are  still dead
Submitter	: Petr Vandrovec <vandrove@vc.cvut.cz>
Date		: 2008-10-25 11:17 (1 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122493470907259&w=3D=
4
Handled-By	: Jens Axboe <jens.axboe@oracle.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11845
Subject		: Suspend regression on Lenovo x60
Submitter	: Jens Axboe <jens.axboe@oracle.com>
Date		: 2008-10-24 18:02 (2 days old)
References	: http://marc.info/?l=3Dlinux-next&m=3D122487159829507&w=3D4
Handled-By	: Rafael J. Wysocki <rjw@sisk.pl>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11841
Subject		: plenty of line "ACPI: EC: non-query interrupt received, swit=
ching to interrupt mode" in dmesg
Submitter	: Fran=C3=A7ois Valenduc <francois.valenduc@tvcablenet.be>
Date		: 2008-10-25 10:29 (1 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11838
Subject		: general protection fault: =C2=A0from release_blocks_on_commi=
t
Submitter	: Eric Paris <eparis@redhat.com>
Date		: 2008-10-21 14:03 (5 days old)
References	: http://lkml.org/lkml/2008/10/21/248


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11835
Subject		: 2.6.27-git8: max1111_read_channel and corgi_ssp_ads7846_putg=
et missing
Submitter	: Pavel Machek <pavel@suse.cz>
Date		: 2008-10-20 12:10 (6 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122450475101945&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11834
Subject		: iwl3945: if I leave my machine running overnight, wifi will =
not work in the morning
Submitter	: Pavel Machek <pavel@suse.cz>
Date		: 2008-10-19 21:40 (7 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122445440206101&w=3D=
4
Handled-By	: reinette chatre <reinette.chatre@intel.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11833
Subject		: 2.6.27-git8 compile error in drivers/mfd/wm8350-core.c
Submitter	: Tilman Schmidt <tilman@imap.cc>
Date		: 2008-10-19 18:17 (7 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122444027920472&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11828
Subject		: Linux 2.6.27-git3: no SD card reader
Submitter	: J.A. Magall=C3=B3n <jamagallon@ono.com>
Date		: 2008-10-14 0:54 (12 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122394573904699&w=3D=
4
Handled-By	: Pierre Ossman <drzeus-list@drzeus.cx>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11827
Subject		: suspend broken on powerbook5,6
Submitter	: Johannes Berg <johannes@sipsolutions.net>
Date		: 2008-10-25 05:07 (1 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11826
Subject		: extreme slowness of IO stuff using 2.6.28-rc1
Submitter	: Yves-Alexis Perez <corsac@debian.org>
Date		: 2008-10-25 04:25 (1 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11824
Subject		: raw1394: possible deadlock if accessed by multithreaded app
Submitter	: Stefan Richter <stefan-r-bz@s5r6.in-berlin.de>
Date		: 2008-10-25 02:08 (1 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11822
Subject		: ACPI Warning (nspredef-0858): _SB_.PCI0.LPC_.EC__.BAT0._BIF:=
 Return Package type mismatch at index 9 - found Buffer, expected Strin=
g [20080926]
Submitter	: Len Brown <len.brown@intel.com>
Date		: 2008-10-25 01:26 (1 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11806
Subject		: iwl3945 fails with microcode error
Submitter	: Johannes Berg <johannes@sipsolutions.net>
Date		: 2008-10-22 02:36 (4 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122450235730661&w=3D=
4
Handled-By	: Reinette Chatre <reinette.chatre@intel.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11805
Subject		: mounting XFS produces a segfault
Submitter	: Tiago Maluta <maluta_tiago@yahoo.com.br>
Date		: 2008-10-21 18:00 (5 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11799
Subject		: xorg can not start up with stolen memory
Submitter	: arrow zhang <arrow.ebd@gmail.com>
Date		: 2008-10-21 06:08 (5 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11798
Subject		: [Radeon Xpress 1100 IGP] DRI fail on recent kernel updates
Submitter	: Gu Rui <chaos.proton@gmail.com>
Date		: 2008-10-21 04:28 (5 days old)


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11851
Subject		: wmifinfo dockapp takes 100% of cpu
Submitter	: Carlos R. Mafra <crmafra2@gmail.com>
Date		: 2008-10-25 9:40 (1 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122492763030453&w=3D=
4
Handled-By	: Arjan van de Ven <arjan@linux.intel.com>
		  Marcin Slusarz <marcin.slusarz@gmail.com>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122496409612709&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11847
Subject		: 2.6.28-rc1 fails building on allnoconfig
Submitter	: Matt Mackall <mpm@selenic.com>
Date		: 2008-10-24 17:09 (2 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122487097728241&w=3D=
4
		  http://marc.info/?l=3Dlinux-pci&m=3D122485633732409&w=3D4
Handled-By	: Fenghua Yu <fenghua.yu@intel.com>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122487160129531&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11846
Subject		: commit a802dd0e breaks console keyboard input
Submitter	: walt <w41ter@gmail.com>
Date		: 2008-10-24 0:09 (2 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122480701528944&w=3D=
4
Handled-By	: Heiko Carstens <heiko.carstens@de.ibm.com>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122487763507703&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11844
Subject		: ext3: fix ext3_dx_readdir hash collision handling
Submitter	: Markus Trippelsdorf <markus@trippelsdorf.de>
Date		: 2008-10-25 11:56 (1 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122493582908742&w=3D=
4
Handled-By	: Theodore Tso <tytso@mit.edu>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122493582908742&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11825
Subject		: appletouch broken
Submitter	: Johannes Berg <johannes@sipsolutions.net>
Date		: 2008-10-25 03:55 (1 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122433436930451&w=3D=
4
Handled-By	: Jiri Slaby <jirislaby@gmail.com>
		  Jiri Kosina <jkosina@suse.cz>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122442584100873&w=3D4


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions from 2=
=2E6.27,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D11808

Please let me know if there are any Bugzilla entries that should be add=
ed to
the list in there.

Thanks,
Rafael

--
To unsubscribe from this list: send the line "unsubscribe linux-scsi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
