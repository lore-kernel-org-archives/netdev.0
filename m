From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.35-rc6-git6: Reported regressions from 2.6.34
Date: Sun,  1 Aug 2010 15:46:42 +0200 (CEST)
Message-ID: <2dWFdr9kTFM.A.P0D.spXVMB@chimera>
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
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This message contains a list of some regressions from 2.6.34,
for which there are no fixes in the mainline known to the tracking team.
If any of them have been fixed already, please let us know.

If you know of any other unresolved regressions from 2.6.34, please let us
know either and we'll add them to the list.  Also, please let us know
if any of the entries below are invalid.

Each entry from the list will be sent additionally in an automatic reply
to this message with CCs to the people involved in reporting and handling
the issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2010-08-01      100       27          23
  2010-07-23       94       33          25
  2010-07-09       79       45          37
  2010-06-21       46       37          26
  2010-06-09       15       13          10


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16462
Subject		: unable to connect to AP on legal channels 12/13
Submitter	: Daniel J Blueman <daniel.blueman@gmail.com>
Date		: 2010-07-25 17:06 (8 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16458
Subject		: Bluetooth disabled after resume
Submitter	: AttilaN <attila123456@gmail.com>
Date		: 2010-07-25 09:33 (8 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16450
Subject		: MTD drivers cannot be unloaded
Submitter	: Ben Hutchings <bhutchings@solarflare.com>
Date		: 2010-07-24 00:17 (9 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16448
Subject		: 2.6.35-rc5 panic at __br_deliver+0x64/0xe0 with kvm bridge networking
Submitter	: caiqian@redhat.com
Date		: 2010-07-23 3:25 (10 days old)
Message-ID	: <198123598.1050221279855515402.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
References	: http://marc.info/?l=linux-kernel&m=127985553916052&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16423
Subject		: netfilter/iptables stopped logging 2.6.35-rc
Submitter	: auto401300@hushmail.com
Date		: 2010-07-17 10:20 (16 days old)
Message-ID	: <20100717072036.1BBE52804B@smtp.hushmail.com>
References	: http://lkml.indiana.edu/hypermail/linux/kernel/1007.2/00440.html


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16406
Subject		: Badness with the kernel version 2.6.35-rc1-git1 running on P6 box
Submitter	: divya <dipraksh@linux.vnet.ibm.com>
Date		: 2010-07-16 8:50 (17 days old)
Message-ID	: <4C401D56.3070108@linux.vnet.ibm.com>
References	: http://marc.info/?l=linux-kernel&m=127927024906085&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16400
Subject		: 2.6.35-rc5 inconsistent lock state
Submitter	: Martin Pirker <lkml.collector@gmail.com>
Date		: 2010-07-14 20:33 (19 days old)
Message-ID	: <AANLkTikDF0TL6OyPVCzPlUTwxFehcrETn3ysgSSeTq92@mail.gmail.com>
References	: http://marc.info/?l=linux-kernel&m=127913961025267&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16399
Subject		: perf failed with kernel 2.6.35-rc
Submitter	: Zhang, Yanmin <yanmin_zhang@linux.intel.com>
Date		: 2010-07-13 8:14 (20 days old)
First-Bad-Commit: http://git.kernel.org/linus/1ac62cfff252fb668405ef3398a1fa7f4a0d6d15
Message-ID	: <1279008849.2096.913.camel@ymzhang.sh.intel.com>
References	: http://marc.info/?l=linux-kernel&m=127900880212470&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16396
Subject		: [bisected] resume from suspend freezes system
Submitter	: tomas m <tmezzadra@gmail.com>
Date		: 2010-07-15 02:32 (18 days old)
Handled-By	: Rafael J. Wysocki <rjw@sisk.pl>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16393
Subject		: kernel BUG at fs/block_dev.c:765!
Submitter	: Markus Trippelsdorf <markus@trippelsdorf.de>
Date		: 2010-07-14 13:52 (19 days old)
Message-ID	: <20100714135217.GA1797@arch.tripp.de>
References	: http://marc.info/?l=linux-kernel&m=127911564213748&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16383
Subject		: Regression with e1000e from 2.6.34.1 to 2.6.35-rc5
Submitter	: Stefan Behte <craig@haquarter.de>
Date		: 2010-07-14 00:44 (19 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16380
Subject		: Loop devices act strangely in 2.6.35
Submitter	: Artem S. Tashkinov <t.artem@mailcity.com>
Date		: 2010-07-13 23:21 (20 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16369
Subject		: Yet another 2.6.35 regression (AGP)?
Submitter	: Woody Suwalski <terraluna977@gmail.com>
Date		: 2010-07-09 14:21 (24 days old)
Message-ID	: <4C373084.8000503@gmail.com>
References	: http://marc.info/?l=linux-kernel&m=127868797119254&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16365
Subject		: kernel BUG at fs/btrfs/extent-tree.c:1353
Submitter	: Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>
Date		: 2010-07-08 14:27 (25 days old)
Message-ID	: <201007081627.24654.johannes.hirte@fem.tu-ilmenau.de>
References	: http://marc.info/?l=linux-kernel&m=127859960725931&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16337
Subject		: general protection fault: 0000 [#1] SMP
Submitter	: Justin P. Mattock <justinmattock@gmail.com>
Date		: 2010-07-03 22:59 (30 days old)
Message-ID	: <4C2FC0E3.6050101@gmail.com>
References	: http://marc.info/?l=linux-kernel&m=127819798215589&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16322
Subject		: WARNING: at /arch/x86/include/asm/processor.h:1005 read_measured_perf_ctrs+0x5a/0x70()
Submitter	: boris64 <bugzilla.kernel.org@boris64.net>
Date		: 2010-07-01 13:54 (32 days old)
Handled-By	: H. Peter Anvin <hpa@zytor.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16307
Subject		: i915 in kernel 2.6.35-rc3, high number of wakeups
Submitter	: Enrico Bandiello <enban@postal.uv.es>
Date		: 2010-06-26 16:57 (37 days old)
Message-ID	: <<4C26317A.5070309@postal.uv.es>>
References	: http://marc.info/?l=linux-kernel&m=127757403404259&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16265
Subject		: Why is kslowd accumulating so much CPU time?
Submitter	: Theodore Ts'o <tytso@mit.edu>
Date		: 2010-06-09 18:36 (54 days old)
First-Bad-Commit: http://git.kernel.org/linus/fbf81762e385d3d45acad057b654d56972acf58c
Message-ID	: <E1OMQ88-0002a1-Gb@closure.thunk.org>
References	: http://marc.info/?l=linux-kernel&m=127610857819033&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16228
Subject		: BUG/boot failure on Dell Precision T3500 (pci/ahci_stop_engine)
Submitter	: Brian Bloniarz <phunge0@hotmail.com>
Date		: 2010-06-16 17:57 (47 days old)
Handled-By	: Bjorn Helgaas <bjorn.helgaas@hp.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16221
Subject		: 2.6.35-rc2-git5 -- [drm:drm_mode_getfb] *ERROR* invalid framebuffer id
Submitter	: Miles Lane <miles.lane@gmail.com>
Date		: 2010-06-11 20:31 (52 days old)
Message-ID	: <AANLkTim0jVRyqkwlGOcrg_XTvUQwcBYfWJX-aRzkkrLG@mail.gmail.com>
References	: http://marc.info/?l=linux-kernel&m=127628828119623&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16215
Subject		: sysfs: cannot create duplicate filename '/class/net/bnep0'
Submitter	: Janusz Krzysztofik <jkrzyszt@tis.icnet.pl>
Date		: 2010-06-15 14:55 (48 days old)
Handled-By	: Eric W. Biederman <ebiederm@xmission.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16184
Subject		: Container, X86-64, i386, iptables rule
Submitter	: Jean-Marc Pigeon <jmp@safe.ca>
Date		: 2010-06-12 04:17 (51 days old)
Handled-By	: Patrick McHardy <kaber@trash.net>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16173
Subject		: After uncompressing the kernel, at boot time, the server hangs.
Submitter	: David Hill <hilld@binarystorm.net>
Date		: 2010-06-09 23:25 (54 days old)
First-Bad-Commit: http://git.kernel.org/linus/cf7500c0ea133d66f8449d86392d83f840102632
Handled-By	: Eric W. Biederman <ebiederm@xmission.com>


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16405
Subject		: Brightness Adjustment on Toshiba nb305 Netbooks is non-functional.
Submitter	: John Mesmon <jmesmon@gmail.com>
Date		: 2010-07-15 23:40 (18 days old)
First-Bad-Commit: http://git.kernel.org/linus/74a365b3f354fafc537efa5867deb7a9fadbfe27
Handled-By	: Matthew Garrett <mjg59-kernel@srcf.ucam.org>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=27236


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16312
Subject		: WARNING: at fs/fs-writeback.c:1127 __mark_inode_dirty
Submitter	: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date		: 2010-06-28 9:40 (35 days old)
Message-ID	: <AANLkTin24fr5O4_q5Xbo9Y_NKkEmtcp6Hgmr9_4qXaFz@mail.gmail.com>
References	: http://marc.info/?l=linux-kernel&m=127771804806465&w=2
Handled-By	: Jan Kara <jack@suse.cz>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=27272


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16310
Subject		: arm omap invalid module format
Submitter	: Robert Nelson <robertcnelson@gmail.com>
Date		: 2010-06-28 17:30 (35 days old)
First-Bad-Commit: http://git.kernel.org/linus/d0679c730395d0bde9a46939e7ba255b4ba7dd7c
Handled-By	: Michal Marek <mmarek@suse.cz>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=26999


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16278
Subject		: lvm snapshot causes deadlock in 2.6.35
Submitter	: Phillip Susi <psusi@cfl.rr.com>
Date		: 2010-06-23 16:55 (40 days old)
Handled-By	: Eric Sandeen <sandeen@redhat.com>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=26933


For details, please visit the bug entries and follow the links given in
references.

As you can see, there is a Bugzilla entry for each of the listed regressions.
There also is a Bugzilla entry used for tracking the regressions from 2.6.34,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=16055

Please let the tracking team know if there are any Bugzilla entries that
should be added to the list in there.

Thanks!

