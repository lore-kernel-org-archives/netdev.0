From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.30-rc6: Reported regressions 2.6.28 -> 2.6.29
Date: Sat, 16 May 2009 21:58:56 +0200 (CEST)
Message-ID: <yO1BmxN79sN.A.xAG.8_zDKB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
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

This message contains a list of some regressions introduced between 2.6.28 and
2.6.29, for which there are no fixes in the mainline I know of.  If any of them
have been fixed already, please let me know.

If you know of any other unresolved regressions introduced between 2.6.28
and 2.6.29, please let me know either and I'll add them to the list.
Also, please let me know if any of the entries below are invalid.

Each entry from the list will be sent additionally in an automatic reply to
this message with CCs to the people involved in reporting and handling the
issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2009-05-17      162       27          25
  2009-04-26      160       29          27
  2009-04-06      142       37          31
  2009-03-21      128       29          26
  2009-03-14      124       36          32
  2009-03-03      108       33          28
  2009-02-24       95       32          24
  2009-02-14       85       33          27
  2009-02-08       82       45          36
  2009-02-04       66       51          39
  2009-01-20       38       35          27
  2009-01-11       13       13          10



Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13271
Subject		: ath9k stop working since 2.6.29
Submitter	: lyman <lymanrb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-05-10 01:58 (7 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13269
Subject		: WARNING: at kernel/hrtimer.c:625 hres_timers_resume+0x3c/0x48() when resuming
Submitter	: cedric <cedric-x1Cn44Nr1HaZIoH1IeqzKA@public.gmane.org>
Date		: 2009-05-08 08:48 (9 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13232
Subject		: ext3/4 with synchronous writes gets wedged by Postfix
Submitter	: David Watson <kernel-nospam-yvBcC19sZ6P0OyVTGvYuXB2eb7JE58TQ@public.gmane.org>
Date		: 2009-05-03 19:46 (14 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13225
Subject		: [2.6.29 regression] Software suspend no longer works
Submitter	: Artem S. Tashkinov <t.artem-VInPYn6yXxRWk0Htik3J/w@public.gmane.org>
Date		: 2009-05-02 21:41 (15 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13183
Subject		: forcedeth: no link during initialization
Submitter	: Harald Dunkel <harald.dunkel-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org>
Date		: 2009-04-23 13:02 (24 days old)
References	: http://marc.info/?l=linux-kernel&m=124049180309233&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13178
Subject		: Booting very slow
Submitter	: Martin Knoblauch <spamtrap-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
Date		: 2009-04-24 12:45 (23 days old)
References	: http://marc.info/?l=linux-kernel&m=124057716231773&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13175
Subject		: sata_nv incompatible with async scsi scan
Submitter	: Benny Halevy <bhalevy-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org>
Date		: 2009-04-21 7:03 (26 days old)
References	: http://marc.info/?l=linux-kernel&m=124029746431777&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13172
Subject		: Spontaneous reboots since 2.6.29-rc*
Submitter	: Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-04-17 17:03 (30 days old)
References	: http://marc.info/?l=linux-kernel&m=123998788921733&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13144
Subject		: resume from suspend fails using video card i915
Submitter	: C Sights <csights-97jfqw80gc6171pxa8y+qA@public.gmane.org>
Date		: 2009-04-21 17:03 (26 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13100
Subject		: can't anymore even do a s2ram-s2disk-s2ram cycle on acer aspire 5720G
Submitter	: Maxim Levitsky <maximlevitsky-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-04-06 23:52 (41 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=a0d4922da2e4ccb0973095d8d29f36f6b1b5f703
References	: http://marc.info/?l=linux-kernel&m=123906202829074&w=4
Handled-By	: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13074
Subject		: gspca_stv06xx doesn't work with Logitech QuickCam Express (046d:0840)
Submitter	: Paulo Matias <matias-fd97jBR+K/6SGgWmA85PRw@public.gmane.org>
Date		: 2009-04-12 14:10 (35 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13072
Subject		: forcedeth seems to switch off eth on shutdown
Submitter	: Daniel Bierstedt <daniel.bierstedt-Mmb7MZpHnFY@public.gmane.org>
Date		: 2009-04-12 07:00 (35 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13025
Subject		: After upgrading to kernel 2.6.29, pulseaudio stopped with some strange error
Submitter	: Yaroslav Isakov <yaroslav.isakov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-04-06 19:47 (41 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13024
Subject		: nozomi: pppd fails on kernel 2.6.29
Submitter	: Mark Karpeles <mark-pwcEARUeV57PDbFq/vQRIQ@public.gmane.org>
Date		: 2009-04-06 19:12 (41 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13001
Subject		: PCI-DMA: Out of IOMMU space
Submitter	:  <optimusgd-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-04-03 09:30 (44 days old)
References	: http://lkml.org/lkml/2009/4/28/133


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12980
Subject		: lockup in X.org
Submitter	: Marcus Better <marcus-sJr3legBufCzQB+pC5nmwQ@public.gmane.org>
Date		: 2009-03-31 08:58 (47 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12971
Subject		: "tg3 transmit timed out" when transmitting at high bitrate
Submitter	: Nikolay <dobrev666-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-03-29 18:02 (49 days old)
Handled-By	: Matt Carlson <mcarlson-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12947
Subject		: r128: system hangs when X is started with DRI enabled
Submitter	: Jos van der Ende <seraph-qWit8jRvyhVmR6Xm/wNWPw@public.gmane.org>
Date		: 2009-03-26 16:14 (52 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12909
Subject		: boot/kernel init duration regression from 2.6.28
Submitter	: CaT <cat-LJ1TwQYPT6cQrrorzV6ljw@public.gmane.org>
Date		: 2009-03-16 10:25 (62 days old)
References	: http://marc.info/?l=linux-kernel&m=123720083515950&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12899
Subject		: Crash in i915.ko: i915_driver_irq_handler
Submitter	: Helge Bahmann <helge.bahmann-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org>
Date		: 2009-03-20 07:13 (58 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12861
Subject		: Xorg fails to start "Failed to allocate space for kernel memory manager"
Submitter	: Emil Karlson <jkarlson-kf+aQKke1yb1KXRcyAk9cg@public.gmane.org>
Date		: 2009-03-12 12:06 (66 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=ab657db12d7020629f26f30d287558a8d0e32b41


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12705
Subject		: X200: Brightness broken since 2.6.29-rc4-58-g4c098bc
Submitter	: Nico Schottelius <nico-linux-20090213-xuaVFQXs+5hIG4jRRZ66WA@public.gmane.org>
Date		: 2009-02-13 9:33 (93 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=e806b4957412bf472d826bd8cc571da041248799
References	: http://marc.info/?l=linux-kernel&m=123451768406825&w=4
		  http://marc.info/?l=linux-kernel&m=123479975503827&w=2
Handled-By	: Eric Anholt <eric-WhKQ6XTQaPysTnJN9+BGXg@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12681
Subject		: s2ram: fails to wake up on Acer Extensa 4220 (SMP disabled)
Submitter	: Orivej Desh <smpuj-5URONGGNgjI@public.gmane.org>
Date		: 2009-02-09 13:01 (97 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=1cfe62c8010ac56e1bd3827e30386a87cc2f3594
Handled-By	: Alexey Starikovskiy <astarikovskiy-l3A5Bk7waGM@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12499
Subject		: Problem with using bluetooth adaper connected to usb port
Submitter	: Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-01-13 18:34 (124 days old)
References	: http://marc.info/?l=linux-kernel&m=123187185426236&w=4
Handled-By	: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12490
Subject		: ath5k related kernel panic in 2.6.29-rc1
Submitter	: Sergey S. Kostyliov <rathamahata-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-01-12 7:38 (125 days old)
References	: http://marc.info/?l=linux-kernel&m=123174591509586&w=4
		  http://lkml.org/lkml/2009/4/6/527
Handled-By	: Bob Copeland <me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org>


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13186
Subject		: cpufreq timer teardown problem
Submitter	: Mathieu Desnoyers <mathieu.desnoyers-scC8bbJcJLCw5LPnMra/2Q@public.gmane.org>
Date		: 2009-04-23 14:00 (24 days old)
References	: http://marc.info/?l=linux-kernel&m=124049523515036&w=4
Handled-By	: Mathieu Desnoyers <mathieu.desnoyers-scC8bbJcJLCw5LPnMra/2Q@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/19754/
		  http://patchwork.kernel.org/patch/19753/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12765
Subject		: i915 VT switch with AIGLX causes X lock up
Submitter	: Sitsofe Wheeler <sitsofe-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
Date		: 2009-02-21 15:38 (85 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=14d200c5e5bd19219d930bbb9a5a22758c8f5bec
References	: http://marc.info/?l=linux-kernel&m=123523074304955&w=4
		  http://lkml.org/lkml/2009/4/27/317
Handled-By	: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/20197/


For details, please visit the bug entries and follow the links given in
references.

As you can see, there is a Bugzilla entry for each of the listed regressions.
There also is a Bugzilla entry used for tracking the regressions introduced
between 2.6.28 and 2.6.29, unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=12398

Please let me know if there are any Bugzilla entries that should be added to
the list in there.

Thanks,
Rafael

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
