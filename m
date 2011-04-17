From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.39-rc3-git7: Reported regressions from 2.6.38
Date: Sun, 17 Apr 2011 14:52:34 +0200 (CEST)
Message-ID: <OlQwC5HnRsN.A.ULB.OGuqNB@chimera>
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
  2011-04-17       17       11          10


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=33342
Subject		: [2.6.39-rc2][bisected] Constant DISK_MEDIA_CHANGE_EVENTS from CDROM drive.
Submitter	: Shaun Ruffell <sruffell@digium.com>
Date		: 2011-04-08 20:15 (10 days old)
Message-ID	: <20110408201513.GA3040@digium.com>
References	: http://marc.info/?l=linux-kernel&m=130229371907209&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=33272
Subject		: drm related hard-hang
Submitter	: Peter Teoh <htmldeveloper@gmail.com>
Date		: 2011-04-14 01:29 (4 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=33242
Subject		: Lockdep splat in autofs with 2.6.39-rc2
Submitter	: Nick Bowler <nbowler@elliptictech.com>
Date		: 2011-04-07 19:44 (11 days old)
Message-ID	: <20110407194403.GA29404@elliptictech.com>
References	: http://marc.info/?l=linux-kernel&m=130220545614682&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=33142
Subject		: 2.6.39-rc2 regression: X201s fails to resume b77dcf8460ae57d4eb9fd3633eb4f97b8fb20716
Submitter	: Keith Packard <keithp@keithp.com>
Date		: 2011-04-06 7:44 (12 days old)
Message-ID	: <yun1v1fj024.fsf@aiko.keithp.com>
References	: http://marc.info/?l=linux-kernel&m=130207593728273&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=33102
Subject		: File's copied from client->linux server only copy 1st 64K data;rest is lost
Submitter	: Linda Walsh <lkml@tlinx.org>
Date		: 2011-04-11 22:12 (7 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=33092
Subject		: [regression] 2.6.39-rc1 - Beagleboard usbnet broken
Submitter	: Mark Jackson <mpfj-list@mimc.co.uk>
Date		: 2011-04-04 9:22 (14 days old)
First-Bad-Commit: http://git.kernel.org/linus/087809fce28f50098d9c3ef1a6865c722f23afd2
Message-ID	: <4D998DC9.3040109@mimc.co.uk>
References	: http://marc.info/?l=linux-kernel&m=130191386508831&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=32982
Subject		: Kernel locks up a few minutes after boot
Submitter	: Bart Van Assche <bart.vanassche@gmail.com>
Date		: 2011-04-10 19:55 (8 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=32902
Subject		: 2.6.39-rc1 doesn't boot on thinkpad t61p x86_64
Submitter	: Alex Romosan <romosan@sycorax.lbl.gov>
Date		: 2011-04-03 19:41 (15 days old)
Message-ID	: <87k4fbnmw8.fsf@sycorax.lbl.gov>
References	: http://marc.info/?l=linux-kernel&m=130186054431678&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=32892
Subject		: 2.6.39-rc1 data corruption with rtorrent
Submitter	: Jindrich Makovicka <makovick@gmail.com>
Date		: 2011-04-02 20:21 (16 days old)
Message-ID	: <20110402222118.3b5c2fa8@holly>
References	: http://marc.info/?l=linux-kernel&m=130177570309226&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=32262
Subject		: 2.6.38-git15+  IDE hangs boot
Submitter	: Pete Clements <clem@clem.clem-digital.net>
Date		: 2011-03-25 15:38 (24 days old)
Message-ID	: <201103251538.p2PFc11i001674@clem.clem-digital.net>
References	: http://marc.info/?l=linux-kernel&m=130106749313695&w=2


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=33252
Subject		: [regression 2.6.39-rc2][bisected] "perf, x86: P4 PMU - Read proper MSR register to catch" and NMIs
Submitter	: Shaun Ruffell <sruffell@digium.com>
Date		: 2011-04-06 22:30 (12 days old)
First-Bad-Commit: http://git.kernel.org/linus/242214f9c1eeaae40eca11e3b4d37bfce960a7cd
Message-ID	: <20110406223036.GA15721@digium.com>
References	: http://marc.info/?l=linux-kernel&m=130212907032580&w=2
Handled-By	: Don Zickus <dzickus@redhat.com>
Patch		: http://cache.gmane.org//gmane/linux/kernel/1125621-001.bin


For details, please visit the bug entries and follow the links given in
references.

As you can see, there is a Bugzilla entry for each of the listed regressions.
There also is a Bugzilla entry used for tracking the regressions from 2.6.38,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=32012

Please let the tracking team know if there are any Bugzilla entries that
should be added to the list in there.

Thanks!

