From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 3.1-rc1-git9: Reported regressions 2.6.39 -> 3.0
Date: Sun, 14 Aug 2011 21:02:27 +0200 (CEST)
Message-ID: <xuTC4jRtHbB.A.l4H.gMCSOB@chimera>
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

[NOTE:
 We already have a bug entry for tracking regressions from 3.0:

 http://bugzilla.kernel.org/show_bug.cgi?id=3D40982

 but there are no reports linked to it, mostly because Maciej is on vac=
ation,
 but also because the frequency of reporting regressions has been low
 recently.  So, if you're seeing a regression from 3.0, please let us k=
now.]

This message contains a list of some post-2.6.39 regressions introduced=
 before
3.0, for which there are no fixes in the mainline known to the tracking=
 team.
If any of them have been fixed already, please let us know.

If you know of any other unresolved post-2.6.39 regressions, please let=
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
  2011-08-14       63       22          19


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D40282
Subject		: IP forwarding regression since 3.0-rc6
Submitter	: Stephan Seitz <stse+lkml-S0d6l+6kcjrOGKtSYHEJQ9HuzzzSOjJt@public.gmane.org>
Date		: 2011-07-25 12:51 (21 days old)
Message-ID	: <20110725T141145.GA.2ae38.stse-S0d6l+6kcjrOGKtSYHEJQ9HuzzzSOjJt@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D131159880004908&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D40172
Subject		: lockdep trace from post 3.0.
Submitter	: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date		: 2011-07-24 1:32 (22 days old)
Message-ID	: <20110724013257.GA6777-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D131147120206819&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D40092
Subject		: RCU stall in linux-3.0.0
Submitter	: Philip Armstrong <phil-awZZuG094qgqdlJmJB21zg@public.gmane.org>
Date		: 2011-07-25 21:44 (21 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D40072
Subject		: suspend/resume problems w/ kernel 3.0 and a *docked* ThinkPa=
d T400, unless iwlagn unloaded
Submitter	: Toralf F=C3=B6rster <toralf.foerster-Mmb7MZpHnFY@public.gmane.org>
Date		: 2011-07-23 19:27 (23 days old)
Message-ID	: <201107232127.34255.toralf.foerster-Mmb7MZpHnFY@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D131144928023465&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D39972
Subject		: [regression] Radeon multi-screen
Submitter	: Robert Piasek <dagger-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Date		: 2011-07-25 14:04 (21 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D39922
Subject		: WIFI becomes EXTREMELY slow ( ath9k ) making the connection =
unusable
Submitter	: Lukasz Olszewski <lcpak-tIkWECEXGi3VItvQsEIGlw@public.gmane.org>
Date		: 2011-07-24 09:20 (22 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D39912
Subject		: WARNING: at drivers/tty/tty_ldisc.c:766 tty_ldisc_reinit+0x7=
d/0x90()
Submitter	: Vegard Nossum <vegard.nossum-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-07-19 11:33 (27 days old)
Message-ID	: <CAOMGZ=3DHS2EPkYD=3D5HfkSPpwPqHB5V3q0vaFmoZ8Hh+pMM9phrQ@m=
ail.gmail.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D131107522914558&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D39902
Subject		: ath: Unable to reset channel (2412 MHz), reset status -5
Submitter	: Justin P. Mattock <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-07-19 6:13 (27 days old)
Message-ID	: <4E252076.1050309-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D131105603428323&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D39832
Subject		: HDA ATI HDMI: no sound with 3.0 - 2.6.39.3 works
Submitter	: Andreas Steinmetz <ast-sy9/ueDX/ME@public.gmane.org>
Date		: 2011-07-23 01:36 (23 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D39732
Subject		: JBD: Spotted dirty metadata buffer (dev =3D dm-2, blocknr =3D=
 2512725). There's a risk of filesystem corruption in case of system cr=
ash.
Submitter	: Witold Baryluk <baryluk-W6Hso+/wx31C2Nf1M/Lcnw@public.gmane.org>
Date		: 2011-07-22 04:22 (24 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D39412
Subject		: Win Vista and Win2K8 guests' network breaks down
Submitter	: Jay Ren <yongjie.ren-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date		: 2011-07-15 15:31 (31 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D39342
Subject		: [3.0.0-rc6-git7] possible recursive locking at cache_alloc_r=
efill
Submitter	: Tetsuo Handa <penguin-kernel-1yMVhJb1mP/7nzcFbJAaVXf5DAMn2ifp@public.gmane.org>
Date		: 2011-07-11 12:37 (35 days old)
Message-ID	: <201107112137.FAD00545.SHtLOFOJOMFQFV-JPay3/Yim36HaxMnTkn67Xf5DAMn2ifp@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D131038788902151&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D39192
Subject		: firmware_install fails with parallel make
Submitter	: Ambroz Bizjak <ambrop7-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-07-12 09:35 (34 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D39132
Subject		: Starting with 3.0.0-rc6, masquerading seems to be broken.
Submitter	: David Hill <hilld-HTiBYHdybX7UkGsOFmftXw@public.gmane.org>
Date		: 2011-07-10 19:45 (36 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D38922
Subject		: Lenovo T420 (Sandy Bridge) Crashes on SD Card gpt partition =
writing and io errors on insert
Submitter	: Peter Vollmer <vollmerpeter-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Date		: 2011-07-07 17:33 (39 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/a3c7778f8153b9e4eceea67=
38973280b9e63c618


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D38622
Subject		: [radeon cayman regresion] artefacts on screen
Submitter	: Marek Hobler, &apos;neutrinus&apos; <kernellist@neutrinus.c=
om>
Date		: 2011-07-01 09:35 (45 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D38612
Subject		: Boot time warnings in APIC
Submitter	: Bill Huey <bill.huey-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-07-01 06:44 (45 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D38582
Subject		: T510 43495KG won't resume with 32bit installation
Submitter	: Marc Koschewski <marc-e1Wt+8K1Ta8ZEwqihLH0+Q@public.gmane.org>
Date		: 2011-06-30 22:39 (46 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D37432
Subject		: sdhci-pci fails on 3.0.0-rc1 on Dell E6510
Submitter	: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Date		: 2011-06-07 20:06 (69 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/da7822e5ad71ec9b745b412=
639f1e5e0ba795a20
References	: http://article.gmane.org/gmane.linux.kernel.mmc/8442
		  https://lkml.org/lkml/2011/6/23/660


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D40062
Subject		: USB related "unable to handle kernel paging request" in 3.0.=
0-rc7
Submitter	: Tino Keitel <tino.keitel-rAwCM5oiXHA@public.gmane.org>
Date		: 2011-07-22 19:27 (24 days old)
Message-ID	: <20110722192722.GA9369-dW8JlKMZij8@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D131136334621623&w=3D=
2
Patch		: https://lkml.org/lkml/2011/8/2/174


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D39882
Subject		: Kernel oops when turning bluetooth mouse on
Submitter	: Lamarque V. Souza <lamarque-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-07-24 02:09 (22 days old)
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=3D66632


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D37872
Subject		: CPU lockup during boot
Submitter	: Bruno Wolff III <bruno-bdMChIhFSYk@public.gmane.org>
Date		: 2011-06-19 15:00 (57 days old)
Patch		: https://bugzilla.kernel.org/show_bug.cgi?id=3D37872#c16


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions introd=
uced
between 2.6.39 and 3.0, unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D36912

Please let the tracking team know if there are any Bugzilla entries tha=
t
should be added to the list in there.

Thanks!
