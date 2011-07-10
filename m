From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 3.0-rc6-git6: Reported regressions from 2.6.39
Date: Sun, 10 Jul 2011 12:19:24 +0200 (CEST)
Message-ID: <Y7LyOsOBwFM.A.kJG.kBYGOB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
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

This message contains a list of some regressions from 2.6.39,
for which there are no fixes in the mainline known to the tracking team.
If any of them have been fixed already, please let us know.

If you know of any other unresolved regressions from 2.6.39, please let us
know either and we'll add them to the list.  Also, please let us know
if any of the entries below are invalid.

Each entry from the list will be sent additionally in an automatic reply
to this message with CCs to the people involved in reporting and handling
the issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2011-07-10       38       16          13
  2011-06-26       22       14          12
  2011-06-12        8        7           7


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=39052
Subject		: .tmp_depmod owned by root after modules_install
Submitter	: Christian Kujau <lists-AanptEQQ3TL9uQeqpI+JUg@public.gmane.org>
Date		: 2011-07-04 9:49 (7 days old)
Message-ID	: <alpine.DEB.2.01.1107040242180.9183-yMVncJ7Z0T9hhup4ARC/jw@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=130977296812731&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=38802
Subject		: Not work hotkey of Microsoft Comfort Curve Keyboard 2000
Submitter	: Cristian Aravena Romero <caravena-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-07-05 20:43 (6 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=38732
Subject		: Linux 3.0-rc5 doesnt boot and hangs at rcu_sched_state ()
Submitter	: RKK <kulkarni.ravi4-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-06-29 13:38 (12 days old)
Message-ID	: <BANLkTikW6Xk8UMsOHLCnLn7STRzy8RaiJA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=130935402722869&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=38702
Subject		: 3.0.0-rc4-git6 - INFO: possible circular locking dependency detected - (&rdev->mtx){+.+.+.}, at: [<ffffffffa00e27e0>] cfg80211_netdev_notifier_call+0x275/0x4ff [cfg80211]
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-06-26 21:54 (15 days old)
Message-ID	: <BANLkTikztsFnPkJZ7VxRC-zsitwCCvVmeg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=130912559804336&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=38672
Subject		: KVM guest boot crashed
Submitter	: Steve <stefan.bosak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-07-02 06:56 (9 days old)
First-Bad-Commit: http://git.kernel.org/linus/6506e4f995967b1a48cc34418c77b318df92ce35


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=38622
Subject		: [radeon cayman regresion] artefacts on screen
Submitter	: Marek Hobler, &apos;neutrinus&apos; <kernellist-X/h6sc6Dz0uakBO8gow8eQ@public.gmane.org>
Date		: 2011-07-01 09:35 (10 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=38612
Subject		: Boot time warnings in APIC
Submitter	: Bill Huey <bill.huey-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-07-01 06:44 (10 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=38582
Subject		: T510 43495KG won't resume with 32bit installation
Submitter	: Marc Koschewski <marc-e1Wt+8K1Ta8ZEwqihLH0+Q@public.gmane.org>
Date		: 2011-06-30 22:39 (11 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=38522
Subject		: address space collision error message on boot
Submitter	: Jools Wills <jools-ApNQbik20ZdhgJEaYHuxyvXRex20P6io@public.gmane.org>
Date		: 2011-06-29 02:28 (12 days old)
First-Bad-Commit: http://git.kernel.org/linus/5d94e81f69d4b1d1102d3ab557ce0a817c11fbbb


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=38332
Subject		: System hang when enable rc6
Submitter	: Gu Rui <chaos.proton-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-06-27 08:16 (14 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=37872
Subject		: CPU lockup during boot
Submitter	: Bruno Wolff III <bruno-bdMChIhFSYk@public.gmane.org>
Date		: 2011-06-19 15:00 (22 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=37482
Subject		: Driver: i915 - Starting with kernel 3.0.0-rc3, dual monitor freezes a Dell Latitude E6410 when a second monitor is connected at boot time
Submitter	: David Hill <hilld-HTiBYHdybX7UkGsOFmftXw@public.gmane.org>
Date		: 2011-06-14 18:42 (27 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=37432
Subject		: sdhci-pci fails on 3.0.0-rc1 on Dell E6510
Submitter	: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Date		: 2011-06-07 20:06 (34 days old)
First-Bad-Commit: http://git.kernel.org/linus/da7822e5ad71ec9b745b412639f1e5e0ba795a20
References	: http://article.gmane.org/gmane.linux.kernel.mmc/8442
		  https://lkml.org/lkml/2011/6/23/660


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=38972
Subject		: Kernel panic when syncing while cifs is mounted
Submitter	:  <farbing-S0/GAf8tV78@public.gmane.org>
Date		: 2011-07-08 15:39 (3 days old)
First-Bad-Commit: http://git.kernel.org/linus/dd8544661947ad6d8d87b3c9d4333bfa1583d1bc
Handled-By	: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=65082


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=38302
Subject		: NFS crash in un-modified 3.0.0-rc3+, list corruption.
Submitter	: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Date		: 2011-06-20 22:42 (21 days old)
Message-ID	: <4DFFCCDC.2070106-my8/4N5VtI7c+919tysfdA@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=130860979610651&w=2
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=63902


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=38152
Subject		: acpi_power_off lockdep splat
Submitter	: Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>
Date		: 2011-06-19 13:30 (22 days old)
Message-ID	: <20110619133049.GA18168-f9CnO7I+Q6zU6FkGJEIX5A@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=130849028317365&w=2
Handled-By	: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>
Patch		: https://patchwork.kernel.org/patch/950852/


For details, please visit the bug entries and follow the links given in
references.

As you can see, there is a Bugzilla entry for each of the listed regressions.
There also is a Bugzilla entry used for tracking the regressions from 2.6.39,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=36912

Please let the tracking team know if there are any Bugzilla entries that
should be added to the list in there.

Thanks!
