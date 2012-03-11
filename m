From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 3.3-rc7: Reported regressions 3.1 -> 3.2
Date: Sun, 11 Mar 2012 22:46:18 +0100 (CET)
Message-ID: <5lvJI01hLEP.A.LnC.3_RXPB@chimera>
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

This message contains a list of some post-3.1 regressions introduced before
3.2, for which there are no fixes in the mainline known to the tracking team.
If any of them have been fixed already, please let us know.

If you know of any other unresolved post-3.1 regressions, please let us know
either and we'll add them to the list.  Also, please let us know if any
of the entries below are invalid.

Each entry from the list will be sent additionally in an automatic reply to
this message with CCs to the people involved in reporting and handling the
issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2012-03-11        9        6           5
  2012-03-04        9        8           7
  2012-02-24        9        8           7


Unresolved regressions
----------------------

Bug-Entry	: https://bugzilla.kernel.org/show_bug.cgi?id=42684
Subject		: FYIO: usb/video 3.2 breaks logitech 9000pro webcam focus control
Submitter	: M G Berberich <berberic-vmG2aq7wDA3mFSIgyKwhw7NAH6kLmebB@public.gmane.org>
Date		: 2012-01-23 21:49 (49 days old)
Message-ID	: <20120123214934.GA4240@invalid>
References	: http://marc.info/?l=linux-kernel&m=132735609521443&w=2


Bug-Entry	: https://bugzilla.kernel.org/show_bug.cgi?id=42631
Subject		: Sound broken in 3.2.0 and 3.2.1
Submitter	: Joseph Parmelee <jparmele-0t/HR9YC43JWk0Htik3J/w@public.gmane.org>
Date		: 2012-01-13 19:44 (59 days old)
Message-ID	: <alpine.LNX.2.00.1201131241090.1239@bruno>
References	: http://marc.info/?l=linux-kernel&m=132648462806235&w=2


Bug-Entry	: https://bugzilla.kernel.org/show_bug.cgi?id=42629
Subject		: recvmsg sleeping from invalid context
Submitter	: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date		: 2012-01-13 18:24 (59 days old)
Message-ID	: <20120113182401.GA25885-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=132647921304184&w=2


Bug-Entry	: https://bugzilla.kernel.org/show_bug.cgi?id=42611
Subject		: kernel 3.2 crashes too early on HP dc7700 and HP t5000 series
Submitter	: Dmitry D. Khlebnikov <galaxy-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
Date		: 2012-01-10 11:49 (62 days old)
Message-ID	: <20120110114905.GC13535-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=132619793012702&w=2


Bug-Entry	: https://bugzilla.kernel.org/show_bug.cgi?id=42610
Subject		: 3.2.0 reboot powers off machine
Submitter	: Tom Weber <l_linux-kernel-w8lRr17kQ6puIcIf6OMhTAC/G2K4zDHf@public.gmane.org>
Date		: 2012-01-11 11:03 (61 days old)
Message-ID	: <1326279818.24835.12.camel@utumno>
References	: http://marc.info/?l=linux-kernel&m=132628059308023&w=2


Regressions with patches
------------------------

Bug-Entry	: https://bugzilla.kernel.org/show_bug.cgi?id=42571
Subject		: BUG in ofcs2_change_file_space
Submitter	: Bret Towe <magnade-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2012-01-05 22:23 (67 days old)
Message-ID	: <CALjC5haTNDMOTDPL1m1uBTc2a-Qb8cvR44SCaVDFMzGc+Gw3+w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=132580236211209&w=2
Patch		: http://oss.oracle.com/pipermail/ocfs2-devel/2012-January/008464.html


For details, please visit the bug entries and follow the links given in
references.

As you can see, there is a Bugzilla entry for each of the listed regressions.
There also is a Bugzilla entry used for tracking the regressions introduced
between 3.1 and 3.2, unresolved as well as resolved, at:

https://bugzilla.kernel.org/show_bug.cgi?id=42566

Please let the tracking team know if there are any Bugzilla entries that
should be added to the list in there.

Thanks!
