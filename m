From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 3.0-rc2: Reported regressions from 2.6.39
Date: Sun, 12 Jun 2011 22:23:10 +0200 (CEST)
Message-ID: <vv0uv79EvLN.A.jiC.pNS9NB@chimera>
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
  2011-06-12        8        7           7


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=37242
Subject		: lockdep deadlock warning in shutdown
Submitter	: Shaohua Li <shaohua.li-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date		: 2011-06-03 3:24 (10 days old)
Message-ID	: <1307071472.15392.60.camel@sli10-conroe>
References	: http://marc.info/?l=linux-acpi&m=130707148811930&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=37232
Subject		: [3.0-rc1][NMI/DMAR][iwlagn] errors - PCI system error (SERR) for reason a1 on CPU 0
Submitter	: Shawn Starr <shawn.starr-bJEeYj9oJeDQT0dZR+AlfA@public.gmane.org>
Date		: 2011-06-03 4:56 (10 days old)
Message-ID	: <4478124.OuFNgaPiHS-RRHT56Q3PSMGBMjmSbuoWl6hYfS7NtTn@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=130707737616116&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=37222
Subject		: 3.0.0-rc1-git3 -- kernel/sched.c:619 invoked rcu_dereference_check() without protection!
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-06-04 3:22 (9 days old)
Message-ID	: <BANLkTikHS7TuFhm3cfJ+Y=erWDaAwuE_TA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=130715775803343&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=36982
Subject		: 3.0-rc1 problem with usb, cdrom
Submitter	: werner <w.landgraf-ow1r9FSYgO0@public.gmane.org>
Date		: 2011-06-01 16:43 (12 days old)
Message-ID	: <web-538043386-zcyLqNHFQq3Ee+7He9zlJw@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=130694663410114&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=36972
Subject		: 3.0-rc1: DMAR errors from iwlagn
Submitter	: Jeremy Fitzhardinge <jeremy-TSDbQ3PG+2Y@public.gmane.org>
Date		: 2011-05-31 21:14 (13 days old)
Message-ID	: <4DE55A26.6040702-TSDbQ3PG+2Y@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=130687723213857&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=36452
Subject		: Artifacts with 3.0-rc1 on SandyBridge
Submitter	: Alex Zhavnerchik <alex.vizor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-06-01 13:55 (12 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=36302
Subject		: SandyBridge can't do s2disk with linux 3.0-rc1
Submitter	: Alex Zhavnerchik <alex.vizor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2011-05-30 23:10 (14 days old)


Regressions with patches
------------------------

For details, please visit the bug entries and follow the links given in
references.

As you can see, there is a Bugzilla entry for each of the listed regressions.
There also is a Bugzilla entry used for tracking the regressions from 2.6.39,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=36912

Please let the tracking team know if there are any Bugzilla entries that
should be added to the list in there.

Thanks!
