From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.36-rc3: Reported regressions from 2.6.35
Date: Mon, 30 Aug 2010 00:24:40 +0200 (CEST)
Message-ID: <4LwrqITm-eJ.A.r8G.eFueMB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: Maciej Rutecki <maciej.rutecki@gmail.com>,
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
  2010-08-30       21       16          15


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17341
Subject		: kdump regression compared to v2.6.35
Submitter	: CAI Qian <caiqian@redhat.com>
Date		: 2010-08-27 12:35 (3 days old)
Message-ID	: <2136707099.1405541282912500148.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
References	: http://marc.info/?l=linux-kernel&m=128291252612135&w=2
Handled-By	: Tejun Heo <tj@kernel.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17331
Subject		: BUG: scheduling while atomic
Submitter	: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Date		: 2010-08-27 7:59 (3 days old)
Message-ID	: <20100827075911.GA5966@swordfish.minsk.epam.com>
References	: http://marc.info/?l=linux-kernel&m=128289602925505&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17321
Subject		: i386 WARNING: at kernel/softirq.c:143 _local_bh_enable_ip+0x2f/0x7e
Submitter	: Arno Schuring <aelschuring@hotmail.com>
Date		: 2010-08-27 20:04 (3 days old)
Message-ID	: <4C781A3A.4010707@hotmail.com>
References	: http://marc.info/?l=linux-kernel&m=128294076822387&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17311
Subject		: 2.6.36-rc2-git4 - INFO: possible circular locking dependency detected
Submitter	: Miles Lane <miles.lane@gmail.com>
Date		: 2010-08-27 1:56 (3 days old)
First-Bad-Commit: http://git.kernel.org/linus/5a652052fedbd7869572c757dd2ffc2ed420c69d
Message-ID	: <AANLkTinHbEW36D5R9NSrGgfbOC0Hri3Tg-fA0iR92Udi@mail.gmail.com>
References	: http://marc.info/?l=linux-kernel&m=128287422106267&w=2
Handled-By	: Johannes Berg <johannes@sipsolutions.net>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17301
Subject		: i915: 2.6.36-rc2 wrong resolution on gdm start
Submitter	: Ivan Bulatovic <combuster@gmx.com>
Date		: 2010-08-24 1:00 (6 days old)
First-Bad-Commit: http://git.kernel.org/linus/9d0498a2bf7455159b317f19531a3e5db2ecc9c4
Message-ID	: <1282611655.2177.19.camel@localhost.localdomain>
References	: http://marc.info/?l=linux-kernel&m=128261168202306&w=2
Handled-By	: Chris Wilson <chris@chris-wilson.co.uk>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17151
Subject		: i915: 2.6.36-rc2 hoses my Intel display
Submitter	: Jonathan Corbet <corbet@lwn.net>
Date		: 2010-08-23 17:01 (7 days old)
First-Bad-Commit: http://git.kernel.org/linus/32aad86fe88e7323d4fc5e9e423abcee0d55a03d
Message-ID	: <20100823110145.08eb72fd@bike.lwn.net>
References	: http://marc.info/?l=linux-kernel&m=128258293327326&w=2
Handled-By	: Chris Wilson <chris@chris-wilson.co.uk>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17131
Subject		: WARN with 3c905 boomerang NIC
Submitter	: Doug Nazar <nazard.lkml@gmail.com>
Date		: 2010-08-22 6:35 (8 days old)
Message-ID	: <4C70C516.5020404@gmail.com>
References	: http://marc.info/?l=linux-kernel&m=128245894300623&w=2
Handled-By	: David Miller <davem@davemloft.net>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17061
Subject		: 2.6.36-rc1 on zaurus: bluetooth regression
Submitter	: Pavel Machek <pavel@ucw.cz>
Date		: 2010-08-21 15:24 (9 days old)
Message-ID	: <20100821152445.GA1536@ucw.cz>
References	: http://marc.info/?l=linux-kernel&m=128240433828087&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17041
Subject		: 2.6.36-rc1 hangs during XFS barrier test for /
Submitter	: Torsten Kaiser <just.for.lkml@googlemail.com>
Date		: 2010-08-20 (10 days old)
Message-ID	: <AANLkTim1PXibiY98GUdMj-UZLTav+n7GAnJ0Mjn6_5a3@mail.gmail.com>
References	: http://marc.info/?l=linux-kernel&m=128231691708710&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17021
Subject		: [REGRESSION] [2.6.36-rc1] [DRM INTEL] [drm:intel_calculate_wm] *ERROR* Insufficient FIFO for plane, expect flickering: entries required = 36, available = 28.
Submitter	: Maciej Rutecki <maciej.rutecki@gmail.com>
Date		: 2010-08-18 18:46 (12 days old)
Message-ID	: <201008182046.37732.maciej.rutecki@gmail.com>
References	: http://marc.info/?l=linux-kernel&m=128215721507666&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16971
Subject		: qla4xxx compile failure on 32-bit PowerPC: missing readq and writeq
Submitter	: Meelis Roos <mroos@linux.ee>
Date		: 2010-08-19 21:03 (11 days old)
Message-ID	: <alpine.SOC.1.00.1008192359310.19654@math.ut.ee>
References	: http://marc.info/?l=linux-kernel&m=128225184900892&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16961
Subject		: kernel BUG at arch/x86/kvm/../../../virt/kvm/kvm_main.c:1978
Submitter	: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Date		: 2010-08-19 9:54 (11 days old)
Message-ID	: <20100819095429.GA5201@swordfish.minsk.epam.com>
References	: http://marc.info/?l=linux-kernel&m=128221169606214&w=2
Handled-By	: Avi Kivity <avi@redhat.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16951
Subject		: hackbench regression with 2.6.36-rc1
Submitter	: Zhang, Yanmin <yanmin_zhang@linux.intel.com>
Date		: 2010-08-18 6:18 (12 days old)
Message-ID	: <1282112318.21202.8.camel@ymzhang.sh.intel.com>
References	: http://marc.info/?l=linux-kernel&m=128211235904910&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16881
Subject		: [REGRESSION, Radeon-KMS] 2.6.36-rc1,2 - missing textures in 0 A.D.
Submitter	:  <trapdoor6@gmail.com>
Date		: 2010-08-24 12:20 (6 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16626
Subject		: Machine hangs with EIP at skb_copy_and_csum_dev
Submitter	: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>
Date		: 2010-08-19 09:57 (11 days old)
Handled-By	:  Eric Dumazet <eric.dumazet@gmail.com>


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16629
Subject		: fix BUG: using smp_processor_id() in preemptible code (resend)
Submitter	: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Date		: 2010-08-18 9:11 (12 days old)
Message-ID	: <20100818091157.GA5238@swordfish.minsk.epam.com>
References	: http://marc.info/?l=linux-kernel&m=128212276618793&w=2
Handled-By	: H. Peter Anvin <hpa@zytor.com>
Patch		: http://marc.info/?l=linux-kernel&m=128212276618793&w=2


For details, please visit the bug entries and follow the links given in
references.

As you can see, there is a Bugzilla entry for each of the listed regressions.
There also is a Bugzilla entry used for tracking the regressions from 2.6.35,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=16444

Please let the tracking team know if there are any Bugzilla entries that
should be added to the list in there.

Thanks!

