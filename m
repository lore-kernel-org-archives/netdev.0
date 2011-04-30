From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.39-rc5-git4: Reported regressions 2.6.37 -> 2.6.38
Date: Sat, 30 Apr 2011 22:13:11 +0200 (CEST)
Message-ID: <QbBtx5c9v1J.A.JaF.PxGvNB@chimera>
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

This message contains a list of some post-2.6.37 regressions introduced=
 before
2.6.38, for which there are no fixes in the mainline known to the track=
ing team.
If any of them have been fixed already, please let us know.

If you know of any other unresolved post-2.6.37 regressions, please let=
 us know
either and we'll add them to the list.  Also, please let us know if any
of the entries below are invalid.

Each entry from the list will be sent additionally in an automatic repl=
y to
this message with CCs to the people involved in reporting and handling =
the
issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2011-04-30      105       29          28
  2011-04-17       98       28          28
  2011-03-27       88       26          26
  2011-03-06       70       27          26
  2011-02-21       51       18          17
  2011-02-12       39       20          18
  2011-02-03       19       11           7


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D34022
Subject		: Kernel OOPS turning on Radeon on vgaswitcheroo enabled syste=
m
Submitter	:  <blazej.bucko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-04-27 19:39 (4 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D33982
Subject		: ath9k: regulatory: strange tx power limits
Submitter	: Richard Sch=C3=BCtz <r.schtz-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org>
Date		: 2011-04-26 18:37 (5 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D33892
Subject		: Kernel sometimes fails to find major/minor number of root de=
vice
Submitter	: Aaron Barany <akb825-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-04-23 20:13 (8 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D33882
Subject		: rt2800pci bad performance in 2.6.38
Submitter	: Ricardo Gra=C3=A7a <r.jpg-8MI2nhFGehw@public.gmane.org>
Date		: 2011-04-23 14:35 (8 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D33852
Subject		: Regression of AR2413 802.11bg in 2.6.38.4
Submitter	: Boris Popov <popov.b-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-04-23 12:12 (8 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/42c025f3de9042d9c9abd9a=
6f6205d1a0f4bcadf


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D33662
Subject		: System hangs during X startup (kwin compositing?)
Submitter	: Luke-Jr <luke-jr+linuxbugs-LLS2WxOx/a1AfugRpC6u6w@public.gmane.org>
Date		: 2011-04-19 04:26 (12 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D32762
Subject		: Booting with external monitor attached results in red flicke=
ring screen on the external monitor
Submitter	: Anton <anton.bugs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-04-06 04:50 (25 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D32522
Subject		: drm:i915_hangcheck_ring_idle after suspend/resume cycle
Submitter	:  <fhimpe-CNXmb7IdZIWZIoH1IeqzKA@public.gmane.org>
Date		: 2011-04-02 18:40 (29 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D32202
Subject		: 2.6.38 hangs on boot until key is pressed
Submitter	: Tvrtko Ursulin <tvrtko-9sj9WOxYP5jR7s880joybQ@public.gmane.org>
Date		: 2011-03-27 19:18 (35 days old)
Message-ID	: <1301253485.2500.2.camel@deuteros>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D130125411116558&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D32112
Subject		: Writes to USB flash drives are extremely slow in 2.6.38
Submitter	: Delan Azabani <delan-Boohn7ZbvbpBDgjK7y7TUQ@public.gmane.org>
Date		: 2011-03-29 08:10 (33 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D32072
Subject		: 2.6.38 Regression: Nvidia GeForce8400 + i915 =3D Crash on Bo=
ot
Submitter	: simon-wM4F9T/ekXmXDw4h08c5KA@public.gmane.org
Date		: 2011-03-24 15:20 (38 days old)
Message-ID	: <fe471c05897776b7c26b9fd2603e3b76.squirrel-N82HvsEaY4kGLQ9C4TkFhg@public.gmane.org=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D130100955926434&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D31982
Subject		: XFS memory allocation deadlock in 2.6.38
Submitter	: Sean Noonan <Sean.Noonan-dxgubf92oBlWk0Htik3J/w@public.gmane.org>
Date		: 2011-03-21 16:19 (41 days old)
Message-ID	: <081DDE43F61F3D43929A181B477DCA95639B52FD-W84Bic8V7yZ3GC5t/3agGQ@public.gmane.org=
=2Ecom>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D130072585111310&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D31922
Subject		: ath5k: Decreased throughput in IBSS or 802.11n mode
Submitter	: Jeff Cook <jeff-Lrzp875GHuWS7RsuTa25K+qUGfbH9hYC@public.gmane.org>
Date		: 2011-03-26 20:06 (36 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D31782
Subject		: nouveau: lockdep spew
Submitter	: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date		: 2011-03-24 09:51 (38 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D31702
Subject		: ath5k phy2: failed to wakeup the MAC Chip
Submitter	: Justin P. Mattock <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-03-22 19:15 (40 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D31572
Subject		: BUG in vb_alloc() - firewire crash at boot
Submitter	: Pavel Kysilka <goldenfish-3RRv3fhkseTjAhjy0/KdDg@public.gmane.org>
Date		: 2011-03-21 12:40 (41 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D31532
Subject		: 2.6.38: Quota over NFS4
Submitter	: Adam Lackorzynski <adam-IG//nw+yl+iQIjdd1DhZXWfrygkm6VTR@public.gmane.org>
Date		: 2011-03-17 13:32 (45 days old)
Message-ID	: <20110317133247.GB6424-IG//nw+yl+iQIjdd1DhZXWfrygkm6VTR@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D130036878203485&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D31522
Subject		: i915/kms regression after 2.6.38-rc8 (was: Re: Linux 2.6.38)
Submitter	: Melchior FRANZ <melchior.franz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-03-16 17:30 (46 days old)
Message-ID	: <201103161830.52231-s3vZadu4I7qzZXS1Dc/lvw@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D130029706416659&w=3D=
2
		  http://marc.info/?l=3Dlinux-kernel&m=3D130409270332174&w=3D2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D31402
Subject		: Diminished brightness at startup
Submitter	: Guilherme Salazar <guilhermesalazar-DaQTI0RpDDMAvxtiuMwx3w@public.gmane.org>
Date		: 2011-03-18 16:29 (44 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D31322
Subject		: 2.6.38-rc echo 3 > /proc/sys/vm/drop_caches repairs mplayer =
distortions
Submitter	: Hans de Bruin <jmdebruin-agH9qYG3oEhmR6Xm/wNWPw@public.gmane.org>
Date		: 2011-03-14 21:34 (48 days old)
Message-ID	: <4D7E89E7.3080505-agH9qYG3oEhmR6Xm/wNWPw@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D130014181919827&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D31012
Subject		: WARNING: Perf: bad frame pointer =3D (null), 2.6.38-rc8
Submitter	: Chuck Ebbert <cebbert-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date		: 2011-03-12 19:08 (50 days old)
Message-ID	: <20110312140851.52420149@katamari>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129995721014931&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D30992
Subject		: 2.6.38-rc7: Some strange soft-lockup
Submitter	: Dmitry Nezhevenko <dion-Riw6fTKU00peoWH0uzbU5w@public.gmane.org>
Date		: 2011-03-06 14:01 (56 days old)
Message-ID	: <20110306140104.GA7700-Kfeq/R7O60eE+EvaaNYduQ@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129942161205739&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D30582
Subject		: WARNING: at drivers/net/wireless/ath/ath9k/recv.c:536 ath_st=
oprecv+0xc8/0xda [ath9k]()
Submitter	: Justin Mattock <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-03-03 5:47 (59 days old)
Message-ID	: <AANLkTik9To0Rkq2FRqQFB2wNu0kyJ7CzyBek2jBp36Cb-JsoAwUIsXotQFR93xxRIaA@public.gmane.org=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129913127722786&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D29992
Subject		: boot hang 2.6.37.1 regression w/ intel_idle and CONFIG_NO_HZ=
=3Dn - asus p7p55d le
Submitter	: De Ganseman Amaury <amaury.deganseman-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-02-27 10:38 (63 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D29672
Subject		: [regression][ALSA][hda-conexant][2.6.38-rcX] external microp=
hone sound too quiet
Submitter	: Shawn Starr <shawn.starr-bJEeYj9oJeDQT0dZR+AlfA@public.gmane.org>
Date		: 2011-02-19 6:02 (71 days old)
Message-ID	: <474630.25335.qm-LGyaPT5kzbjzJNTqFNLFoaJ1FwRQo79cG6kzb5Gsg2M@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129809536502092&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D28522
Subject		: Unable to mount FAT-formatted floppy on /dev/fd0, plus WARN_=
ON when using /dev/fd0u1440
Submitter	: Alex Villacis Lasso <avillaci-x0m+Mc+nT7uljOmnV8AmnkElSqmLX1BE@public.gmane.org>
Date		: 2011-02-07 17:21 (83 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D28452
Subject		: 2.6.38-rc3 regression on parisc: segfaults
Submitter	: Meelis Roos <mroos-Y27EyoLml9s@public.gmane.org>
Date		: 2011-02-01 22:00 (89 days old)
Message-ID	: <alpine.SOC.1.00.1102012342200.25944-ptEonEWSGqKptlylMvRsHA@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129659763426600&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D28422
Subject		: kref and apparmor panic in 2.6.38-rc2.
Submitter	: Tao Ma <tm-d1IQDZat3X0@public.gmane.org>
Date		: 2011-01-31 10:06 (90 days old)
Message-ID	: <4D46899B.80302-d1IQDZat3X0@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129646840303149&w=3D=
2


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D32862
Subject		: acer_wmi partially crashes ACPI/EC (Aspire 8930G)
Submitter	: Hector Martin <hector-eIot3r3D0w+Wd6l5hS35sQ@public.gmane.org>
Date		: 2011-04-07 17:44 (24 days old)
Handled-By	: Lee, Chun-Yi <jlee-Et1tbQHTxzrQT0dZR+AlfA@public.gmane.org>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=3D54492


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions introd=
uced
between 2.6.37 and 2.6.38, unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D27352

Please let the tracking team know if there are any Bugzilla entries tha=
t
should be added to the list in there.

Thanks!
