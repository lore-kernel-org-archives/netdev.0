From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.36-rc7-git2: Reported regressions from 2.6.35
Date: Sun, 10 Oct 2010 19:46:14 +0200 (CEST)
Message-ID: <v0Rsc8XZnFC.A.-xF.oqfsMB@chimera>
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
  2010-10-10       56       16          15
  2010-10-03       52       16          14
  2010-09-26       46       15          13
  2010-09-20       38       15          15
  2010-09-12       28       14          13
  2010-08-30       21       16          15


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=19862
Subject		: [REGRESSION] no sound on T60 laptop (HDA Intel)
Submitter	: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Date		: 2010-10-05 9:25 (6 days old)
Message-ID	: <E1P33mT-0003qa-Fv-8f8m9JG5TPIdUIPVzhDTVZP2KDSNp7ea@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128627079921512&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=19802
Subject		: [drm:init_ring_common] *ERROR* render ring head not reset to zero
Submitter	: Thomas Meyer <thomas-VsYtu1Qij5c@public.gmane.org>
Date		: 2010-10-04 20:31 (7 days old)
Message-ID	: <201010042231.20320.thomas-VsYtu1Qij5c@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128622441331199&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=19782
Subject		: 2.6.36-rc6-git2 -- BUG dentry: Poison overwritten (after resume from hibernation)
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-10-03 3:54 (8 days old)
Message-ID	: <AANLkTimrqtzBHAZSuDhEs_3CKA6pCbM35b1BtKH=MvC_-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128607809314079&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=19632
Subject		: 2.6.36-rc6: modprobe Not tainted warning
Submitter	: Heinz Diehl <htd-iEI8Y0CNJBYdnm+yROfE0A@public.gmane.org>
Date		: 2010-09-30 18:25 (11 days old)
Message-ID	: <20100930182516.GA15089-iEI8Y0CNJBYdnm+yROfE0A@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128587114004680&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=19392
Subject		: WARNING: at drivers/net/wireless/ath/ath5k/base.c:3475 ath5k_bss_info_changed+0x44/0x168 [ath5k]()
Submitter	: Justin Mattock <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-09-28 22:30 (13 days old)
Message-ID	: <AANLkTim5WCGKPvEkOkO_YnMF9pg8mvLfQoFBNUFpfa_k-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128571307018635&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=19372
Subject		: 2.6.36-rc6: WARNING: at drivers/gpu/drm/radeon/radeon_fence.c:235 radeon_fence_wait+0x35a/0x3c0
Submitter	: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-09-29 21:29 (12 days old)
Message-ID	: <20100929212923.GA5578-y0M6fkzdUYllgR+Ck+lCww@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128579579400315&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=19142
Subject		: Screen flickers when switching from the console to X
Submitter	: Andrey Rahmatullin <wrar-u2l5PoMzF/Vg9hUCZPvPmw@public.gmane.org>
Date		: 2010-09-27 12:05 (14 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=19072
Subject		: [2.6.36-rc regression] occasional complete system hangs on sparc64 SMP
Submitter	: Mikael Pettersson <mikpe-1zs4UD6AkMk@public.gmane.org>
Date		: 2010-09-23 17:02 (18 days old)
Message-ID	: <19611.34846.813757.309183-tgku4HJDRZih8lFjZTKsyTAV6s6igYVG@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128526136531048&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=19052
Subject		: 2.6.36-rc5-git1 -- [drm:i915_report_and_clear_eir] *ERROR* EIR stuck: 0x00000010, masking
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-09-22 23:47 (19 days old)
Message-ID	: <AANLkTikWQjUQjFJU9MO1+XbSLAEE-GARz+S+Dz2Fgu4h-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128519926626322&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=19002
Subject		: Radeon rv730 AGP/KMS/DRM kernel lockup
Submitter	: Duncan <1i5t5.duncan-j9pdmedNgrk@public.gmane.org>
Date		: 2010-09-23 16:48 (18 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17361
Subject		: Random kmemcheck errors and kernel freeze on 2.6.36-rc*
Submitter	: Christian Casteyde <casteyde.christian-GANU6spQydw@public.gmane.org>
Date		: 2010-08-29 19:59 (43 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17121
Subject		: Two blank rectangles more than 10 cm long when booting
Submitter	: Eric Valette <eric.valette-GANU6spQydw@public.gmane.org>
Date		: 2010-08-26 17:24 (46 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17061
Subject		: 2.6.36-rc1 on zaurus: bluetooth regression
Submitter	: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Date		: 2010-08-21 15:24 (51 days old)
Message-ID	: <20100821152445.GA1536-+ZI9xUNit7I@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128240433828087&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16971
Subject		: qla4xxx compile failure on 32-bit PowerPC: missing readq and writeq
Submitter	: Meelis Roos <mroos-Y27EyoLml9s@public.gmane.org>
Date		: 2010-08-19 21:03 (53 days old)
Message-ID	: <alpine.SOC.1.00.1008192359310.19654-ptEonEWSGqKptlylMvRsHA@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128225184900892&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16951
Subject		: hackbench regression with 2.6.36-rc1
Submitter	: Zhang, Yanmin <yanmin_zhang-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Date		: 2010-08-18 6:18 (54 days old)
Message-ID	: <1282112318.21202.8.camel-sz7BYL/Y5Hu/P+R7jlPCFVaTQe2KTcn/@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128211235904910&w=2


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=18742
Subject		: PROBLEM: Kernel panic on 2.6.36-rc4 when loading intel_ips on Core i3 laptop
Submitter	: infernix <infernix-ZHiucA87ovfk1uMJSBkQmQ@public.gmane.org>
Date		: 2010-09-15 14:35 (26 days old)
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
