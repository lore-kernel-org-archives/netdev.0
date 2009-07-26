From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.31-rc4: Reported regressions from 2.6.30
Date: Sun, 26 Jul 2009 22:23:24 +0200 (CEST)
Message-ID: <Jya1GruKQpD.A.16.2GObKB@chimera>
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
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.sourceforge.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This message contains a list of some regressions from 2.6.30, for which=
 there
are no fixes in the mainline I know of.  If any of them have been fixed=
 already,
please let me know.

If you know of any other unresolved regressions from 2.6.30, please let=
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
  2009-07-27       70       51          43
  2009-07-07       35       25          21
  2009-06-29       22       22          15


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13848
Subject		: iwlwifi (4965) regression since 2.6.30
Submitter	: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Date		: 2009-07-26 7:57 (1 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124859658502866&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13847
Subject		: X stopped accepting keystrokes
Submitter	: Pavel Machek <pavel@ucw.cz>
Date		: 2009-07-14 9:24 (13 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124756352426737&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13846
Subject		: Possible regression in rt61pci driver
Submitter	: Chris Clayton <chris2553@googlemail.com>
Date		: 2009-07-13 8:27 (14 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124747418828398&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13845
Subject		: inotify regression, missing events
Submitter	: Scott James Remnant <scott@ubuntu.com>
Date		: 2009-07-11 16:02 (16 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124732816314881&w=3D=
4
Handled-By	: Eric Paris <eparis@redhat.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13844
Subject		: i915 errors
Submitter	: Fabio Comolli <fabio.comolli@gmail.com>
Date		: 2009-07-25 9:30 (2 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124851427612720&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13843
Subject		: Linux-2.6.31-rc4 fails to open a USB serial port
Submitter	: e9hack <e9hack@googlemail.com>
Date		: 2009-07-25 9:16 (2 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124851343512022&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13842
Subject		: Oops when writing to /sys/block/ram0/queue/max_sectors_kb
Submitter	: Jens Rosenboom <jens@mcbone.net>
Date		: 2009-07-23 15:30 (4 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124836574403032&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13841
Subject		: 2.6.31-rc4 boot failure
Submitter	: Gene Heskett <gene.heskett@verizon.net>
Date		: 2009-07-23 14:12 (4 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124835839019906&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13839
Subject		: xc5000 no longer works with Myth-0.21-fixes branch
Submitter	: Mark Lord <lkml@rtr.ca>
Date		: 2009-07-19 15:15 (8 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124814394016848&w=3D=
4
Handled-By	: Devin Heitmueller <dheitmueller@kernellabs.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13838
Subject		: kernel BUG at include/net/netns/generic.h:41!
Submitter	: Luca Tettamanti <kronos.it@gmail.com>
Date		: 2009-07-20 15:27 (7 days old)
References	: http://lkml.org/lkml/2009/7/20/105


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13837
Subject		: Input : regression - touchpad not detected
Submitter	: Dave Young <hidave.darkstar@gmail.com>
Date		: 2009-07-17 07:13 (10 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124780763701571&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13836
Subject		: suspend script fails, related to stdout?
Submitter	: Tomas M. <tmezzadra@gmail.com>
Date		: 2009-07-17 21:24 (10 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124785853811667&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13835
Subject		: e1000e massive packet loss
Submitter	: Caleb Cushing <xenoterracide@gmail.com>
Date		: 2009-07-16 09:49 (11 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124773057917887&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13833
Subject		: Kernel Oops when trying to suspend with ubifs mounted on blo=
ck2mtd mtd device
Submitter	: Tobias Diedrich <ranma@tdiedrich.de>
Date		: 2009-07-15 14:20 (12 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D15bce40cb3133bcc07d548013df97e4653d363c1
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124766049207807&w=3D=
4
		  http://marc.info/?l=3Dlinux-kernel&m=3D124704927819769&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13826
Subject		: thinkpad boots with backlight low
Submitter	: Pavel Machek <pavel@ucw.cz>
Date		: 2009-07-15 15:13 (12 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124756359126830&w=3D=
4
Handled-By	: Henrique de Moraes Holschuh <hmh@hmh.eng.br>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13821
Subject		: Replugging USB serial converter uses new device node
Submitter	: Ferenc Wagner <wferi@niif.hu>
Date		: 2009-07-18 20:04 (9 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124794754015776&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13819
Subject		: system freeze when switching to console
Submitter	: Reinette Chatre <reinette.chatre@intel.com>
Date		: 2009-07-23 17:57 (4 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13815
Subject		: emacs -nw compilation doesn't show the error message
Submitter	: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Date		: 2009-07-23 06:22 (4 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dd945cb9cce20ac7143c2de8d88b187f62db99bdc


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13813
Subject		: Hangups in n_tty_read()
Submitter	: Johannes Weiner <hannes@cmpxchg.org>
Date		: 2009-07-16 18:48 (11 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124777019920579&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13812
Subject		: Ooops on uplug
Submitter	: Daniel Mack <daniel@caiaq.de>
Date		: 2009-07-20 17:51 (7 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124811234302786&w=3D=
4
Handled-By	: Alan Stern <stern@rowland.harvard.edu>
		  Alan Cox <alan@linux.intel.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13809
Subject		: oprofile: possible circular locking dependency detected
Submitter	: Jerome Marchand <jmarchan@redhat.com>
Date		: 2009-07-22 13:35 (5 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13806
Subject		: system does not boot due to device-mapper error
Submitter	: Roman Shtylman <shtylman@gmail.com>
Date		: 2009-07-21 00:03 (6 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13781
Subject		: System freeze at resume after suspend to RAM
Submitter	: Christian Casteyde <casteyde.christian@free.fr>
Date		: 2009-07-15 18:42 (12 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13770
Subject		: System freeze on XFS filesystem recovery on an external disk
Submitter	: Jean-Luc Coulon <jean.luc.coulon@gmail.com>
Date		: 2009-07-14 10:31 (13 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13762
Subject		: AHCI on HP Compaq 6715s broken, did not detect slots/ports -=
> unable to boot
Submitter	: Matthias Tingelhoff <mindo83@t-online.de>
Date		: 2009-07-11 20:48 (16 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13750
Subject		: Load average flatlines after returning from hibernate
Submitter	: Duncan <1i5t5.duncan@cox.net>
Date		: 2009-07-09 15:14 (18 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13740
Subject		: X server crashes with 2.6.31-rc2 when options are changed
Submitter	: Michael S. Tsirkin <m.s.tsirkin@gmail.com>
Date		: 2009-07-07 15:19 (20 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13733
Subject		: 2.6.31-rc2: irq 16: nobody cared
Submitter	: Niel Lambrechts <niel.lambrechts@gmail.com>
Date		: 2009-07-06 18:32 (21 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124690524027166&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13732
Subject		: tty layer instabilities
Submitter	: Mikael Pettersson <mikpe@it.uu.se>
Date		: 2009-07-06 13:43 (21 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124688781732419&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13731
Subject		: Inconsistent {IN-RECLAIM_FS-W} -> {RECLAIM_FS-ON-W} usage.
Submitter	: Miles Lane <miles.lane@gmail.com>
Date		: 2009-07-06 4:22 (21 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124685417325348&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13730
Subject		: hitting lockdep limits...
Submitter	: Daniel J Blueman <daniel.blueman@gmail.com>
Date		: 2009-07-05 18:19 (22 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124681799023782&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13729
Subject		: kernel BUG at fs/notify/notification.c:93!
Submitter	: Mikko C. <mikko.cal@gmail.com>
Date		: 2009-06-04 10:16 (53 days old)
References	: http://lkml.org/lkml/2009/7/4/12
Handled-By	: Eric Paris <eparis@redhat.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13728
Subject		: 2.6.31-rc2 soft lockups, RPC-related
Submitter	: Paul Collins <paul@burly.ondioline.org>
Date		: 2009-07-05 7:17 (22 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124677884816794&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13726
Subject		: fio sync read 4k block size 35% regression
Submitter	: Zhang, Yanmin <yanmin_zhang@linux.intel.com>
Date		: 2009-07-01 11:25 (26 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D51daa88ebd8e0d437289f589af29d4b39379ea76
References	: http://lkml.org/lkml/2009/6/30/679
Handled-By	: Wu Fengguang <fengguang.wu@intel.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13716
Subject		: The AIC-7892P controller does not work any more
Submitter	: Andrej Podzimek <andrej@podzimek.org>
Date		: 2009-07-05 19:23 (22 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13713
Subject		: [drm/i915] Possible regression due to commit "Change GEM thr=
ottling to be 20ms (...)"
Submitter	:  <kazikcz@gmail.com>
Date		: 2009-07-05 10:49 (22 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Db962442e46a9340bdbc6711982c59ff0cc2b5afb


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13709
Subject		: b2c2-flexcop: no frontend driver found for this B2C2/FlexCop=
 adapter w/ kernel-2.6.31-rc2
Submitter	: boris64 <bugzilla.kernel.org@boris64.net>
Date		: 2009-07-05 01:36 (22 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13700
Subject		: usb error flood in dmesg, makes kde use plenty of cpu - bise=
cted
Submitter	: jouni susiluoto <jouni.susiluoto@helsinki.fi>
Date		: 2009-07-03 21:13 (24 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13667
Subject		: drm: display arifacts when X.Org is stopped
Submitter	: Frans Pop <elendil@planet.nl>
Date		: 2009-06-27 18:52 (30 days old)
References	: http://lkml.org/lkml/2009/6/27/105
		  http://lkml.org/lkml/2009/7/8/30


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13666
Subject		: WARNING: at mm/page_alloc.c:1743 __alloc_pages_nodemask
Submitter	: Thomas Meyer <thomas@m3y3r.de>
Date		: 2009-06-27 16:15 (30 days old)
References	: http://lkml.org/lkml/2009/6/27/75
		  http://lkml.org/lkml/2009/7/7/6


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13657
Subject		: Linux-2.6.31-rc1 Fails To Recognize Some USB Disks
Submitter	: Tarkan Erimer <tarkan.erimer@turknet.net.tr>
Date		: 2009-06-26 10:03 (31 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D3821d768912a47ddbd6cab52943a8284df88003c
References	: http://lkml.org/lkml/2009/6/26/34
Handled-By	: Martin K. Petersen <martin.petersen@oracle.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13656
Subject		: 2.6.31-rc1 crashes randomly on my Machine.
Submitter	: Zeno Davatz <zdavatz@gmail.com>
Date		: 2009-06-26 08:56 (31 days old)
References	: http://lkml.org/lkml/2009/6/26/27


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13645
Subject		: NULL pointer dereference at (null) (level2_spare_pgt)
Submitter	: poornima nayak <mpnayak@linux.vnet.ibm.com>
Date		: 2009-06-17 17:56 (40 days old)
References	: http://lkml.org/lkml/2009/6/17/194


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13840
Subject		: KMS oops on 945G system
Submitter	: Diego Calleja <diegocg@gmail.com>
Date		: 2009-07-21 20:50 (6 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D7662c8bd6545c12ac7b2b39e4554c3ba34789c50
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124820945815030&w=3D=
4
Handled-By	: Jesse Barnes <jbarnes@virtuousgeek.org>
Patch		: http://git.kernel.org/?p=3Dlinux/kernel/git/anholt/drm-intel.g=
it;a=3Dcommit;h=3Ddff33cfcefa31c30b72c57f44586754ea9e8f3e2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13834
Subject		: device mapper fails on some logical volumes
Submitter	: Christian Borntr=C3=A4ger <borntraeger@de.ibm.com>
Date		: 2009-07-15 18:52 (12 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D754c5fc7ebb417b23601a6222a6005cc2e7f2913
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124767677206470&w=3D=
4
Handled-By	: Mike Snitzer <snitzer@redhat.com>
Patch		: http://patchwork.kernel.org/patch/33534/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13827
Subject		: PM/hibernate swapfile regression
Submitter	: Heiko Carstens <heiko.carstens@de.ibm.com>
Date		: 2009-07-14 15:54 (13 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124757972118196&w=3D=
4
Handled-By	: Alan Jenkins <alan-jenkins@tuffmail.co.uk>
Patch		: http://patchwork.kernel.org/patch/36510/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13825
Subject		: eeepc-laptop: fix hot-unplug on resume
Submitter	: Alan Jenkins <alan-jenkins@tuffmail.co.uk>
Date		: 2009-06-29 13:12 (28 days old)
References	: http://lkml.org/lkml/2009/6/29/150
Handled-By	: Alan Jenkins <alan-jenkins@tuffmail.co.uk>
Patch		: http://patchwork.kernel.org/patch/32926/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13742
Subject		: iwlagn (4965): regression when hardware rf switch is used
Submitter	: Frans Pop <elendil@planet.nl>
Date		: 2009-06-29 11:28 (28 days old)
References	: http://lkml.org/lkml/2009/6/29/88
Handled-By	: Reinette Chatre <reinette.chatre@intel.com>
Patch		: http://lkml.org/lkml/2009/6/30/224


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13665
Subject		: commit 69c854817566 causes OOMs
Submitter	: David Howells <dhowells@redhat.com>
Date		: 2009-06-27 08:12 (30 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D69c854817566db82c362797b4a6521d0b00fe1d8
References	: http://lkml.org/lkml/2009/6/27/28
Handled-By	: Wu Fengguang <fengguang.wu@intel.com>
Patch		: http://patchwork.kernel.org/patch/32740/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13659
Subject		: iwlagn (4965): no wireless due to RFKILL problem
Submitter	: Frans Pop <elendil@planet.nl>
Date		: 2009-06-26 13:36 (31 days old)
References	: http://lkml.org/lkml/2009/6/26/127
Handled-By	: Johannes Berg <johannes@sipsolutions.net>
Patch		: http://lkml.org/lkml/2009/6/27/35


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13643
Subject		: Touchpad lost synchronization after resume from suspend to R=
AM
Submitter	: Cijoml Cijomlovic Cijomlov <cijoml@volny.cz>
Date		: 2009-06-28 10:42 (29 days old)
References	: http://lkml.org/lkml/2009/6/23/365
		  2.6.30-rc1: touchpad disabled
		  http://lkml.org/lkml/2009/6/25/256
Handled-By	: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
Patch		: http://patchwork.kernel.org/patch/34075/


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions from 2=
=2E6.30,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D13615

Please let me know if there are any Bugzilla entries that should be add=
ed to
the list in there.

Thanks,
Rafael

--
To unsubscribe from this list: send the line "unsubscribe linux-acpi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
