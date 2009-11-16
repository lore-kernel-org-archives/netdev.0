From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.32-rc7-git1: Reported regressions from 2.6.31
Date: Mon, 16 Nov 2009 23:33:23 +0100 (CET)
Message-ID: <GUZt44bIwCE.A.vLF.pSdALB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Natalie Protasevich <protasnb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This message contains a list of some regressions from 2.6.31, for which=
 there
are no fixes in the mainline I know of.  If any of them have been fixed=
 already,
please let me know.

If you know of any other unresolved regressions from 2.6.31, please let=
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
  2009-11-16       84       46          41
  2009-10-26       66       42          37
  2009-10-12       48       31          27
  2009-10-02       22       15           9


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14629
Subject		: Oops on i915 on 8086:a011 pine trail
Submitter	: Luis R. Rodriguez <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-11-10 23:27 (7 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125789570519147&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14628
Subject		: drm/ksm -> s2disk -> resume -> [drm:r100_ring_test] *ERROR* =
radeon: ring test failed
Submitter	: Christian Hartmann <cornogle-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Date		: 2009-11-06 15:46 (11 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125752241331067&w=3D=
4
Handled-By	: Jerome Glisse <glisse-CC+yJ3UmIYqDUpFQwHEjaQ@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14627
Subject		: i915: *ERROR* Execbuf while wedged
Submitter	: Michael <schnitzelkuchen-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Date		: 2009-11-15 10:48 (2 days old)
References	: http://lkml.org/lkml/2009/11/15/40


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14626
Subject		: oops on boot starting udev
Submitter	: Soeren Sonnenburg <sonne-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org>
Date		: 2009-11-14 10:16 (3 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125819380206800&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14625
Subject		: Commit d451564 breaks ARM
Submitter	: Russell King <rmk+lkml-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Date		: 2009-11-13 15:11 (4 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dd4515646699b6ad7b1a98ceb871296b957f3ef47
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125812520315835&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14624
Subject		: ath9k: BUG kmalloc-8192: Poison overwritten
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-11-12 4:58 (5 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125800196520396&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14622
Subject		: Second IDE device not found
Submitter	: Zeno Davatz <zdavatz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-11-11 17:31 (6 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125796105822353&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14621
Subject		: specjbb2005 and aim7 regression with 2.6.32-rc kernels
Submitter	: Zhang, Yanmin <yanmin_zhang-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Date		: 2009-11-06 7:38 (11 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125749310413174&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14620
Subject		: WARNING: at mm/page_alloc.c:1805 __alloc_pages_nodemask
Submitter	: Rog=C3=A9rio Brito <rbrito-qczF+2RCDl1fyO9Q7EP/yw@public.gmane.org>
Date		: 2009-11-06 23:10 (11 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125754907413892&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14619
Subject		: ext3/jbd oops in journal_start
Submitter	: Sage Weil <sage-BnTBU8nroG7k1uMJSBkQmQ@public.gmane.org>
Date		: 2009-10-31 6:14 (17 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125696970418300&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14618
Subject		: OOM killer, page fault
Submitter	: Norbert Preining <preining-DX+603jRYB8@public.gmane.org>
Date		: 2009-10-30 6:32 (18 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125688434909582&w=3D=
4
Handled-By	: Minchan Kim <minchan.kim-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14616
Subject		: [2.6.32 regression] sata_nv: commit 6489e3262e6b188a1a009b65=
e8a94b7aa17645b7 slows down system boot
Submitter	: Artem S. Tashkinov <t.artem-VInPYn6yXxRWk0Htik3J/w@public.gmane.org>
Date		: 2009-11-16 19:49 (1 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14577
Subject		: Data Corruption with Adaptec 52445, Firmware 5.2-0 (17380)
Submitter	:  <lkolbe-If1cxaH3S3JVgF+RW+Bo1SZEdBbF94EN@public.gmane.org>
Date		: 2009-11-10 13:31 (7 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14538
Subject		: Unable to associate with AP after resume since 2.6.32-rc6
Submitter	: Christian Casteyde <casteyde.christian-GANU6spQydw@public.gmane.org>
Date		: 2009-11-03 22:07 (14 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14504
Subject		: intermittent hibernation problem again
Submitter	: Ferenc W=C3=A1gner <wferi-eEbw3PyuezQ@public.gmane.org>
Date		: 2009-10-28 23:49 (20 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14487
Subject		: PANIC: early exception 08 rip 246:10 error ffffffff810251b5 =
cr2 0
Submitter	: Justin P. Mattock <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-23 16:45 (25 days old)
References	: http://lkml.org/lkml/2009/10/23/252


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14485
Subject		: System lockup running "cat /sys/kernel/debug/dri/0/i915_regs=
"
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-26 4:00 (22 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125652968117713&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14483
Subject		: Interrupts enabled after irqrouter_resume - iMac9,1
Submitter	: Justin Mattock <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-25 19:58 (23 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125650070420168&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14482
Subject		: kernel BUG at fs/dcache.c:670 +lvm +md +ext3
Submitter	: Alexander Clouter <alex-L4GPcECwBoDe9xe1eoZjHA@public.gmane.org>
Date		: 2009-10-23 10:30 (25 days old)
References	: http://lkml.org/lkml/2009/10/23/50


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14481
Subject		: umount blocked for more than 120 seconds after USB drive rem=
oval
Submitter	: Robert Hancock <hancockrwd-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-21 5:26 (27 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125610280532245&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14472
Subject		: EXT4 corruption
Submitter	: Shawn Starr <shawn.starr-bJEeYj9oJeDQT0dZR+AlfA@public.gmane.org>
Date		: 2009-10-13 2:07 (35 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125539997508256&w=3D=
4
Handled-By	: Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14467
Subject		: Linker errors on ia64 with NR_CPUS=3D4096
Submitter	: Jeff Mahoney <jeffm-IBi9RG/b67k@public.gmane.org>
Date		: 2009-10-18 22:28 (30 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D34d76c41554a05425613d16efebb3069c4c545f0
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125590493116720&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14442
Subject		: resume after hibernate: /dev/sdb drops and returns as /dev/s=
de
Submitter	: Duncan <1i5t5.duncan-j9pdmedNgrk@public.gmane.org>
Date		: 2009-10-20 01:52 (28 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14436
Subject		: Computer becomes unusable without any apparent reason
Submitter	: Pitxyoki <Pitxyoki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-18 18:32 (30 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14430
Subject		: sync() hangs in bdi_sched_wait
Submitter	: Petr Vandrovec <petr-vPk2MGR0e28uaRcfnNAh7A@public.gmane.org>
Date		: 2009-10-17 19:14 (31 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14426
Subject		: CE: hpet increasing min_delta_ns flood
Submitter	: Thibault Mondary <thibm-GANU6spQydw@public.gmane.org>
Date		: 2009-10-17 09:29 (31 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14415
Subject		: Reboot on kernel load
Submitter	: Brian Beardall <brian-sVkzCUl/XCrR7s880joybQ@public.gmane.org>
Date		: 2009-10-15 23:57 (33 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14406
Subject		: uvcvideo stopped work on Toshiba
Submitter	: okias <d.okias-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-14 19:08 (34 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14384
Subject		: tbench regression with 2.6.32-rc1
Submitter	: Zhang, Yanmin <yanmin_zhang-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Date		: 2009-10-09 9:51 (39 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D59abf02644c45f1591e1374ee7bb45dc757fcb88
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125508216713138&w=3D=
4
Handled-By	: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14383
Subject		: hackbench regression with kernel 2.6.32-rc1
Submitter	: Zhang, Yanmin <yanmin_zhang-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Date		: 2009-10-09 9:19 (39 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D29cd8bae396583a2ee9a3340db8c5102acf9f6fd
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125508007510274&w=3D=
4
Handled-By	: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14376
Subject		: Kernel NULL pointer dereference/ kvm subsystem
Submitter	: Don Dupuis <dondster-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-06 14:38 (42 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125484025021737&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14373
Subject		: Task blocked for more than 120 seconds
Submitter	: Zeno Davatz <zdavatz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-02 10:16 (46 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125447858618412&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14372
Subject		: ath5k wireless not working after suspend-resume - eeepc
Submitter	: Fabio Comolli <fabio.comolli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-03 15:36 (45 days old)
References	: http://lkml.org/lkml/2009/10/3/91


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14355
Subject		: USB serial regression after 2.6.31.1 with Huawei E169 GSM mo=
dem
Submitter	: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Date		: 2009-10-10 03:07 (38 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125513456327542&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14354
Subject		: Bad corruption with 2.6.32-rc1 and upwards
Submitter	: Holger Freyther <zecke-MQnelBtSfJRAfugRpC6u6w@public.gmane.org>
Date		: 2009-10-09 15:42 (39 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14352
Subject		: WARNING: at net/mac80211/scan.c:267
Submitter	: Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-08 00:30 (40 days old)
References	: http://bugzilla.intellinuxwireless.org/show_bug.cgi?id=3D2=
089#c7


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14331
Subject		: Radeon XPRESS 200M: System hang with radeon DRI and Fedora 1=
0 userspace unless DRI=3Doff
Submitter	: Alex Villacis Lasso <avillaci-x0m+Mc+nT7uljOmnV8AmnkElSqmLX1BE@public.gmane.org>
Date		: 2009-10-06 00:29 (42 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14298
Subject		: warning at manage.c:361 (set_irq_wake), matrix-keypad relate=
d?
Submitter	: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Date		: 2009-09-30 20:07 (48 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125434130703538&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14297
Subject		: console resume broken since ba15ab0e8d
Submitter	: Sascha Hauer <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Date		: 2009-09-30 15:11 (48 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125432349404060&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14296
Subject		: spitz boots but suspend/resume is broken
Submitter	: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Date		: 2009-09-30 12:06 (48 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125431244516449&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14277
Subject		: Caught 8-bit read from freed memory in b43 driver at associa=
tion
Submitter	: Christian Casteyde <casteyde.christian-GANU6spQydw@public.gmane.org>
Date		: 2009-09-30 18:06 (48 days old)


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14630
Subject		: sched_rt_periodic_timer vs cpu hotplug
Submitter	: Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Date		: 2009-11-11 10:18 (6 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125793470309588&w=3D=
4
Handled-By	: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/60250/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14597
Subject		: thinkpad-acpi: driver fails to load on old BIOS for the A31,=
 T23-T30, X30-X31
Submitter	: Henrique de Moraes Holschuh <hmh-N3TV7GIv+o9fyO9Q7EP/yw@public.gmane.org>
Date		: 2009-11-13 20:45 (4 days old)
Handled-By	: Henrique de Moraes Holschuh <hmh-N3TV7GIv+o9fyO9Q7EP/yw@public.gmane.org>
Patch		: http://bugzilla.kernel.org/attachment.cgi?id=3D23770


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14480
Subject		: 2 locks held by cat -- running "find /sys | head -c 4" --> s=
ystem hang
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-20 16:11 (28 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125605511728088&w=3D=
4
Handled-By	: Chris Wilson <chris-Y6uKTt2uX1cEflXRtASbqLVCufUGDwFn@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/54974/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14380
Subject		: Video tearing/glitching with T400 laptops
Submitter	: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>
Date		: 2009-10-02 22:40 (46 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125452324520623&w=3D=
4
Handled-By	: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D125591495325000&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14379
Subject		: ACPI Warning for _SB_.BAT0._BIF: Converted Buffer to expecte=
d String
Submitter	: Justin Mattock <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-08 21:46 (40 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dd9adc2e031bd22d5d9607a53a8d3b30e0b675f39
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125504031328941&w=3D=
4
Handled-By	: Alexey Starikovskiy <astarikovskiy-l3A5Bk7waGM@public.gmane.org>
Patch		: http://bugzilla.kernel.org/attachment.cgi?id=3D23347


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions from 2=
=2E6.31,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D14230

Please let me know if there are any Bugzilla entries that should be add=
ed to
the list in there.

Thanks,
Rafael
