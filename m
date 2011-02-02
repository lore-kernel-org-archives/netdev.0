From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.38-rc3-git1: Reported regressions from 2.6.37
Date: Thu,  3 Feb 2011 00:02:08 +0100 (CET)
Message-ID: <QUnbpYCwS-F.A.vaC.VHeSNB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
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

This message contains a list of some regressions from 2.6.37,
for which there are no fixes in the mainline known to the tracking team=
=2E
If any of them have been fixed already, please let us know.

If you know of any other unresolved regressions from 2.6.37, please let=
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
  2011-02-03       19       11           7


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D28102
Subject		: New display errors in 2.6.38-rc2-00175-g6fb1b30
Submitter	: Nico Schottelius <nico-kernel-20110117@schottelius.org>
Date		: 2011-01-28 20:29 (6 days old)
Message-ID	: <20110128202905.GB3395@schottelius.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129624657425949&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D28052
Subject		: [BUG] 2.6.38-rc2: Circular Locking Dependency
Submitter	: Knut Petersen <Knut_Petersen@t-online.de>
Date		: 2011-01-24 9:25 (10 days old)
Message-ID	: <4D3D45A3.7040809@t-online.de>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129586118515443&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D27812
Subject		: 2.6.38-rc2: acpi backlight control missing
Submitter	: Thomas Meyer <thomas@m3y3r.de>
Date		: 2011-01-22 10:49 (12 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/677bd810eedce61edf15452=
491781ff046b92edc
Message-ID	: <1295693349.2120.3.camel@localhost.localdomain>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129569353414755&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D27652
Subject		: 38-rc1: umount+rmmod cause ext4 error.
Submitter	: Tao Ma <tm@tao.ma>
Date		: 2011-01-19 6:53 (15 days old)
Message-ID	: <4D368A70.5030103@tao.ma>
References	: http://marc.info/?l=3Dlinux-ext4&m=3D129542001031750&w=3D2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D27382
Subject		: ath5k phy0: gain calibration timeout
Submitter	: Nicolas Stransky <Nico@stransky.cx>
Date		: 2011-01-23 00:18 (11 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D27282
Subject		: Regression: 2.6.38 vs. Powertop 2
Submitter	: Dennis Jansen <dennis.jansen@web.de>
Date		: 2011-01-21 14:34 (13 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D27022
Subject		: [REPORT] BUG: spinlock recursion on CPU#0, init/1
Submitter	: Santosh Shilimkar <santosh.shilimkar@ti.com>
Date		: 2011-01-10 15:33 (24 days old)
Message-ID	: <a7a9bdaa5936630925fb7ffd1a1795b1@mail.gmail.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129467294808655&w=3D=
2


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D28012
Subject		: [drm:i915_driver_load] *ERROR* failed to init modeset, EINVA=
L
Submitter	: Ferenc W=C3=A1gner <wferi@niif.hu>
Date		: 2011-02-01 15:18 (2 days old)
Handled-By	: Chris Wilson <chris@chris-wilson.co.uk>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=3D45892


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D27862
Subject		: Cannot launch X.org server on Core I5 with 2.6.38-rc2-git7
Submitter	: Darisuz Luksza <dariusz.luksza@gmail.com>
Date		: 2011-01-30 12:13 (4 days old)
Handled-By	: Chris Wilson <chris@chris-wilson.co.uk>
Patch		: https://bugs.freedesktop.org/attachment.cgi?id=3D42634


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D27702
Subject		: regression 2.6.37 -> 2.6.38-rc1: after suspend backlight can=
not be adjusted
Submitter	: Norbert Preining <preining@logic.at>
Date		: 2011-01-21 1:55 (13 days old)
Message-ID	: <20110121015529.GD9796@gamma.logic.tuwien.ac.at>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129557717826819&w=3D=
2
Handled-By	: Michael Karcher <kernel@mkarcher.dialup.fu-berlin.de>
Patch		: https://patchwork.kernel.org/patch/499221/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D27472
Subject		: 5bd5a45 breaks resume from suspend on Thinkpad X201
Submitter	: Bj=C3=B6rn Schlie=C3=9Fmann <chronoss@gmx.de>
Date		: 2011-01-23 23:24 (11 days old)
Handled-By	: CASTET Matthieu <castet.matthieu@free.fr>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=3D45192


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions from 2=
=2E6.37,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D27352

Please let the tracking team know if there are any Bugzilla entries tha=
t
should be added to the list in there.

Thanks!

--
To unsubscribe from this list: send the line "unsubscribe linux-acpi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
