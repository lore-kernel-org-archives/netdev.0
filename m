From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.36-rc6-git2: Reported regressions from 2.6.35
Date: Sun,  3 Oct 2010 23:15:32 +0200 (CEST)
Message-ID: <-jYMINoCtaK.A.F5.8CPqMB@chimera>
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
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/linux-pm>
List-Post: <mailto:linux-pm@lists.linux-foundation.org>
List-Help: <mailto:linux-pm-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=subscribe>
Sender: linux-pm-bounces@lists.linux-foundation.org
Errors-To: linux-pm-bounces@lists.linux-foundation.org
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
  2010-10-03       52       16          14
  2010-09-26       46       15          13
  2010-09-20       38       15          15
  2010-09-12       28       14          13
  2010-08-30       21       16          15


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=19642
Subject		: 2.6.36-rc6 BUG at drivers/scsi/scsi_lib.c:1113
Submitter	: George Spelvin <linux@horizon.com>
Date		: 2010-09-30 21:10 (4 days old)
Message-ID	: <20100930211006.27449.qmail@science.horizon.com>
References	: http://marc.info/?l=linux-kernel&m=128588102620299&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=19632
Subject		: 2.6.36-rc6: modprobe Not tainted warning
Submitter	: Heinz Diehl <htd@fritha.org>
Date		: 2010-09-30 18:25 (4 days old)
Message-ID	: <20100930182516.GA15089@fritha.org>
References	: http://marc.info/?l=linux-kernel&m=128587114004680&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=19392
Subject		: WARNING: at drivers/net/wireless/ath/ath5k/base.c:3475 ath5k_bss_info_changed+0x44/0x168 [ath5k]()
Submitter	: Justin Mattock <justinmattock@gmail.com>
Date		: 2010-09-28 22:30 (6 days old)
Message-ID	: <AANLkTim5WCGKPvEkOkO_YnMF9pg8mvLfQoFBNUFpfa_k@mail.gmail.com>
References	: http://marc.info/?l=linux-kernel&m=128571307018635&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=19372
Subject		: 2.6.36-rc6: WARNING: at drivers/gpu/drm/radeon/radeon_fence.c:235 radeon_fence_wait+0x35a/0x3c0
Submitter	: Alexey Dobriyan <adobriyan@gmail.com>
Date		: 2010-09-29 21:29 (5 days old)
Message-ID	: <20100929212923.GA5578@core2.telecom.by>
References	: http://marc.info/?l=linux-kernel&m=128579579400315&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=19142
Subject		: Screen flickers when switching from the console to X
Submitter	: Andrey Rahmatullin <wrar@altlinux.org>
Date		: 2010-09-27 12:05 (7 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=19072
Subject		: [2.6.36-rc regression] occasional complete system hangs on sparc64 SMP
Submitter	: Mikael Pettersson <mikpe@it.uu.se>
Date		: 2010-09-23 17:02 (11 days old)
Message-ID	: <19611.34846.813757.309183@pilspetsen.it.uu.se>
References	: http://marc.info/?l=linux-kernel&m=128526136531048&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=19062
Subject		: Dirtiable inode bdi default != sb bdi btrfs
Submitter	: Cesar Eduardo Barros <cesarb@cesarb.net>
Date		: 2010-09-23 0:54 (11 days old)
Message-ID	: <<4C9AA546.6050201@cesarb.net>>
References	: http://marc.info/?l=linux-kernel&m=128520328929595&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=19052
Subject		: 2.6.36-rc5-git1 -- [drm:i915_report_and_clear_eir] *ERROR* EIR stuck: 0x00000010, masking
Submitter	: Miles Lane <miles.lane@gmail.com>
Date		: 2010-09-22 23:47 (12 days old)
Message-ID	: <AANLkTikWQjUQjFJU9MO1+XbSLAEE-GARz+S+Dz2Fgu4h@mail.gmail.com>
References	: http://marc.info/?l=linux-kernel&m=128519926626322&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=19002
Subject		: Radeon rv730 AGP/KMS/DRM kernel lockup
Submitter	: Duncan <1i5t5.duncan@cox.net>
Date		: 2010-09-23 16:48 (11 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17361
Subject		: Watchdog detected hard LOCKUP in jbd2_journal_get_write_access
Submitter	: Christian Casteyde <casteyde.christian@free.fr>
Date		: 2010-08-29 19:59 (36 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17121
Subject		: Two blank rectangles more than 10 cm long when booting
Submitter	: Eric Valette <eric.valette@free.fr>
Date		: 2010-08-26 17:24 (39 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17061
Subject		: 2.6.36-rc1 on zaurus: bluetooth regression
Submitter	: Pavel Machek <pavel@ucw.cz>
Date		: 2010-08-21 15:24 (44 days old)
Message-ID	: <20100821152445.GA1536@ucw.cz>
References	: http://marc.info/?l=linux-kernel&m=128240433828087&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16971
Subject		: qla4xxx compile failure on 32-bit PowerPC: missing readq and writeq
Submitter	: Meelis Roos <mroos@linux.ee>
Date		: 2010-08-19 21:03 (46 days old)
Message-ID	: <alpine.SOC.1.00.1008192359310.19654@math.ut.ee>
References	: http://marc.info/?l=linux-kernel&m=128225184900892&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16951
Subject		: hackbench regression with 2.6.36-rc1
Submitter	: Zhang, Yanmin <yanmin_zhang@linux.intel.com>
Date		: 2010-08-18 6:18 (47 days old)
Message-ID	: <1282112318.21202.8.camel@ymzhang.sh.intel.com>
References	: http://marc.info/?l=linux-kernel&m=128211235904910&w=2


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=18742
Subject		: PROBLEM: Kernel panic on 2.6.36-rc4 when loading intel_ips on Core i3 laptop
Submitter	: infernix <infernix@infernix.net>
Date		: 2010-09-15 14:35 (19 days old)
Message-ID	: <4C90D998.6050103@infernix.net>
References	: http://marc.info/?l=linux-kernel&m=128456187928496&w=2
Handled-By	: Jesse Barnes <jbarnes@virtuousgeek.org>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=31112


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17722
Subject		: 2.6.36-rc3: WARNING: at net/mac80211/scan.c:269 ieee80211_scan_completed
Submitter	: Thomas Meyer <thomas@m3y3r.de>
Date		: 2010-08-31 20:14 (34 days old)
Message-ID	: <201008312214.52473.thomas@m3y3r.de>
References	: http://marc.info/?l=linux-kernel&m=128328580504227&w=2
		  http://www.spinics.net/lists/netdev/msg140769.html
Handled-By	: Florian Mickler <florian@mickler.org>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=31671


For details, please visit the bug entries and follow the links given in
references.

As you can see, there is a Bugzilla entry for each of the listed regressions.
There also is a Bugzilla entry used for tracking the regressions from 2.6.35,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=16444

Please let the tracking team know if there are any Bugzilla entries that
should be added to the list in there.

Thanks!
