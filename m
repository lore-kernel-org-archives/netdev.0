From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.29-rc8: Reported regressions from 2.6.28
Date: Sat, 14 Mar 2009 20:01:15 +0100 (CET)
Message-ID: <MiincthRUSI.A.eKC.F4BvJB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This message contains a list of some regressions from 2.6.28, for which there
are no fixes in the mainline I know of.  If any of them have been fixed already,
please let me know.

If you know of any other unresolved regressions from 2.6.28, please let me know
either and I'll add them to the list.  Also, please let me know if any of the
entries below are invalid.

Each entry from the list will be sent additionally in an automatic reply to
this message with CCs to the people involved in reporting and handling the
issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2009-03-14      124       36          32
  2009-03-03      108       33          28
  2009-02-24       95       32          24
  2009-02-14       85       33          27
  2009-02-08       82       45          36
  2009-02-04       66       51          39
  2009-01-20       38       35          27
  2009-01-11       13       13          10


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12872
Subject		: pwc mmap always fails with EAGAIN
Submitter	: Markus <M4rkusXXL@web.de>
Date		: 2009-03-14 16:42 (1 days old)
References	: http://marc.info/?l=linux-kernel&m=123704902201378&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12871
Subject		: usb bluetooth crashes system
Submitter	: Pavel Machek <pavel@ucw.cz>
Date		: 2009-03-10 11:23 (5 days old)
References	: http://marc.info/?l=linux-kernel&m=123668450400940&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12870
Subject		: 2.6.29-rc "TKIP: replay detected" regression
Submitter	: Hugh Dickins <hugh@veritas.com>
Date		: 2009-03-11 12:07 (4 days old)
References	: http://marc.info/?l=linux-kernel&m=123677337219148&w=4
Handled-By	: John W. Linville <linville@tuxdriver.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12867
Subject		: 2.6.29-rc7 broke r8169 MAC on Thecus n2100 ARM board
Submitter	: Mikael Pettersson <mikpe@it.uu.se>
Date		: 2009-03-09 20:29 (6 days old)
References	: http://marc.info/?l=linux-kernel&m=123663065403760&w=4
Handled-By	: Francois Romieu <romieu@fr.zoreil.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12861
Subject		: Xorg fails to start "Failed to allocate space for kernel memory manager"
Submitter	: Emil Karlson <jkarlson@cc.hut.fi>
Date		: 2009-03-12 12:06 (3 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12856
Subject		: Thinkpad freezes with X.org and acpi=rsdt
Submitter	: Maciej Piechotka <uzytkownik2@gmail.com>
Date		: 2009-03-11 16:46 (4 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12846
Subject		: Regression issue with kernel 2.6.29-rc6-git1: high power consumption during sleep
Submitter	: Raymond Wooninck <tittiatcoke@gmail.com>
Date		: 2009-03-09 08:18 (6 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12842
Subject		: CCMP: replay detected
Submitter	: Peter Teoh <htmldeveloper@gmail.com>
Date		: 2009-03-08 07:42 (7 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12836
Subject		: 2.6.29-rc breaks STD using Intel 945
Submitter	: Rolf Eike Beer <eike-kernel@sf-tec.de>
Date		: 2009-03-04 19:20 (11 days old)
References	: http://marc.info/?l=linux-kernel&m=123619451406192&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12831
Subject		: Hot/Fn Keys do not work EEEPC 1000HE (eeepc_laptop)
Submitter	: Matthew <pyther@pyther.net>
Date		: 2009-03-07 10:05 (8 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12809
Subject		: iozone regression with 2.6.29-rc6
Submitter	: Lin Ming <ming.m.lin@intel.com>
Date		: 2009-02-27 9:13 (16 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=1cf6e7d83bf334cc5916137862c920a97aabc018
References	: http://marc.info/?l=linux-kernel&m=123572630504360&w=4
Handled-By	: Wu Fengguang <fengguang.wu@intel.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12808
Subject		: Suspend regression with 2.6.29-rc
Submitter	: Tino Keitel <tino.keitel@gmx.de>
Date		: 2009-02-24 19:08 (19 days old)
References	: http://marc.info/?l=linux-kernel&m=123550257312112&w=4
Handled-By	: Rafael J. Wysocki <rjw@sisk.pl>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12806
Subject		: i915 broken STR
Submitter	: Harvey Harrison <harvey.harrison@gmail.com>
Date		: 2009-02-28 4:20 (15 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=5669fcacc58bf3a7386057addffd280d75380858
References	: http://marc.info/?l=linux-kernel&m=123579487801064&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12805
Subject		: QinQ vlan trunking regression
Submitter	: Bart Trojanowski <bart@jukie.net>
Date		: 2009-02-28 18:05 (15 days old)
References	: http://marc.info/?l=linux-kernel&m=123584439115868&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12800
Subject		: x86 PAT invalid vm_insert_pfn assumptions
Submitter	: Thomas Hellstrom <thellstrom@vmware.com>
Date		: 2009-03-02 01:40 (13 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12792
Subject		: 2.6.29-rc6-git4 boot failure
Submitter	: Sachin P. Sant <sachinp@in.ibm.com>
Date		: 2009-02-27 23:19 (16 days old)
References	: http://ozlabs.org/pipermail/linuxppc-dev/2009-February/068771.html


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12778
Subject		: suspend regression from 29rc5 to 29rc6
Submitter	: yury <urykhy@gmail.com>
Date		: 2009-02-25 09:25 (18 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12771
Subject		: Oops in i915_gem_flush
Submitter	: Kalev Lember <kalev@colleduc.ee>
Date		: 2009-02-24 08:35 (19 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12765
Subject		: i915 VT switch with AIGLX causes X lock up
Submitter	: Sitsofe Wheeler <sitsofe@yahoo.com>
Date		: 2009-02-21 15:38 (22 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=14d200c5e5bd19219d930bbb9a5a22758c8f5bec
References	: http://marc.info/?l=linux-kernel&m=123523074304955&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12763
Subject		: Different cpu MHz values for processor0 and processor1
Submitter	: Matthew A. Bockol <mbockol@carleton.edu>
Date		: 2009-02-21 5:42 (22 days old)
References	: http://marc.info/?l=linux-kernel&m=123519687807246&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12705
Subject		: X200: Brightness broken since 2.6.29-rc4-58-g4c098bc
Submitter	: Nico Schottelius <nico-linux-20090213@schottelius.org>
Date		: 2009-02-13 9:33 (30 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=e806b4957412bf472d826bd8cc571da041248799
References	: http://marc.info/?l=linux-kernel&m=123451768406825&w=4
		  http://marc.info/?l=linux-kernel&m=123479975503827&w=2
Handled-By	: Len Brown <lenb@kernel.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12681
Subject		: s2ram: fails to wake up on Acer Extensa 4220 (SMP disabled)
Submitter	: Orivej Desh <smpuj@bk.ru>
Date		: 2009-02-09 13:01 (34 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=1cfe62c8010ac56e1bd3827e30386a87cc2f3594


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12680
Subject		: Entropy pool problem
Submitter	: Valentin QUEQUET <v.quequet-techniques@orange.fr>
Date		: 2009-02-09 09:12 (34 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12670
Subject		: BUG: unable to handle kernel paging request at pin_to_kill+0x21
Submitter	: Alessandro Bono <alessandro.bono@gmail.com>
Date		: 2009-02-08 11:04 (35 days old)
References	: http://marc.info/?l=linux-kernel&m=123409113223833&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12668
Subject		: USB flash disk surprise disconnect
Submitter	: Vegard Nossum <vegard.nossum@gmail.com>
Date		: 2009-02-08 10:21 (35 days old)
References	: http://marc.info/?l=linux-kernel&m=123408851821292&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12574
Subject		: possible circular locking dependency detected
Submitter	: Michael S. Tsirkin <m.s.tsirkin@gmail.com>
Date		: 2009-01-29 11:35 (45 days old)
References	: http://lkml.org/lkml/2009/2/9/205


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12499
Subject		: Problem with using bluetooth adaper connected to usb port
Submitter	: Maciej Rutecki <maciej.rutecki@gmail.com>
Date		: 2009-01-13 18:34 (61 days old)
References	: http://marc.info/?l=linux-kernel&m=123187185426236&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12490
Subject		: ath5k related kernel panic in 2.6.29-rc1
Submitter	: Sergey S. Kostyliov <rathamahata@gmail.com>
Date		: 2009-01-12 7:38 (62 days old)
References	: http://marc.info/?l=linux-kernel&m=123174591509586&w=4
Handled-By	: Bob Copeland <me@bobcopeland.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12444
Subject		: X hangs following switch from radeonfb console - Bisected
Submitter	: Graham Murray <graham@gmurray.org.uk>
Date		: 2009-01-13 14:03 (61 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=7c1c2871a6a3a114853ec6836e9035ac1c0c7f7a


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12419
Subject		: possible circular locking dependency on i915 dma
Submitter	: Wang Chen <wangchen@cn.fujitsu.com>
Date		: 2009-01-08 14:11 (66 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=546b0974c39657017407c86fe79811100b60700d
References	: http://marc.info/?l=linux-kernel&m=123142399720125&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12418
Subject		: Repeated ioctl(4, 0x40046445, ..) loop in glxgears
Submitter	: Pallipadi, Venkatesh <venkatesh.pallipadi@intel.com>
Date		: 2009-01-07 22:43 (67 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=7c1c2871a6a3a114853ec6836e9035ac1c0c7f7a
References	: http://marc.info/?l=linux-kernel&m=123136836213319&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12414
Subject		: iwl4965 cannot use "ap auto" on latest 2.6.28/29?
Submitter	: Jeff Chua <jeff.chua.linux@gmail.com>
Date		: 2009-01-05 4:13 (69 days old)
References	: http://marc.info/?l=linux-kernel&m=123112882127823&w=4


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12869
Subject		: BUG when disabled ipv6 module is unloaded
Submitter	: Thomas Backlund <tmb@mandriva.org>
Date		: 2009-03-10 20:15 (5 days old)
References	: http://marc.info/?l=linux-kernel&m=123671614621097&w=4
Handled-By	: John Dykstra <john.dykstra1@gmail.com>
Patch		: http://marc.info/?l=linux-kernel&m=123672746905127&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12758
Subject		: ACPI exception with 2.6.29-rc6
Submitter	: Heinz Diehl <htd@fancy-poultry.org>
Date		: 2009-02-23 16:46 (20 days old)
References	: http://marc.info/?l=linux-kernel&m=123540758700861&w=4
Handled-By	: Len Brown <lenb@kernel.org>
Patch		: http://bugzilla.kernel.org/attachment.cgi?id=20368&action=view


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12671
Subject		: uvc_status_cleanup(): undefined reference to `input_unregister_device'
Submitter	: Ingo Molnar <mingo@elte.hu>
Date		: 2009-02-08 14:58 (35 days old)
References	: http://marc.info/?l=linux-kernel&m=123410529909318&w=4
Handled-By	: Randy Dunlap <randy.dunlap@oracle.com>
Patch		: http://lkml.org/lkml/2009/2/15/172


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12667
Subject		: Badness at kernel/time/timekeeping.c:98 in pmud (timekeeping_suspended)
Submitter	: Paul Collins <paul@burly.ondioline.org>
Date		: 2009-01-21 7:15 (53 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=1c5745aa380efb6417b5681104b007c8612fb496
References	: http://marc.info/?l=linux-kernel&m=123252215315106&w=4
Handled-By	: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Patch		: http://lkml.org/lkml/2009/2/16/78


For details, please visit the bug entries and follow the links given in
references.

As you can see, there is a Bugzilla entry for each of the listed regressions.
There also is a Bugzilla entry used for tracking the regressions from 2.6.28,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=12398

Please let me know if there are any Bugzilla entries that should be added to
the list in there.

Thanks,
Rafael

