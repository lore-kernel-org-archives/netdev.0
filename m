From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.37-rc4-git1: Reported regressions from 2.6.36
Date: Fri,  3 Dec 2010 00:35:49 +0100 (CET)
Message-ID: <1OMp3vU_qjP.A.JXG.uxC-MB@chimera>
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
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This message contains a list of some regressions from 2.6.36,
for which there are no fixes in the mainline known to the tracking team.
If any of them have been fixed already, please let us know.

If you know of any other unresolved regressions from 2.6.36, please let us
know either and we'll add them to the list.  Also, please let us know
if any of the entries below are invalid.

Each entry from the list will be sent additionally in an automatic reply
to this message with CCs to the people involved in reporting and handling
the issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2010-12-03       55       25          19
  2010-11-19       39       29          25


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=24142
Subject		: No more bt848 driver in 2.6.37-rc*
Submitter	: Christian Casteyde <casteyde.christian@free.fr>
Date		: 2010-11-30 20:50 (3 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=23902
Subject		: [BUG] 2.6.37-rc3 massive interactivity regression on ARM
Submitter	: Mikael Pettersson <mikpe@it.uu.se>
Date		: 2010-11-27 15:16 (6 days old)
Message-ID	: <19697.8378.717761.236202@pilspetsen.it.uu.se>
References	: http://marc.info/?l=linux-kernel&m=129087098911837&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=23762
Subject		: kernel 2.6.37-rc2 breaks i915 graphics
Submitter	: Chris Vine <chris@cvine.freeserve.co.uk>
Date		: 2010-11-21 10:23 (12 days old)
Message-ID	: <20101121102344.7c590b99@laptop.homenet>
References	: http://marc.info/?l=linux-kernel&m=129033505414671&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=23542
Subject		: HP 2530p accelerated graphics causes spontaneous power off/on
Submitter	: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date		: 2010-11-22 17:12 (11 days old)
References	: https://patchwork.kernel.org/patch/365092/
Handled-By	: Bjorn Helgaas <bjorn.helgaas@hp.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=23462
Subject		: DVI/EDID broken with Intel i945 graphics and 2.6.37-rc2
Submitter	: Tino Keitel <tino.keitel@tikei.de>
Date		: 2010-11-16 18:49 (17 days old)
Message-ID	: <20101116184914.GA15794@mac.home>
References	: http://marc.info/?l=linux-kernel&m=128993389113001&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=23432
Subject		: resume from suspend hangs on everex stepnote sa2053
Submitter	: tomas m <tmezzadra@gmail.com>
Date		: 2010-11-21 13:32 (12 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=23332
Subject		: Boot failure on HP nx6325
Submitter	: Rafael J. Wysocki <rjw@sisk.pl>
Date		: 2010-11-20 00:57 (13 days old)
First-Bad-Commit: http://git.kernel.org/linus/1af3c2e45e7a641e774bbb84fa428f2f0bf2d9c9
Handled-By	: Bjorn Helgaas <bjorn.helgaas@hp.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=23142
Subject		: autofs4 hang in 2.6.37-rc1
Submitter	: Avi Kivity <avi@redhat.com>
Date		: 2010-11-14 12:55 (19 days old)
Message-ID	: <4CDFDC2B.6040205@redhat.com>
References	: http://marc.info/?l=linux-kernel&m=128973936026185&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=23102
Subject		: [bisected] i915 regression in post 2.6.36 kernels
Submitter	: Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>
Date		: 2010-11-10 7:02 (23 days old)
Message-ID	: <201011100802.20332.johannes.hirte@fem.tu-ilmenau.de>
References	: http://marc.info/?l=linux-kernel&m=128937310017057&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=22942
Subject		: [2.6.37-rc1, OOM] virtblk: OOM in do_virtblk_request()
Submitter	: Dave Chinner <david@fromorbit.com>
Date		: 2010-11-05 1:30 (28 days old)
Message-ID	: <20101105013003.GE13830@dastard>
References	: http://marc.info/?l=linux-kernel&m=128892062917641&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=22912
Subject		: spi_lm70llp module crash on unload (2.6.37-rc1)
Submitter	: Randy Dunlap <randy.dunlap@oracle.com>
Date		: 2010-11-05 0:16 (28 days old)
Message-ID	: <20101104171620.00d8c95d.randy.dunlap@oracle.com>
References	: http://marc.info/?l=linux-kernel&m=128891627913647&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=22882
Subject		: (2.6.37-rc1) amd64-agp module crashed on second load
Submitter	: Randy Dunlap <randy.dunlap@oracle.com>
Date		: 2010-11-05 0:13 (28 days old)
Message-ID	: <20101104171333.fea1f498.randy.dunlap@oracle.com>
References	: http://marc.info/?l=linux-kernel&m=128891605213447&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=22812
Subject		: kernel oops on 2.6.37-rc1
Submitter	: Andrew <atswartz@gmail.com>
Date		: 2010-11-12 16:05 (21 days old)
First-Bad-Commit: http://git.kernel.org/linus/a68c439b1966c91f0ef474e2bf275d6792312726


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=22672
Subject		: Regression in 2.6.37-rc1 for Intel 945 Graphics Adapter - bisected to commit e9e331a
Submitter	: Larry Finger <Larry.Finger@lwfinger.net>
Date		: 2010-11-11 01:56 (22 days old)
References	: https://bugs.freedesktop.org/show_bug.cgi?id=31803
		  http://marc.info/?l=linux-kernel&m=128944001311444&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=22642
Subject		: 2.6.37-rc1: Disk takes 10 seconds to resume - MacBook2,1
Submitter	: Tobias <devnull@plzk.org>
Date		: 2010-11-10 19:33 (23 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=22562
Subject		: Regression in 2.6.37-rc1 - logs spammed with "unable to enumerate USB port" - bisected to commit 3df7169e
Submitter	: Larry Finger <Larry.Finger@lwfinger.net>
Date		: 2010-11-02 22:32 (31 days old)
First-Bad-Commit: http://git.kernel.org/linus/3df7169e73fc1d71a39cffeacc969f6840cdf52b
Message-ID	: <4CD09166.4060202@lwfinger.net>
References	: http://marc.info/?l=linux-kernel&m=128873713207906&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=22542
Subject		: [2.6.37-rc1] drm:i195 errors
Submitter	: Paul Rolland <rol@witbe.net>
Date		: 2010-11-02 14:58 (31 days old)
Message-ID	: <20101102155813.09cb2c6e@tux.DEF.witbe.net>
References	: http://marc.info/?l=linux-kernel&m=128870991628970&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=22532
Subject		: 2.6.37-rc1: BUG: scheduling while atomic (kvm_init)
Submitter	: Thomas Meyer <thomas@m3y3r.de>
Date		: 2010-11-02 19:06 (31 days old)
Message-ID	: <50AA24C585B14210A44AB599605C7CBD@hugo>
References	: http://marc.info/?l=linux-kernel&m=128872479921559&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=22472
Subject		: vga_switcheroo fails to switch from intel to ati
Submitter	: Radu Andries <admiral0@tuxfamily.org>
Date		: 2010-11-08 16:46 (25 days old)


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=24012
Subject		: Commit g18733b0 hangs my LVM+raid10 system
Submitter	: Giacomo Catenazzi <cate@cateee.net>
Date		: 2010-11-29 19:48 (4 days old)
Handled-By	: Neil Brown <neilb@suse.de>
Patch		: https://bugzilla.kernel.org/show_bug.cgi?id=24012#c16


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=23452
Subject		: 5ada28bf76752 causes compilation error if !CONFIG_LEDS_CLASS
Submitter	: Michal Hocko <mhocko@suse.cz>
Date		: 2010-11-16 14:20 (17 days old)
Message-ID	: <20101116142027.GC19247@tiehlicka.suse.cz>
References	: http://marc.info/?l=linux-kernel&m=128991726220668&w=2
Handled-By	: Johannes Berg <johannes.berg@intel.com>
Patch		: https://patchwork.kernel.org/patch/365582/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=23012
Subject		: ftdi_sio /dev/ttyUSB error:  "Resource Temporarily Unavailable"
Submitter	: Kevin Smith <thirdwiggin@gmail.com>
Date		: 2010-11-16 06:25 (17 days old)
Handled-By	: Alan Stern <stern@rowland.harvard.edu>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=38372


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=22932
Subject		: [REGRESSION] [2.6.37-rc1] Fan noise after suspend to ram/disk
Submitter	: Maciej Rutecki <maciej.rutecki@gmail.com>
Date		: 2010-11-04 16:06 (29 days old)
First-Bad-Commit: http://git.kernel.org/linus/3e384ee6c687cb397581ee8f9440fc8220cfac80
Message-ID	: <201011041706.59046.maciej.rutecki@gmail.com>
References	: http://marc.info/?l=linux-kernel&m=128888684308982&w=2
Handled-By	: Rafael J. Wysocki <rjw@sisk.pl>
Patch		: https://patchwork.kernel.org/patch/354682/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=22662
Subject		: divide error in select_task_rq_fair()
Submitter	: Myron Stowe <myron.stowe@hp.com>
Date		: 2010-11-10 23:58 (23 days old)
Patch		: http://lkml.org/lkml/2010/11/13/176
		  http://lkml.org/lkml/2010/11/13/181


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=22572
Subject		: Linux 2.6.37-rc1 (acpi_video)
Submitter	: Randy Dunlap <randy.dunlap@oracle.com>
Date		: 2010-11-02 18:51 (31 days old)
Message-ID	: <20101102115106.bac57d21.randy.dunlap@oracle.com>
References	: http://marc.info/?l=linux-kernel&m=128872403920449&w=2
		  http://marc.info/?l=linux-acpi&m=128874714517914&w=2
Handled-By	: Zhang Rui <rui.zhang@intel.com>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=36992


For details, please visit the bug entries and follow the links given in
references.

As you can see, there is a Bugzilla entry for each of the listed regressions.
There also is a Bugzilla entry used for tracking the regressions from 2.6.36,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=21782

Please let the tracking team know if there are any Bugzilla entries that
should be added to the list in there.

Thanks!

