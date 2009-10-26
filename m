From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.32-rc5-git3: Reported regressions from 2.6.31
Date: Mon, 26 Oct 2009 19:45:48 +0100 (CET)
Message-ID: <Sj-rRjx6TwF.A.djE.vqe5KB@chimera>
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
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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
  2009-10-26       66       42          37
  2009-10-12       48       31          27
  2009-10-02       22       15           9


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14485
Subject		: System lockup running "cat /sys/kernel/debug/dri/0/i915_regs=
"
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-26 4:00 (1 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125652968117713&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14484
Subject		: no video output after suspend
Submitter	: Riccardo Magliocchetti <riccardo.magliocchetti-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-25 20:57 (2 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125650430123713&w=3D=
4
Handled-By	: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14483
Subject		: WARNING: at drivers/base/sys.c:353 __sysdev_resume+0x54/0xca=
()
Submitter	: Justin Mattock <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-25 19:58 (2 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125650070420168&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14482
Subject		: kernel BUG at fs/dcache.c:670 +lvm +md +ext3
Submitter	: Alexander Clouter <alex-L4GPcECwBoDe9xe1eoZjHA@public.gmane.org>
Date		: 2009-10-23 10:30 (4 days old)
References	: http://lkml.org/lkml/2009/10/23/50


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14481
Subject		: umount blocked for more than 120 seconds after USB drive rem=
oval
Submitter	: Robert Hancock <hancockrwd-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-21 5:26 (6 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125610280532245&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14479
Subject		: nfs oops
Submitter	: Egon Alter <egon.alter-hi6Y0CQ0nG0@public.gmane.org>
Date		: 2009-10-19 16:03 (8 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125596822630410&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14477
Subject		: possible circular locking dependency in ISDN PPP
Submitter	: Tilman Schmidt <tilman-ZTO5kqT2PaM@public.gmane.org>
Date		: 2009-10-18 22:16 (9 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125590423416087&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14473
Subject		: ATA related kernel warning after resume
Submitter	: Tino Keitel <tino.keitel-rAwCM5oiXHA@public.gmane.org>
Date		: 2009-10-14 6:55 (13 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125550466624678&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14472
Subject		: EXT4 corruption
Submitter	: Shawn Starr <shawn.starr-bJEeYj9oJeDQT0dZR+AlfA@public.gmane.org>
Date		: 2009-10-13 2:07 (14 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125539997508256&w=3D=
4
Handled-By	: Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14467
Subject		: Linker errors on ia64 with NR_CPUS=3D4096
Submitter	: Jeff Mahoney <jeffm-IBi9RG/b67k@public.gmane.org>
Date		: 2009-10-18 22:28 (9 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D34d76c41554a05425613d16efebb3069c4c545f0
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125590493116720&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14466
Subject		: EFI boot on x86 fails in .32
Submitter	: Matthew Garrett <mjg59-1xO5oi07KQx4cg9Nei1l7Q@public.gmane.org>
Date		: 2009-10-20 0:34 (7 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D7bd867dfb4e0357e06a3211ab2bd0e714110def3
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125599887314290&w=3D=
4
Handled-By	: Feng Tang <feng.tang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14442
Subject		: resume after hibernate: /dev/sdb drops and returns as /dev/s=
de
Submitter	: Duncan <1i5t5.duncan-j9pdmedNgrk@public.gmane.org>
Date		: 2009-10-20 01:52 (7 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14430
Subject		: sync() hangs in bdi_sched_wait
Submitter	: Petr Vandrovec <petr-vPk2MGR0e28uaRcfnNAh7A@public.gmane.org>
Date		: 2009-10-17 19:14 (10 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14415
Subject		: Reboot on kernel load
Submitter	: Brian Beardall <brian-sVkzCUl/XCrR7s880joybQ@public.gmane.org>
Date		: 2009-10-15 23:57 (12 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14408
Subject		: sysctl check failed
Submitter	: Peter Teoh <htmldeveloper-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-14 22:59 (13 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14406
Subject		: uvcvideo stopped work on Toshiba
Submitter	: okias <d.okias-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-14 19:08 (13 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14390
Subject		: "bind" a device to a driver doesn't not work anymore
Submitter	: =C3=89ric Piel <Eric.Piel-VkQ1JFuSMpfAbQlEx87xDw@public.gmane.org>
Date		: 2009-10-11 0:04 (16 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125521979921241&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14389
Subject		: Build system issue
Submitter	: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Date		: 2009-10-09 8:58 (18 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dhttp://git.kernel.org/?p=3Dlinux/kernel/=
git/torvalds/linux-2.6.git;a=3Dcommit;h=3D575543347b5baed0ca927cb90ba88=
07396fe9cc9
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125507914909152&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14387
Subject		: deadlock with fallocate
Submitter	: Thomas Neumann <tneumann-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Date		: 2009-10-07 3:00 (20 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125488495526471&w=3D=
4
Handled-By	: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14384
Subject		: tbench regression with 2.6.32-rc1
Submitter	: Zhang, Yanmin <yanmin_zhang-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Date		: 2009-10-09 9:51 (18 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D59abf02644c45f1591e1374ee7bb45dc757fcb88
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125508216713138&w=3D=
4
Handled-By	: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14383
Subject		: hackbench regression with kernel 2.6.32-rc1
Submitter	: Zhang, Yanmin <yanmin_zhang-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Date		: 2009-10-09 9:19 (18 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D29cd8bae396583a2ee9a3340db8c5102acf9f6fd
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125508007510274&w=3D=
4
Handled-By	: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14381
Subject		: iwlagn lost connection after s2ram (with warnings)
Submitter	: Carlos R. Mafra <crmafra2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-07 14:20 (20 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125492569119947&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14378
Subject		: Problems with net/core/skbuff.c
Submitter	: Massimo Cetra <mcetra-BBpJ+9iBSNKonA0d6jMUrA@public.gmane.org>
Date		: 2009-10-08 14:51 (19 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125501488220358&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14376
Subject		: Kernel NULL pointer dereference/ kvm subsystem
Submitter	: Don Dupuis <dondster-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-06 14:38 (21 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125484025021737&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14373
Subject		: Task blocked for more than 120 seconds
Submitter	: Zeno Davatz <zdavatz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-02 10:16 (25 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125447858618412&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14372
Subject		: ath5k wireless not working after suspend-resume - eeepc
Submitter	: Fabio Comolli <fabio.comolli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-03 15:36 (24 days old)
References	: http://lkml.org/lkml/2009/10/3/91


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14355
Subject		: USB serial regression after 2.6.31.1 with Huawei E169 GSM mo=
dem
Submitter	: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Date		: 2009-10-10 03:07 (17 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125513456327542&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14354
Subject		: Bad corruption with 2.6.32-rc1 and upwards
Submitter	: Holger Freyther <zecke-MQnelBtSfJRAfugRpC6u6w@public.gmane.org>
Date		: 2009-10-09 15:42 (18 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14353
Subject		: BUG: sleeping function called from invalid context at kernel=
/mutex.c:280
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-05 3:39 (22 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125471432208671&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14352
Subject		: WARNING: at net/mac80211/scan.c:267
Submitter	: Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-08 00:30 (19 days old)
References	: http://bugzilla.intellinuxwireless.org/show_bug.cgi?id=3D2=
089#c7


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14334
Subject		: pcmcia suspend regression from 2.6.31.1 to 2.6.31.2 - Dell I=
nspiron 600m
Submitter	: Jose Marino <braket-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org>
Date		: 2009-10-06 15:44 (21 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14331
Subject		: Radeon XPRESS 200M: System hang with radeon DRI and Fedora 1=
0 userspace unless DRI=3Doff
Submitter	: Alex Villacis Lasso <avillaci-x0m+Mc+nT7uljOmnV8AmnkElSqmLX1BE@public.gmane.org>
Date		: 2009-10-06 00:29 (21 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14299
Subject		: oops in wireless, iwl3945 related?
Submitter	: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Date		: 2009-09-29 17:12 (28 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125424439725743&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14298
Subject		: warning at manage.c:361 (set_irq_wake), matrix-keypad relate=
d?
Submitter	: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Date		: 2009-09-30 20:07 (27 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125434130703538&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14297
Subject		: console resume broken since ba15ab0e8d
Submitter	: Sascha Hauer <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Date		: 2009-09-30 15:11 (27 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125432349404060&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14296
Subject		: spitz boots but suspend/resume is broken
Submitter	: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Date		: 2009-09-30 12:06 (27 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125431244516449&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14277
Subject		: Caught 8-bit read from freed memory in b43 driver at associa=
tion
Submitter	: Christian Casteyde <casteyde.christian-GANU6spQydw@public.gmane.org>
Date		: 2009-09-30 18:06 (27 days old)


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14480
Subject		: 2 locks held by cat -- running "find /sys | head -c 4" --> s=
ystem hang
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-20 16:11 (7 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125605511728088&w=3D=
4
Handled-By	: Chris Wilson <chris-Y6uKTt2uX1cEflXRtASbqLVCufUGDwFn@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/54974/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14380
Subject		: Video tearing/glitching with T400 laptops
Submitter	: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>
Date		: 2009-10-02 22:40 (25 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125452324520623&w=3D=
4
Handled-By	: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D125591495325000&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14379
Subject		: ACPI Warning for _SB_.BAT0._BIF: Converted Buffer to expecte=
d String
Submitter	: Justin Mattock <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-08 21:46 (19 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dd9adc2e031bd22d5d9607a53a8d3b30e0b675f39
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125504031328941&w=3D=
4
Handled-By	: Alexey Starikovskiy <astarikovskiy-l3A5Bk7waGM@public.gmane.org>
Patch		: http://bugzilla.kernel.org/attachment.cgi?id=3D23347


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14375
Subject		: Intel(R) I/OAT DMA Engine init failed
Submitter	: Alexander Beregalov <a.beregalov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-02 9:46 (25 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125447680016160&w=3D=
4
Handled-By	: Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/51808/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14302
Subject		: Kernel panic on i386 machine when booting with profile=3D2
Submitter	: Shi, Alex <alex.shi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-01 3:23 (26 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125436749607199&w=3D=
4
Handled-By	: Alex Shi <alex.shi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/50813/


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

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
