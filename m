From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.36-rc5-git7: Reported regressions from 2.6.35
Date: Sun, 26 Sep 2010 21:55:19 +0200 (CEST)
Message-ID: <MEG5YPP-fxC.A.vnD.So6nMB@chimera>
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

This message contains a list of some regressions from 2.6.35,
for which there are no fixes in the mainline known to the tracking team.
If any of them have been fixed already, please let us know.

If you know of any other unresolved regressions from 2.6.35, please let us
know either and we'll add them to the list.  Also, please let us know
if any of the entries below are invalid.

Each entry from the list will be sent additionally in an automatic reply
to this message with CCs to the people involved in reporting and handling
the issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2010-09-26       46       15          13
  2010-09-20       38       15          15
  2010-09-12       28       14          13
  2010-08-30       21       16          15


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=19082
Subject		: fs/fs-writeback.c to dump
Submitter	: Pavel Vasilyev <pavel-wkUsHEiXLHUox3rIn2DAYQ@public.gmane.org>
Date		: 2010-09-25 15:52 (2 days old)
Message-ID	: <201009251952.58749.pavel-wkUsHEiXLHUox3rIn2DAYQ@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128543035026659&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=19072
Subject		: [2.6.36-rc regression] occasional complete system hangs on sparc64 SMP
Submitter	: Mikael Pettersson <mikpe-1zs4UD6AkMk@public.gmane.org>
Date		: 2010-09-23 17:02 (4 days old)
Message-ID	: <19611.34846.813757.309183-tgku4HJDRZih8lFjZTKsyTAV6s6igYVG@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128526136531048&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=19062
Subject		: Dirtiable inode bdi default != sb bdi btrfs
Submitter	: Cesar Eduardo Barros <cesarb-PWySMVKUnqmsTnJN9+BGXg@public.gmane.org>
Date		: 2010-09-23 0:54 (4 days old)
Message-ID	: <4C9AA546.6050201-PWySMVKUnqmsTnJN9+BGXg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128520328929595&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=19052
Subject		: 2.6.36-rc5-git1 -- [drm:i915_report_and_clear_eir] *ERROR* EIR stuck: 0x00000010, masking
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-09-22 23:47 (5 days old)
Message-ID	: <AANLkTikWQjUQjFJU9MO1+XbSLAEE-GARz+S+Dz2Fgu4h-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128519926626322&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=19002
Subject		: Radeon rv730 AGP/KMS/DRM kernel lockup
Submitter	: Duncan <1i5t5.duncan-j9pdmedNgrk@public.gmane.org>
Date		: 2010-09-23 16:48 (4 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=18992
Subject		: warn_slow_path_common in iwlagn/mac80211 in 2.6.36-rc5
Submitter	: rocko <rockorequin-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org>
Date		: 2010-09-23 03:07 (4 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=18342
Subject		: [regression] i915 incorrectly detects bogus LVDS connection instead of LVDS1
Submitter	: Woody Suwalski <terraluna977-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-09-08 15:10 (19 days old)
Message-ID	: <AANLkTim2mrVRCKg-2couMTFV7krHQp0+2e_cbaiT_KYW-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128395866331382&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17722
Subject		: 2.6.36-rc3: WARNING: at net/mac80211/scan.c:269 ieee80211_scan_completed
Submitter	: Thomas Meyer <thomas-VsYtu1Qij5c@public.gmane.org>
Date		: 2010-08-31 20:14 (27 days old)
Message-ID	: <201008312214.52473.thomas-VsYtu1Qij5c@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128328580504227&w=2
		  http://www.spinics.net/lists/netdev/msg140769.html


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17361
Subject		: Watchdog detected hard LOCKUP in jbd2_journal_get_write_access
Submitter	: Christian Casteyde <casteyde.christian-GANU6spQydw@public.gmane.org>
Date		: 2010-08-29 19:59 (29 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17121
Subject		: Two blank rectangles more than 10 cm long when booting
Submitter	: Eric Valette <eric.valette-GANU6spQydw@public.gmane.org>
Date		: 2010-08-26 17:24 (32 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17061
Subject		: 2.6.36-rc1 on zaurus: bluetooth regression
Submitter	: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Date		: 2010-08-21 15:24 (37 days old)
Message-ID	: <20100821152445.GA1536-+ZI9xUNit7I@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128240433828087&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16971
Subject		: qla4xxx compile failure on 32-bit PowerPC: missing readq and writeq
Submitter	: Meelis Roos <mroos-Y27EyoLml9s@public.gmane.org>
Date		: 2010-08-19 21:03 (39 days old)
Message-ID	: <alpine.SOC.1.00.1008192359310.19654-ptEonEWSGqKptlylMvRsHA@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128225184900892&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16951
Subject		: hackbench regression with 2.6.36-rc1
Submitter	: Zhang, Yanmin <yanmin_zhang-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Date		: 2010-08-18 6:18 (40 days old)
Message-ID	: <1282112318.21202.8.camel-sz7BYL/Y5Hu/P+R7jlPCFVaTQe2KTcn/@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128211235904910&w=2


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=18962
Subject		: screen failes in kde
Submitter	: Hans de Bruin <jmdebruin-agH9qYG3oEhmR6Xm/wNWPw@public.gmane.org>
Date		: 2010-09-22 15:42 (5 days old)
First-Bad-Commit: http://git.kernel.org/linus/e259befd9013e212648c3bd4f6f1fbf92d0dd51d
Handled-By	: Chris Wilson <chris-Y6uKTt2uX1cEflXRtASbqLVCufUGDwFn@public.gmane.org>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=31042


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=18742
Subject		: PROBLEM: Kernel panic on 2.6.36-rc4 when loading intel_ips on Core i3 laptop
Submitter	: infernix <infernix-ZHiucA87ovfk1uMJSBkQmQ@public.gmane.org>
Date		: 2010-09-15 14:35 (12 days old)
Message-ID	: <4C90D998.6050103-ZHiucA87ovfk1uMJSBkQmQ@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128456187928496&w=2
Handled-By	: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=31112


For details, please visit the bug entries and follow the links given in
references.

As you can see, there is a Bugzilla entry for each of the listed regressions.
There also is a Bugzilla entry used for tracking the regressions from 2.6.35,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=16444

Please let the tracking team know if there are any Bugzilla entries that
should be added to the list in there.

Thanks!
