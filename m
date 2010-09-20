From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.36-rc4-git5: Reported regressions from 2.6.35
Date: Mon, 20 Sep 2010 20:47:53 +0200 (CEST)
Message-ID: <1fwtoy8sG5H.A.veG.9D7lMB@chimera>
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
  2010-09-20       38       15          15
  2010-09-12       28       14          13
  2010-08-30       21       16          15


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=18872
Subject		: Radeon KMS r100 and STR problems
Submitter	: Richard Mittendorfer <delist@gmx.net>
Date		: 2010-09-17 18:26 (4 days old)
Message-ID	: <20100917202647.aa4b6300.delist@gmx.net>
References	: http://marc.info/?l=linux-kernel&m=128474802809779&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=18862
Subject		: [BUG]Kernel 2.6.36rc4 crash when rmmod pm8001
Submitter	: Jack Wang <jack_wang@usish.com>
Date		: 2010-09-17 10:11 (4 days old)
Message-ID	: <3219F4D1734640238A632382C50F633E@usish.com.cn>
References	: http://marc.info/?l=linux-kernel&m=128471846828998&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=18742
Subject		: PROBLEM: Kernel panic on 2.6.36-rc4 when loading intel_ips on Core i3 laptop
Submitter	: infernix <infernix@infernix.net>
Date		: 2010-09-15 14:35 (6 days old)
Message-ID	: <4C90D998.6050103@infernix.net>
References	: http://marc.info/?l=linux-kernel&m=128456187928496&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=18692
Subject		: 2.6.36-rc4/iwl: warning triggered in net/mac80211/scan.c:266
Submitter	: Michael S. Tsirkin <mst@redhat.com>
Date		: 2010-09-14 14:28 (7 days old)
Message-ID	: <20100914142814.GA8744@redhat.com>
References	: http://marc.info/?l=linux-kernel&m=128447487918792&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=18432
Subject		: radeon kms freezes on boot with video= option
Submitter	: Jose Marino <braket@hotmail.com>
Date		: 2010-09-13 22:28 (8 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=18402
Subject		: 2.6.36-rc4 KPs whenever booting on a Pentium 4 HT system
Submitter	: Michael Marley <michael@michaelmarley.com>
Date		: 2010-09-13 15:07 (8 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=18342
Subject		: [regression] i915 incorrectly detects bogus LVDS connection instead of LVDS1
Submitter	: Woody Suwalski <terraluna977@gmail.com>
Date		: 2010-09-08 15:10 (13 days old)
Message-ID	: <AANLkTim2mrVRCKg-2couMTFV7krHQp0+2e_cbaiT_KYW@mail.gmail.com>
References	: http://marc.info/?l=linux-kernel&m=128395866331382&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=18332
Subject		: [regression] *ERROR* timed out waiting for FORCE_DETECT in 36rc3 on i915
Submitter	: Andi Kleen <andi@firstfloor.org>
Date		: 2010-09-08 13:53 (13 days old)
Message-ID	: <87mxrswddf.fsf@basil.nowhere.org>
References	: http://marc.info/?l=linux-kernel&m=128395400624946&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17752
Subject		: 2.6.36-rc3: inconsistent lock state (iprune_sem, shrink_icache_memory)
Submitter	: Stefan Richter <stefanr@s5r6.in-berlin.de>
Date		: 2010-09-01 6:37 (20 days old)
Message-ID	: <tkrat.ed8eda6bc8ffe64e@s5r6.in-berlin.de>
References	: http://marc.info/?l=linux-kernel&m=128332308528119&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17722
Subject		: 2.6.36-rc3: WARNING: at net/mac80211/scan.c:269 ieee80211_scan_completed
Submitter	: Thomas Meyer <thomas@m3y3r.de>
Date		: 2010-08-31 20:14 (21 days old)
Message-ID	: <201008312214.52473.thomas@m3y3r.de>
References	: http://marc.info/?l=linux-kernel&m=128328580504227&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17361
Subject		: Watchdog detected hard LOCKUP in jbd2_journal_get_write_access
Submitter	: Christian Casteyde <casteyde.christian@free.fr>
Date		: 2010-08-29 19:59 (23 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17341
Subject		: kdump regression compared to v2.6.35
Submitter	: CAI Qian <caiqian@redhat.com>
Date		: 2010-08-27 12:35 (25 days old)
Message-ID	: <2136707099.1405541282912500148.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
References	: http://marc.info/?l=linux-kernel&m=128291252612135&w=2
Handled-By	: Tejun Heo <tj@kernel.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17061
Subject		: 2.6.36-rc1 on zaurus: bluetooth regression
Submitter	: Pavel Machek <pavel@ucw.cz>
Date		: 2010-08-21 15:24 (31 days old)
Message-ID	: <20100821152445.GA1536@ucw.cz>
References	: http://marc.info/?l=linux-kernel&m=128240433828087&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16971
Subject		: qla4xxx compile failure on 32-bit PowerPC: missing readq and writeq
Submitter	: Meelis Roos <mroos@linux.ee>
Date		: 2010-08-19 21:03 (33 days old)
Message-ID	: <alpine.SOC.1.00.1008192359310.19654@math.ut.ee>
References	: http://marc.info/?l=linux-kernel&m=128225184900892&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16951
Subject		: hackbench regression with 2.6.36-rc1
Submitter	: Zhang, Yanmin <yanmin_zhang@linux.intel.com>
Date		: 2010-08-18 6:18 (34 days old)
Message-ID	: <1282112318.21202.8.camel@ymzhang.sh.intel.com>
References	: http://marc.info/?l=linux-kernel&m=128211235904910&w=2


For details, please visit the bug entries and follow the links given in
references.

As you can see, there is a Bugzilla entry for each of the listed regressions.
There also is a Bugzilla entry used for tracking the regressions from 2.6.35,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=16444

Please let the tracking team know if there are any Bugzilla entries that
should be added to the list in there.

Thanks!

