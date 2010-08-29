From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.36-rc3: Reported regressions 2.6.34 -> 2.6.35
Date: Mon, 30 Aug 2010 00:57:37 +0200 (CEST)
Message-ID: <c1_O4wHrlB.A.63.mbueMB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux SCSI List <linux-scsi@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Linux Wireless List <linux-wireless@vger.kernel.org>,
        DRI <dri-devel@lists.freedesktop.org>,
        Linux ACPI <linux-acpi@vger.kernel.org>,
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

This message contains a list of some post-2.6.34 regressions introduced before
2.6.35, for which there are no fixes in the mainline known to the tracking team.
If any of them have been fixed already, please let us know.

If you know of any other unresolved post-2.6.34 regressions, please let us know
either and we'll add them to the list.  Also, please let us know if any
of the entries below are invalid.

Each entry from the list will be sent additionally in an automatic reply to
this message with CCs to the people involved in reporting and handling the
issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2010-08-30      124       38          34
  2010-08-01      100       27          23
  2010-07-23       94       33          25
  2010-07-09       79       45          37
  2010-06-21       46       37          26
  2010-06-09       15       13          10


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17071
Subject		: possible esata regression in 2.6.35
Submitter	: Nicolas Jungers <nicolas@jungers.net>
Date		: 2010-08-21 18:52 (9 days old)
Message-ID	: <4C702070.5020809@jungers.net>
References	: http://marc.info/?l=linux-kernel&m=128241685406276&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16771
Subject		: [Bisected Regression in 2.6.35] A full tmpfs filesystem causes hibernationto hang
Submitter	: M. Vefa Bicakci <bicave@superonline.com>
Date		: 2010-08-15 5:25 (15 days old)
First-Bad-Commit: http://git.kernel.org/linus/bb21c7ce18eff8e6e7877ca1d06c6db719376e3c
Message-ID	: <4C677A49.4030904@superonline.com>
References	: http://marc.info/?l=linux-kernel&m=128184995401968&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16691
Subject		: IPW5100: iwlagn broken with 2.6.34.x to 2.6.35.2 update
Submitter	: Can Celasun <dcelasun@gmail.com>
Date		: 2010-08-21 08:28 (9 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16633
Subject		: ath5k + 2.6.35 x86 + hostapd - Failed to set channel
Submitter	: NiTr0 <nitr0@seti.kr.ua>
Date		: 2010-08-19 19:37 (11 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16620
Subject		: [REGRESSION 2.6.35+] crash (maybe kmemleak related)
Submitter	: Maxim Levitsky <maximlevitsky@gmail.com>
Date		: 2010-08-12 20:37 (18 days old)
Message-ID	: <1281645464.3893.25.camel@maxim-laptop>
References	: http://marc.info/?l=linux-kernel&m=128164549415081&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16614
Subject		: [2.6.35] usb 2.0 em28xx  kernel panic general protection fault: 0000 [#1] SMP          RIP: 0010:[<ffffffffa004fbc5>]  [<ffffffffa004fbc5>] em28xx_isoc_copy_vbi+0x62e/0x812 [em28xx]
Submitter	: Sander Eikelenboom <linux@eikelenboom.it>
Date		: 2010-08-10 22:12 (20 days old)
Message-ID	: <61936849.20100811001257@eikelenboom.it>
References	: http://marc.info/?l=linux-kernel&m=128152075830927&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16613
Subject		: i8042 kernel module failed to load after unloading
Submitter	: Seryodkin Victor <vvscore@gmail.com>
Date		: 2010-08-17 17:01 (13 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16562
Subject		: 2.6.35: cpu_idle bug report / on i7 870 cpu (x86_64)
Submitter	: Justin Piszcz <jpiszcz@lucidpixels.com>
Date		: 2010-08-06 22:09 (24 days old)
Message-ID	: <alpine.DEB.2.00.1008061800530.5241@p34.internal.lan>
References	: http://marc.info/?l=linux-kernel&m=128113260904048&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16549
Subject		: 2.6.35: suspicious rcu_dereference_check() usage
Submitter	: Vladislav Bolkhovitin <vst@vlnb.net>
Date		: 2010-08-04 10:56 (26 days old)
Message-ID	: <4C594740.1090608@vlnb.net>
References	: http://marc.info/?l=linux-kernel&m=128091938215177&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16537
Subject		: TREE_RCU hangs at boot
Submitter	: Rolf Eike Beer <eike-kernel@sf-tec.de>
Date		: 2010-08-07 12:18 (23 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16536
Subject		: audio stop playing after while
Submitter	: okias <d.okias@gmail.com>
Date		: 2010-08-07 11:00 (23 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16525
Subject		: unexpected high load since 2.6.35
Submitter	: MadLoisae@gmx.net <MadLoisae@gmx.net>
Date		: 2010-08-02 20:53 (28 days old)
Message-ID	: <4C573041.1070103@gmx.net>
References	: http://marc.info/?l=linux-kernel&m=128078243726655&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16515
Subject		: Radeon rv280 can't boot on kernel 2.6.35.
Submitter	: Albert Gall <ss3vdr@gmail.com>
Date		: 2010-08-04 16:10 (26 days old)
Handled-By	: Alex Deucher <alexdeucher@gmail.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16506
Subject		: 2.6.35.0 compilation errors and excessive warnings.
Submitter	:  <software+linux-kernel@kd6lvw.ampr.org>
Date		: 2010-08-04 01:06 (26 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16495
Subject		: Kernel 2.6.35 takes almost half an hour to boot
Submitter	: Claudio M. Camacho <claudiomkd@gmail.com>
Date		: 2010-08-02 17:16 (28 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16488
Subject		: [i915] Framebuffer ID error after suspend/hibernate leading to X crash
Submitter	: Milan Bouchet-Valat <nalimilan@club.fr>
Date		: 2010-08-01 08:55 (29 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16462
Subject		: unable to connect to AP on legal channel 13
Submitter	: Daniel J Blueman <daniel.blueman@gmail.com>
Date		: 2010-07-25 17:06 (36 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16458
Subject		: Bluetooth disabled after resume
Submitter	: AttilaN <attila123456@gmail.com>
Date		: 2010-07-25 09:33 (36 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16448
Subject		: 2.6.35-rc5 panic at __br_deliver+0x64/0xe0 with kvm bridge networking
Submitter	: caiqian@redhat.com
Date		: 2010-07-23 3:25 (38 days old)
Message-ID	: <198123598.1050221279855515402.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
References	: http://marc.info/?l=linux-kernel&m=127985553916052&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16423
Subject		: netfilter/iptables stopped logging 2.6.35-rc
Submitter	: auto401300@hushmail.com
Date		: 2010-07-17 10:20 (44 days old)
Message-ID	: <20100717072036.1BBE52804B@smtp.hushmail.com>
References	: http://lkml.indiana.edu/hypermail/linux/kernel/1007.2/00440.html


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16406
Subject		: Badness with the kernel version 2.6.35-rc1-git1 running on P6 box
Submitter	: divya <dipraksh@linux.vnet.ibm.com>
Date		: 2010-07-16 8:50 (45 days old)
Message-ID	: <4C401D56.3070108@linux.vnet.ibm.com>
References	: http://marc.info/?l=linux-kernel&m=127927024906085&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16399
Subject		: perf failed with kernel 2.6.35-rc
Submitter	: Zhang, Yanmin <yanmin_zhang@linux.intel.com>
Date		: 2010-07-13 8:14 (48 days old)
First-Bad-Commit: http://git.kernel.org/linus/1ac62cfff252fb668405ef3398a1fa7f4a0d6d15
Message-ID	: <1279008849.2096.913.camel@ymzhang.sh.intel.com>
References	: http://marc.info/?l=linux-kernel&m=127900880212470&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16396
Subject		: [bisected] resume from suspend freezes system
Submitter	: tomas m <tmezzadra@gmail.com>
Date		: 2010-07-15 02:32 (46 days old)
Handled-By	: Rafael J. Wysocki <rjw@sisk.pl>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16393
Subject		: kernel BUG at fs/block_dev.c:765!
Submitter	: Markus Trippelsdorf <markus@trippelsdorf.de>
Date		: 2010-07-14 13:52 (47 days old)
Message-ID	: <20100714135217.GA1797@arch.tripp.de>
References	: http://marc.info/?l=linux-kernel&m=127911564213748&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16380
Subject		: Loop devices act strangely in 2.6.35
Submitter	: Artem S. Tashkinov <t.artem@mailcity.com>
Date		: 2010-07-13 23:21 (48 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16337
Subject		: general protection fault: 0000 [#1] SMP
Submitter	: Justin P. Mattock <justinmattock@gmail.com>
Date		: 2010-07-03 22:59 (58 days old)
Message-ID	: <<4C2FC0E3.6050101@gmail.com>>
References	: http://marc.info/?l=linux-kernel&m=127819798215589&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16323
Subject		: 2.6.35-rc3-git4 - kernel/sched.c:616 invoked rcu_dereference_check() without protection!
Submitter	: Miles Lane <miles.lane@gmail.com>
Date		: 2010-07-01 12:21 (60 days old)
Message-ID	: <AANLkTini6hz2LFeZi8CMUmY3xw1MU7NxmyesuxZ4oCdo@mail.gmail.com>
References	: http://marc.info/?l=linux-kernel&m=127798693125541&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16322
Subject		: WARNING: at /arch/x86/include/asm/processor.h:1005 read_measured_perf_ctrs+0x5a/0x70()
Submitter	: boris64 <bugzilla.kernel.org@boris64.net>
Date		: 2010-07-01 13:54 (60 days old)
Handled-By	: H. Peter Anvin <hpa@zytor.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16307
Subject		: i915 in kernel 2.6.35-rc3, high number of wakeups
Submitter	: Enrico Bandiello <enban@postal.uv.es>
Date		: 2010-06-26 16:57 (65 days old)
Message-ID	: <<4C26317A.5070309@postal.uv.es>>
References	: http://marc.info/?l=linux-kernel&m=127757403404259&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16265
Subject		: Why is kslowd accumulating so much CPU time?
Submitter	: Theodore Ts'o <tytso@mit.edu>
Date		: 2010-06-09 18:36 (82 days old)
First-Bad-Commit: http://git.kernel.org/linus/fbf81762e385d3d45acad057b654d56972acf58c
Message-ID	: <E1OMQ88-0002a1-Gb@closure.thunk.org>
References	: http://marc.info/?l=linux-kernel&m=127610857819033&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16228
Subject		: BUG/boot failure on Dell Precision T3500 (pci/ahci_stop_engine)
Submitter	: Brian Bloniarz <phunge0@hotmail.com>
Date		: 2010-06-16 17:57 (75 days old)
Handled-By	: Bjorn Helgaas <bjorn.helgaas@hp.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16221
Subject		: 2.6.35-rc2-git5 -- [drm:drm_mode_getfb] *ERROR* invalid framebuffer id
Submitter	: Miles Lane <miles.lane@gmail.com>
Date		: 2010-06-11 20:31 (80 days old)
Message-ID	: <AANLkTim0jVRyqkwlGOcrg_XTvUQwcBYfWJX-aRzkkrLG@mail.gmail.com>
References	: http://marc.info/?l=linux-kernel&m=127628828119623&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16184
Subject		: Container, X86-64, i386, iptables rule
Submitter	: Jean-Marc Pigeon <jmp@safe.ca>
Date		: 2010-06-12 04:17 (79 days old)
Handled-By	: Patrick McHardy <kaber@trash.net>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16173
Subject		: After uncompressing the kernel, at boot time, the server hangs.
Submitter	: David Hill <hilld@binarystorm.net>
Date		: 2010-06-09 23:25 (82 days old)
First-Bad-Commit: http://git.kernel.org/linus/cf7500c0ea133d66f8449d86392d83f840102632
Handled-By	: Eric W. Biederman <ebiederm@xmission.com>


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16505
Subject		: 2.6.34.2 breaks b43
Submitter	: archman <spermmail001@yahoo.com>
Date		: 2010-08-03 23:53 (27 days old)
Handled-By	: Larry Finger <Larry.Finger@lwfinger.net>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=27335


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16405
Subject		: Brightness Adjustment on Toshiba nb305 Netbooks is non-functional.
Submitter	: John Mesmon <jmesmon@gmail.com>
Date		: 2010-07-15 23:40 (46 days old)
First-Bad-Commit: http://git.kernel.org/linus/74a365b3f354fafc537efa5867deb7a9fadbfe27
Handled-By	: Matthew Garrett <mjg59-kernel@srcf.ucam.org>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=27236


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16400
Subject		: 2.6.35-rc5 inconsistent lock state
Submitter	: Martin Pirker <lkml.collector@gmail.com>
Date		: 2010-07-14 20:33 (47 days old)
Message-ID	: <AANLkTikDF0TL6OyPVCzPlUTwxFehcrETn3ysgSSeTq92@mail.gmail.com>
References	: http://marc.info/?l=linux-kernel&m=127913961025267&w=2
Handled-By	: Jens Axboe <axboe@kernel.dk>
Patch		: http://marc.info/?l=linux-kernel&m=127939627513154&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16312
Subject		: WARNING: at fs/fs-writeback.c:1127 __mark_inode_dirty
Submitter	: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date		: 2010-06-28 9:40 (63 days old)
Message-ID	: <AANLkTin24fr5O4_q5Xbo9Y_NKkEmtcp6Hgmr9_4qXaFz@mail.gmail.com>
References	: http://marc.info/?l=linux-kernel&m=127771804806465&w=2
Handled-By	: Jan Kara <jack@suse.cz>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=27272


For details, please visit the bug entries and follow the links given in
references.

As you can see, there is a Bugzilla entry for each of the listed regressions.
There also is a Bugzilla entry used for tracking the regressions introduced
between 2.6.34 and 2.6.35, unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=16055

Please let the tracking team know if there are any Bugzilla entries that
should be added to the list in there.

Thanks!
