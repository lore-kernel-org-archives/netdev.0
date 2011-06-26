From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 3.0-rc4: Reported regressions from 2.6.39
Date: Sun, 26 Jun 2011 23:18:39 +0200 (CEST)
Message-ID: <VDRaLpg_NZ.A.tnC.JZ6BOB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.freedesktop.org>,
	Florian Mickler <florian@mickler.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <dri-devel-bounces+sf-dri-devel=m.gmane.org@lists.freedesktop.org>
Content-Disposition: inline
List-Unsubscribe: <http://lists.freedesktop.org/mailman/options/dri-devel>,
	<mailto:dri-devel-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <http://lists.freedesktop.org/archives/dri-devel>
List-Post: <mailto:dri-devel@lists.freedesktop.org>
List-Help: <mailto:dri-devel-request@lists.freedesktop.org?subject=help>
List-Subscribe: <http://lists.freedesktop.org/mailman/listinfo/dri-devel>,
	<mailto:dri-devel-request@lists.freedesktop.org?subject=subscribe>
Sender: dri-devel-bounces+sf-dri-devel=m.gmane.org@lists.freedesktop.org
Errors-To: dri-devel-bounces+sf-dri-devel=m.gmane.org@lists.freedesktop.org
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
  2011-06-26       22       14          12
  2011-06-12        8        7           7


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=38302
Subject		: NFS crash in un-modified 3.0.0-rc3+, list corruption.
Submitter	: Ben Greear <greearb@candelatech.com>
Date		: 2011-06-20 22:42 (7 days old)
Message-ID	: <4DFFCCDC.2070106@candelatech.com>
References	: http://marc.info/?l=linux-kernel&m=130860979610651&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=38292
Subject		: slab vs lockdep vs debugobjects
Submitter	: Peter Zijlstra <peterz@infradead.org>
Date		: 2011-06-20 17:48 (7 days old)
Message-ID	: <1308592080.26237.114.camel@twins>
References	: http://marc.info/?l=linux-kernel&m=130859214215636&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=38152
Subject		: acpi_power_off lockdep splat
Submitter	: Borislav Petkov <bp@alien8.de>
Date		: 2011-06-19 13:30 (8 days old)
Message-ID	: <20110619133049.GA18168@liondog.tnic>
References	: http://marc.info/?l=linux-kernel&m=130849028317365&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=38142
Subject		: i915, framebuffer: wrong xoffset?
Submitter	: Lucas De Marchi <lucas.de.marchi@gmail.com>
Date		: 2011-06-18 16:29 (9 days old)
Message-ID	: <BANLkTikAJEma_NNi0NYnjBEB6RkFJK3Dpg@mail.gmail.com>
References	: http://marc.info/?l=linux-kernel&m=130841462202826&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=38122
Subject		: 3.0-rc3 WARNING: at drivers/gpu/drm/i915/i915_drv.c:340 gen6_gt_force_wake_put+0x29/0x52 [i915]()
Submitter	: Jens Axboe <jaxboe@fusionio.com>
Date		: 2011-06-14 12:12 (13 days old)
Message-ID	: <<4DE3E2C9.6060207@fusionio.com>>
References	: http://marc.info/?l=linux-kernel&m=130805412314680&w=2
		  https://lkml.org/lkml/2011/5/30/261


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=37562
Subject		: /scripts/depmod.sh ends up -rw-r--r-- 1 depmod.sh
Submitter	: Andrew <atswartz@gmail.com>
Date		: 2011-06-15 23:49 (12 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=37482
Subject		: Driver: i915 - Starting with kernel 3.0.0-rc3, dual monitor freezes a Dell Latitude E6410 when a second monitor is connected at boot time
Submitter	: David Hill <hilld@binarystorm.net>
Date		: 2011-06-14 18:42 (13 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=37432
Subject		: sdhci-pci fails on 3.0.0-rc1 on Dell E6510
Submitter	: Oliver Hartkopp <socketcan@hartkopp.net>
Date		: 2011-06-07 20:06 (20 days old)
First-Bad-Commit: http://git.kernel.org/linus/da7822e5ad71ec9b745b412639f1e5e0ba795a20
References	: http://article.gmane.org/gmane.linux.kernel.mmc/8442


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=37232
Subject		: [3.0-rc1][NMI/DMAR][iwlagn] errors - PCI system error (SERR) for reason a1 on CPU 0
Submitter	: Shawn Starr <shawn.starr@rogers.com>
Date		: 2011-06-03 4:56 (24 days old)
Message-ID	: <4478124.OuFNgaPiHS@segfault.sh0n.net>
References	: http://marc.info/?l=linux-kernel&m=130707737616116&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=36972
Subject		: 3.0-rc1: DMAR errors from iwlagn
Submitter	: Jeremy Fitzhardinge <jeremy@goop.org>
Date		: 2011-05-31 21:14 (27 days old)
Message-ID	: <4DE55A26.6040702@goop.org>
References	: http://marc.info/?l=linux-kernel&m=130687723213857&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=36452
Subject		: Artifacts with 3.0-rc1 on SandyBridge
Submitter	: Alex Zhavnerchik <alex.vizor@gmail.com>
Date		: 2011-06-01 13:55 (26 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=36302
Subject		: SandyBridge can't do s2disk with linux 3.0-rc1
Submitter	: Alex Zhavnerchik <alex.vizor@gmail.com>
Date		: 2011-05-30 23:10 (28 days old)


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=38012
Subject		: Missing code to load firmware
Submitter	: Larry Finger <Larry.Finger@lwfinger.net>
Date		: 2011-06-20 21:44 (7 days old)
Handled-By	: Larry Finger <Larry.Finger@lwfinger.net>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=63002


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=37542
Subject		: [OOPS] 3.0-rc1 cifs
Submitter	: Martijn Uffing <mp3project@sarijopen.student.utwente.nl>
Date		: 2011-06-09 20:15 (18 days old)
Message-ID	: <Pine.LNX.4.64.1106092211500.19687@sarijopen.student.utwente.nl>
References	: http://marc.info/?l=linux-kernel&m=130765235926144&w=2
Handled-By	: Jeff Layton <jlayton@redhat.com>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=63202


For details, please visit the bug entries and follow the links given in
references.

As you can see, there is a Bugzilla entry for each of the listed regressions.
There also is a Bugzilla entry used for tracking the regressions from 2.6.39,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=36912

Please let the tracking team know if there are any Bugzilla entries that
should be added to the list in there.

Thanks!
