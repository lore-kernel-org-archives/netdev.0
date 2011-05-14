From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.39-rc7-git7: Reported regressions from 2.6.38
Date: Sun, 15 May 2011 00:18:48 +0200 (CEST)
Message-ID: <So1vU2GC7XM.A.5wB.44vzNB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: Maciej Rutecki <maciej.rutecki@gmail.com>,
	Florian Mickler <florian@mickler.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.freedesktop.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This message contains a list of some regressions from 2.6.38,
for which there are no fixes in the mainline known to the tracking team.
If any of them have been fixed already, please let us know.

If you know of any other unresolved regressions from 2.6.38, please let us
know either and we'll add them to the list.  Also, please let us know
if any of the entries below are invalid.

Each entry from the list will be sent additionally in an automatic reply
to this message with CCs to the people involved in reporting and handling
the issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2011-05-15       50       12          11
  2011-04-30       38       17          16
  2011-04-17       17       11          10


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=35062
Subject		: Suspend to ram stopped working after commit of " intel-iommu: Unlink domain from iommu "
Submitter	:  <optiluca@gmail.com>
Date		: 2011-05-14 11:08 (1 days old)
First-Bad-Commit: http://git.kernel.org/linus/a97590e56d0d58e1dd262353f7cbd84e81d8e600


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=34952
Subject		: 2.6.39-rc6: SATA hangs for a few seconds during boot
Submitter	: Tino Keitel <tino.keitel@tikei.de>
Date		: 2011-05-09 20:48 (6 days old)
Message-ID	: <20110509204801.GA2258@x61.home>
References	: http://marc.info/?l=linux-kernel&m=130497409509438&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=34942
Subject		: [Bug] Kdump does not work when panic triggered due to MCE
Submitter	: K.Prasad <prasad@linux.vnet.ibm.com>
Date		: 2011-05-06 16:54 (9 days old)
Message-ID	: <20110506165412.GB2719@in.ibm.com>
References	: http://marc.info/?l=linux-kernel&m=130470087226270&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=34662
Subject		: Warning at block/genhd.c:1556 disk_clear_events
Submitter	: Meelis Roos <mroos@linux.ee>
Date		: 2011-05-02 9:59 (13 days old)
Message-ID	: <alpine.SOC.1.00.1105021255400.6200@math.ut.ee>
References	: http://marc.info/?l=linux-kernel&m=130433037002610&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=34492
Subject		: [2.6.39-rc4, x86_32] Stall at default_idle()
Submitter	: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Date		: 2011-04-27 4:49 (18 days old)
Message-ID	: <201104270449.p3R4n54n023453@www262.sakura.ne.jp>
References	: http://marc.info/?l=linux-kernel&m=130387977425687&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=34202
Subject		: MCEUSB remotes don't work with USB 3.0 ports
Submitter	: Aaron Barany <akb825@gmail.com>
Date		: 2011-05-01 23:48 (14 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=34002
Subject		: [REGRESSION] [2.6.39-rc3] Wrong resolution in framebuffer and X Window
Submitter	: Maciej Rutecki <maciej.rutecki@gmail.com>
Date		: 2011-04-17 16:04 (28 days old)
Message-ID	: <201104171804.04664.maciej.rutecki@gmail.com>
References	: http://marc.info/?l=linux-fbdev&m=130305625114863&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=33842
Subject		: NULL pointer dereference in ip_fragment
Submitter	: Tomas Carnecky <tom@dbservice.com>
Date		: 2011-04-23 07:51 (22 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=33792
Subject		: lockdep trace when unplugging usb audio (.39rc4)
Submitter	: Dave Jones <davej@redhat.com>
Date		: 2011-04-19 18:07 (26 days old)
Message-ID	: <20110419180745.GA438@redhat.com>
References	: http://marc.info/?l=linux-kernel&m=130323648920431&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=33272
Subject		: drm related hard-hang
Submitter	: Peter Teoh <htmldeveloper@gmail.com>
Date		: 2011-04-14 01:29 (31 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=33242
Subject		: Lockdep splat in autofs with 2.6.39-rc2
Submitter	: Nick Bowler <nbowler@elliptictech.com>
Date		: 2011-04-07 19:44 (38 days old)
Message-ID	: <20110407194403.GA29404@elliptictech.com>
References	: http://marc.info/?l=linux-kernel&m=130220545614682&w=2


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=33802
Subject		: list_del corruption in sd driver since 2.6.39-rc4
Submitter	: Christian Casteyde <casteyde.christian@free.fr>
Date		: 2011-04-21 21:10 (24 days old)
Handled-By	: James Bottomley <James.Bottomley@suse.de>
Patch		: http://marc.info/?l=linux-kernel&m=130271409412095


For details, please visit the bug entries and follow the links given in
references.

As you can see, there is a Bugzilla entry for each of the listed regressions.
There also is a Bugzilla entry used for tracking the regressions from 2.6.38,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=32012

Please let the tracking team know if there are any Bugzilla entries that
should be added to the list in there.

Thanks!

