From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.37-rc8: Reported regressions from 2.6.36
Date: Wed, 29 Dec 2010 23:59:38 +0100 (CET)
Message-ID: <96DQe4a_2tH.A.cFB.l27GNB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Florian Mickler <florian-sVu6HhrpSfRAfugRpC6u6w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>
To: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This message contains a list of some regressions from 2.6.36,
for which there are no fixes in the mainline known to the tracking team=
=2E
If any of them have been fixed already, please let us know.

If you know of any other unresolved regressions from 2.6.36, please let=
 us
know either and we'll add them to the list.  Also, please let us know
if any of the entries below are invalid.

Each entry from the list will be sent additionally in an automatic repl=
y
to this message with CCs to the people involved in reporting and handli=
ng
the issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2010-12-30       85       32          26
  2010-12-19       73       28          24
  2010-12-03       55       25          19
  2010-11-19       39       29          25


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D25842
Subject		: thinkpad T410s intel i915 regression
Submitter	: Travis Hume <travis-02nwaM6XSaFQx4ORub6hmQ@public.gmane.org>
Date		: 2010-12-29 18:21 (1 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D25822
Subject		: [BUG] kernel BUG at mm/truncate.c:479! on 2.6.37-rc8
Submitter	: Gurudas Pai <gurudas.pai-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Date		: 2010-12-29 6:58 (1 days old)
Message-ID	: <4D1AD935.1020504-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129360511222037&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D25812
Subject		: 2.6.37-rc7: Regression: b43: crashes in hwrng_register()
Submitter	: Mario 'BitKoenig' Holbe <Mario.Holbe-hs6bpBdVsEZfm0AUMx9V0g@public.gmane.org>
Date		: 2010-12-28 13:32 (2 days old)
Message-ID	: <slrnihjpnh.7t4.Mario.Holbe-elxHLJlugahyoG5eyubGJTtNMCm3PftOHZ5vskTnxNA@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129354319002301&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D25602
Subject		: [regression] 2.6.37-rc5: scsi_eh_11 CPU loop
Submitter	: Martin Steigerwald <Martin-3kZCPVa5dk2azgQtNeiOUg@public.gmane.org>
Date		: 2010-12-20 10:05 (10 days old)
Message-ID	: <201012201105.08993.Martin-3kZCPVa5dk2azgQtNeiOUg@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129283954108331&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D25432
Subject		: Alpha fails to build with gcc 4.4
Submitter	: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Date		: 2010-12-22 01:55 (8 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D25402
Subject		: kernel (2.6.37-8-generic_amd64) panic on boot (with message =
"map_single: bounce buffer is not DMA'ble) - possible regression !!!
Submitter	: carlos <carlos.palma-sh/6fXdz2Rs@public.gmane.org>
Date		: 2010-12-21 19:58 (9 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D25392
Subject		: scsi_eh_11 CPU loop
Submitter	: Zhang, Yanmin <yanmin_zhang-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Date		: 2010-08-18 6:18 (134 days old)
Message-ID	: <1282112318.21202.8.camel-sz7BYL/Y5Hu/P+R7jlPCFVaTQe2KTcn/@public.gmane.org>
References	: http://marc.info/?t=3D129283967100004&r=3D1&w=3D2
		  http://lkml.org/lkml/2010/12/20/52


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D24882
Subject		: PM/Hibernate: Memory corruption patch introduces regression =
(2.6.36.2)
Submitter	:  <akwatts-DaQTI0RpDDMAvxtiuMwx3w@public.gmane.org>
Date		: 2010-12-14 04:00 (16 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D24822
Subject		: Embedded DisplayPort is detected wrongly on HP ProBook 5320m
Submitter	: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>
Date		: 2010-12-13 11:09 (17 days old)
Handled-By	: Chris Wilson <chris-Y6uKTt2uX1cEflXRtASbqLVCufUGDwFn@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D24772
Subject		: Crash with btrfs rootfs on dm-crypt [ kernel BUG at fs/btrfs=
/inode.c:806! ] on linux 2.6.37-rc5
Submitter	: Fabio Comolli <fabio.comolli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-12-10 20:30 (20 days old)
Message-ID	: <AANLkTi=3Dj9zsaYNcu=3DNgGV=3DHfE-3rNHzVswov8VrgwjQp@mail.=
gmail.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129201308706568&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D24762
Subject		: BUG at perf_ctx_adjust_freq (kernel/perf_event.c:1582)
Submitter	: Chris Wilson <chris-Y6uKTt2uX1cEflXRtASbqLVCufUGDwFn@public.gmane.org>
Date		: 2010-12-10 12:00 (20 days old)
Message-ID	: <c6d829$pqibha-vB7d4uKqMBxScZeZrdtW41DQ4js95KgL@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129198247531612&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D24592
Subject		: 2.6.37-rc5: NULL pointer oops in selinux_socket_unix_stream_=
connect
Submitter	: Jeremy Fitzhardinge <jeremy-TSDbQ3PG+2Y@public.gmane.org>
Date		: 2010-12-08 21:09 (22 days old)
Message-ID	: <4CFFF3F3.90100-TSDbQ3PG+2Y@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129184256629712&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D24582
Subject		: Kernel Oops at tty_buffer_request_room when using pppd progr=
am (2.6.37-rc4)
Submitter	: baoyb <baoyb-pUFDVul4/eDM1kAEIRd3EQ@public.gmane.org>
Date		: 2010-12-08 13:55 (22 days old)
Message-ID	: <EF6DDE218DB34702B1FA84D6CD7EA771@baoyb>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129181763525738&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D24372
Subject		: kdump broken on 2.6.37-rc4
Submitter	: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date		: 2010-12-03 11:16 (27 days old)
Message-ID	: <20101203111623.GA2741-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129137502323003&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D24362
Subject		: perf hw  in kexeced kernel broken in tip
Submitter	: Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date		: 2010-12-01 8:00 (29 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/33c6d6a7ad0ffab9b1b15f8=
e4107a2af072a05a0
Message-ID	: <4CF60095.1020900-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129119055922065&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D24272
Subject		: iotop reports insane per-process disk read/write statistics
Submitter	: Brian Rogers <brian-+B9G8rMUbpQ@public.gmane.org>
Date		: 2010-12-03 12:00 (27 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/85893120699f8bae8caa12a=
8ee18ab5fceac978e


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D23902
Subject		: [BUG] 2.6.37-rc3 massive interactivity regression on ARM
Submitter	: Mikael Pettersson <mikpe-1zs4UD6AkMk@public.gmane.org>
Date		: 2010-11-27 15:16 (33 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/305e6835e05513406fa1282=
0e40e4a8ecb63743c
Message-ID	: <<19697.8378.717761.236202-tgku4HJDRZih8lFjZTKsyTAV6s6igYVG@public.gmane.org>>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129087098911837&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D23472
Subject		: 2.6.37-rc2 vs. 2.6.36 laptop backlight changes?
Submitter	: Patrick Schaaf <netdev-g5tzxDtodVw@public.gmane.org>
Date		: 2010-11-17 13:41 (43 days old)
Message-ID	: <1290001262.5727.2.camel@lat1>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129000127920912&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D23102
Subject		: [bisected] i915 regression in post 2.6.36 kernels
Submitter	: Johannes Hirte <johannes.hirte-3kN+8DYepx7zMJDuovMtMLNAH6kLmebB@public.gmane.org>
Date		: 2010-11-10 7:02 (50 days old)
Message-ID	: <201011100802.20332.johannes.hirte-3kN+8DYepx7zMJDuovMtMLNAH6kLmebB@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128937310017057&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D22942
Subject		: [2.6.37-rc1, OOM] virtblk: OOM in do_virtblk_request()
Submitter	: Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>
Date		: 2010-11-05 1:30 (55 days old)
Message-ID	: <20101105013003.GE13830@dastard>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128892062917641&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D22912
Subject		: spi_lm70llp module crash on unload (2.6.37-rc1)
Submitter	: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Date		: 2010-11-05 0:16 (55 days old)
Message-ID	: <20101104171620.00d8c95d.randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128891627913647&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D22882
Subject		: (2.6.37-rc1) amd64-agp module crashed on second load
Submitter	: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Date		: 2010-11-05 0:13 (55 days old)
Message-ID	: <20101104171333.fea1f498.randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128891605213447&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D22642
Subject		: 2.6.37-rc1: Disk takes 10 seconds to resume - MacBook2,1
Submitter	: Tobias <devnull-fBT1nhYaLZ4@public.gmane.org>
Date		: 2010-11-10 19:33 (50 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D22562
Subject		: Regression in 2.6.37-rc1 - logs spammed with "unable to enum=
erate USB port" - bisected to commit 3df7169e
Submitter	: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Date		: 2010-11-02 22:32 (58 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/3df7169e73fc1d71a39cffe=
acc969f6840cdf52b
Message-ID	: <4CD09166.4060202-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128873713207906&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D22542
Subject		: [2.6.37-rc1] drm:i195 errors
Submitter	: Paul Rolland <rol-fjEKYshTNZ1eoWH0uzbU5w@public.gmane.org>
Date		: 2010-11-02 14:58 (58 days old)
Message-ID	: <20101102155813.09cb2c6e-Hu5lHNoInTV+MQpiyFM1nV6hYfS7NtTn@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128870991628970&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D22472
Subject		: vga_switcheroo fails to switch from intel to ati
Submitter	: Radu Andries <admiral0-BoOA+NLF7L6xbKUeIHjxjQ@public.gmane.org>
Date		: 2010-11-08 16:46 (52 days old)


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D25442
Subject		: ixp4xx defines FREQ macro; conflicts with gspca/ov519 driver
Submitter	: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Date		: 2010-12-22 02:02 (8 days old)
Handled-By	: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=3D41252


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D25422
Subject		: nouveau fails to build on ia64
Submitter	: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Date		: 2010-12-22 01:49 (8 days old)
Handled-By	: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=3D41242


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D25012
Subject		: BUG: i915 causes NULL pointer dereference in 2.6.37-rc5-git4
Submitter	: T=C3=B5nu Raitviir <jussuf-Y27EyoLml9s@public.gmane.org>
Date		: 2010-12-15 12:48 (15 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/da79de97d254145dcb7c08c=
978b1093eac15ec9c
Message-ID	: <alpine.DEB.2.00.1012151238570.4797-rbynxJDbKr47Jk59zykfHYGUQIXJGoOI@public.gmane.org>
References	: http://www.spinics.net/lists/dri-devel/msg06282.html
Handled-By	: Chris Wilson <chris-Y6uKTt2uX1cEflXRtASbqLVCufUGDwFn@public.gmane.org>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=3D41502


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D22812
Subject		: kernel oops on 2.6.37-rc1
Submitter	: Andrew <atswartz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-11-12 16:05 (48 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/a68c439b1966c91f0ef474e=
2bf275d6792312726
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=3D41192


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D22672
Subject		: Regression in 2.6.37-rc1 for Intel 945 Graphics Adapter - bi=
sected to commit e9e331a
Submitter	: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Date		: 2010-11-11 01:56 (49 days old)
References	: https://bugs.freedesktop.org/show_bug.cgi?id=3D31803
		  http://marc.info/?l=3Dlinux-kernel&m=3D128944001311444&w=3D2
		  http://www.mail-archive.com/intel-gfx-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org/msg0223=
5.html
Patch		: https://patchwork.kernel.org/patch/359472/
		  https://patchwork.kernel.org/patch/359502/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D22662
Subject		: divide error in select_task_rq_fair()
Submitter	: Myron Stowe <myron.stowe-VXdhtT5mjnY@public.gmane.org>
Date		: 2010-11-10 23:58 (50 days old)
Patch		: http://lkml.org/lkml/2010/11/13/176
		  http://lkml.org/lkml/2010/11/13/181


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions from 2=
=2E6.36,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D21782

Please let the tracking team know if there are any Bugzilla entries tha=
t
should be added to the list in there.

Thanks!
