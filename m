From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.34-rc2: Reported regressions from 2.6.33
Date: Sun, 21 Mar 2010 20:58:56 +0100 (CET)
Message-ID: <M9dVcHY7TxH.A.2GC.ZBopLB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

[NOTES:
 * In this cycle the regressions reported by e-mail will only be put in=
to the
   Bugzilla 1 week after they have been submitted, if not fixed in the
   meantime.  The reason is that some regressions are fixed in less tha=
n a
   week time and there's no point listing them.  [We also hope that peo=
ple will=20
   try to fix bugs faster to avoid being listed. ;-)]  If that works, w=
e'll
   adopt it as a general rule.

 * All of the regressions reported by e-mail that are listed below have=
 been
   put into the Bugzilla by Maciej, because I literally didn't have the=
 time
   to do that (that's also why the summary reports are delayed).
   Thanks Maciej!]

This message contains a list of some regressions from 2.6.33,
for which there are no fixes in the mainline known to the tracking team=
=2E
If any of them have been fixed already, please let us know.

If you know of any other unresolved regressions from 2.6.33, please let=
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
  2010-03-21       15       13          10


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15590
Subject		: 2.6.34-rc1: regression: ^Z no longer stops sound
Submitter	: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Date		: 2010-03-14 7:58 (8 days old)
Message-ID	: <20100314075831.GA13457-I/5MKhXcvmPrBKCeMvbIDA@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126855353122623&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15589
Subject		: 2.6.34-rc1: Badness at fs/proc/generic.c:316
Submitter	: Christian Kujau <lists-AanptEQQ3TL9uQeqpI+JUg@public.gmane.org>
Date		: 2010-03-13 23:53 (9 days old)
Message-ID	: <alpine.DEB.2.01.1003131544340.5493-uKsf7x9sgtqQ/Pez2Lbyp4QuADTiUCJX@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126852442903680&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15584
Subject		: 2.6.34-rc1: lockdep warning on geode subnotebook
Submitter	: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Date		: 2010-03-13 10:51 (9 days old)
Message-ID	: <20100313105109.GA9966-I/5MKhXcvmPrBKCeMvbIDA@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126847750927601&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15555
Subject		: 2.6.34-rc1: kernel BUG at mm/slab.c:2989!
Submitter	: Am=C3=A9rico Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-03-10 8:29 (12 days old)
Message-ID	: <2375c9f91003100029q7d64bbf7xce15eee97f7e2190-JsoAwUIsXounXO2b/Sh1tA@public.gmane.org=
om>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126820979017089&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15549
Subject		: [2.6.34-rc1][libata] regression?
Submitter	: Etienne Basset <etienne.basset-Bf/eaXMDFuuXqB7oj33eUg@public.gmane.org>
Date		: 2010-03-09 21:47 (13 days old)
Message-ID	: <4B96C202.6050606-Bf/eaXMDFuuXqB7oj33eUg@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126817180811846&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15548
Subject		: BUG: key f70f4b50 not in .data
Submitter	: Sergey Senozhatsky <sergey.senozhatsky-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-03-09 10:27 (13 days old)
Message-ID	: <20100309102754.GA3316-dY8u8AhHFaWtd10JCjopabkcH5ONE+aC@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126813046113130&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15533
Subject		: i915 fails to set mode in 2.6.34-rc1, ok in 2.6.33-rc8
Submitter	: Pete Zaitcev <zaitcev-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
Date		: 2010-03-13 20:37 (9 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15518
Subject		: CONFIG_NO_BOOTMEM=3Dy breaks boot on 32bit
Submitter	: Daniel Vetter <daniel-/w4YWyX8dFk@public.gmane.org>
Date		: 2010-03-11 15:37 (11 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15496
Subject		: 2.6.34-rc1 crashes early while startup
Submitter	: Thomas Meyer <thomas-VsYtu1Qij5c@public.gmane.org>
Date		: 2010-03-09 19:40 (13 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15495
Subject		: Flood of SELinux denials on polkitd
Submitter	: Alex Villacis Lasso <avillaci-x0m+Mc+nT7uljOmnV8AmnkElSqmLX1BE@public.gmane.org>
Date		: 2010-03-09 16:47 (13 days old)


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15537
Subject		: 2.6.34-rc1 hangs for 30 seconds when trying to access the di=
sk
Submitter	: Andrew Benton <b3nton-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-03-14 23:26 (8 days old)
Handled-By	: Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Patch		: http://bugzilla.kernel.org/attachment.cgi?id=3D25516


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15505
Subject		: No more b43 wireless interface since 2.6.34-rc1
Submitter	: Christian Casteyde <casteyde.christian-GANU6spQydw@public.gmane.org>
Date		: 2010-03-10 06:59 (12 days old)
Handled-By	: Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Patch		: https://bugzilla.kernel.org/show_bug.cgi?id=3D15505#c11


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15480
Subject		: [regression] Fails to boot properly unless given pci=3Dnocrs
Submitter	: Yanko Kaneti <yaneti-jUE9FD3ILm5BDgjK7y7TUQ@public.gmane.org>
Date		: 2010-03-09 01:24 (13 days old)
Handled-By	: Bjorn Helgaas <bjorn.helgaas-VXdhtT5mjnY@public.gmane.org>
Patch		: http://lkml.org/lkml/2010/3/11/512


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions from 2=
=2E6.33,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D15310

Please let the tracking team know if there are any Bugzilla entries tha=
t
should be added to the list in there.

Thanks!
