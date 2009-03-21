From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.29-rc8-git5: Reported regressions from 2.6.28
Date: Sat, 21 Mar 2009 17:28:37 +0100 (CET)
Message-ID: <GPBuLTara4J.A.3kH.TZTxJB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Natalie Protasevich <protasnb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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
  2009-03-21      128       29          26
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

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12910
Subject		: Wierd iteractions with CPUFREQ
Submitter	: Dmitry Torokhov <dmitry.torokhov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-03-19 5:57 (3 days old)
References	: http://marc.info/?l=linux-kernel&m=123744265002098&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12909
Subject		: boot/kernel init duration regression from 2.6.28
Submitter	: CaT <cat-LJ1TwQYPT6cQrrorzV6ljw@public.gmane.org>
Date		: 2009-03-16 10:25 (6 days old)
References	: http://marc.info/?l=linux-kernel&m=123720083515950&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12908
Subject		: acpi_ex_extract_from_field -- div by zero
Submitter	: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-03-15 10:47 (7 days old)
References	: http://marc.info/?l=linux-kernel&m=123711408225013&w=4
Handled-By	: Lin Ming <ming.m.lin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12872
Subject		: pwc mmap always fails with EAGAIN
Submitter	: Markus <M4rkusXXL-S0/GAf8tV78@public.gmane.org>
Date		: 2009-03-14 16:42 (8 days old)
References	: http://marc.info/?l=linux-kernel&m=123704902201378&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12871
Subject		: usb bluetooth crashes system
Submitter	: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Date		: 2009-03-10 11:23 (12 days old)
References	: http://marc.info/?l=linux-kernel&m=123668450400940&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12867
Subject		: 2.6.29-rc7 broke r8169 MAC on Thecus n2100 ARM board
Submitter	: Mikael Pettersson <mikpe-1zs4UD6AkMk@public.gmane.org>
Date		: 2009-03-09 20:29 (13 days old)
References	: http://marc.info/?l=linux-kernel&m=123663065403760&w=4
Handled-By	: Francois Romieu <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12861
Subject		: Xorg fails to start "Failed to allocate space for kernel memory manager"
Submitter	: Emil Karlson <jkarlson-kf+aQKke1yb1KXRcyAk9cg@public.gmane.org>
Date		: 2009-03-12 12:06 (10 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12856
Subject		: Thinkpad freezes with X.org and acpi=rsdt
Submitter	: Maciej Piechotka <uzytkownik2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-03-11 16:46 (11 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12846
Subject		: Regression issue with kernel 2.6.29-rc6-git1: high power consumption during sleep
Submitter	: Raymond Wooninck <tittiatcoke-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-03-09 08:18 (13 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=1fb25cb8b83e85f5bf1a4adb3c9a254c4ce92405


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12836
Subject		: 2.6.29-rc breaks STD using Intel 945
Submitter	: Rolf Eike Beer <eike-kernel-F+mm6HnICJmzQB+pC5nmwQ@public.gmane.org>
Date		: 2009-03-04 19:20 (18 days old)
References	: http://marc.info/?l=linux-kernel&m=123619451406192&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12809
Subject		: iozone regression with 2.6.29-rc6
Submitter	: Lin Ming <ming.m.lin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date		: 2009-02-27 9:13 (23 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=1cf6e7d83bf334cc5916137862c920a97aabc018
References	: http://marc.info/?l=linux-kernel&m=123572630504360&w=4
		  http://lkml.org/lkml/2009/3/14/265
Handled-By	: Wu Fengguang <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12808
Subject		: Suspend regression with 2.6.29-rc
Submitter	: Tino Keitel <tino.keitel-Mmb7MZpHnFY@public.gmane.org>
Date		: 2009-02-24 19:08 (26 days old)
References	: http://marc.info/?l=linux-kernel&m=123550257312112&w=4
Handled-By	: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12800
Subject		: x86 PAT invalid vm_insert_pfn assumptions
Submitter	: Thomas Hellstrom <thellstrom-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>
Date		: 2009-03-02 01:40 (20 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12792
Subject		: 2.6.29-rc6-git4 boot failure
Submitter	: Sachin P. Sant <sachinp-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
Date		: 2009-02-27 23:19 (23 days old)
References	: http://ozlabs.org/pipermail/linuxppc-dev/2009-February/068771.html


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12778
Subject		: suspend regression from 29rc5 to 29rc6
Submitter	: yury <urykhy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-02-25 09:25 (25 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12771
Subject		: Oops in i915_gem_flush
Submitter	: Kalev Lember <kalev-KfhB8dnw0QSuvFJfX82//w@public.gmane.org>
Date		: 2009-02-24 08:35 (26 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12765
Subject		: i915 VT switch with AIGLX causes X lock up
Submitter	: Sitsofe Wheeler <sitsofe-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
Date		: 2009-02-21 15:38 (29 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=14d200c5e5bd19219d930bbb9a5a22758c8f5bec
References	: http://marc.info/?l=linux-kernel&m=123523074304955&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12763
Subject		: Different cpu MHz values for processor0 and processor1
Submitter	: Matthew A. Bockol <mbockol-dmoCqaWXHRX2fBVCVOL8/A@public.gmane.org>
Date		: 2009-02-21 5:42 (29 days old)
References	: http://marc.info/?l=linux-kernel&m=123519687807246&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12705
Subject		: X200: Brightness broken since 2.6.29-rc4-58-g4c098bc
Submitter	: Nico Schottelius <nico-linux-20090213-xuaVFQXs+5hIG4jRRZ66WA@public.gmane.org>
Date		: 2009-02-13 9:33 (37 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=e806b4957412bf472d826bd8cc571da041248799
References	: http://marc.info/?l=linux-kernel&m=123451768406825&w=4
		  http://marc.info/?l=linux-kernel&m=123479975503827&w=2
Handled-By	: Len Brown <lenb-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12681
Subject		: s2ram: fails to wake up on Acer Extensa 4220 (SMP disabled)
Submitter	: Orivej Desh <smpuj-5URONGGNgjI@public.gmane.org>
Date		: 2009-02-09 13:01 (41 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=1cfe62c8010ac56e1bd3827e30386a87cc2f3594


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12670
Subject		: BUG: unable to handle kernel paging request at pin_to_kill+0x21
Submitter	: Alessandro Bono <alessandro.bono-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-02-08 11:04 (42 days old)
References	: http://marc.info/?l=linux-kernel&m=123409113223833&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12668
Subject		: USB flash disk surprise disconnect
Submitter	: Vegard Nossum <vegard.nossum-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-02-08 10:21 (42 days old)
References	: http://marc.info/?l=linux-kernel&m=123408851821292&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12574
Subject		: possible circular locking dependency detected
Submitter	: Michael S. Tsirkin <m.s.tsirkin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-01-29 11:35 (52 days old)
References	: http://lkml.org/lkml/2009/2/9/205


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12499
Subject		: Problem with using bluetooth adaper connected to usb port
Submitter	: Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-01-13 18:34 (68 days old)
References	: http://marc.info/?l=linux-kernel&m=123187185426236&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12490
Subject		: ath5k related kernel panic in 2.6.29-rc1
Submitter	: Sergey S. Kostyliov <rathamahata-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-01-12 7:38 (69 days old)
References	: http://marc.info/?l=linux-kernel&m=123174591509586&w=4
Handled-By	: Bob Copeland <me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12419
Subject		: possible circular locking dependency on i915 dma
Submitter	: Wang Chen <wangchen-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Date		: 2009-01-08 14:11 (73 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=546b0974c39657017407c86fe79811100b60700d
References	: http://marc.info/?l=linux-kernel&m=123142399720125&w=4


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12870
Subject		: 2.6.29-rc "TKIP: replay detected" regression
Submitter	: Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>
Date		: 2009-03-11 12:07 (11 days old)
References	: http://marc.info/?l=linux-kernel&m=123677337219148&w=4
Handled-By	: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Patch		: http://marc.info/?l=linux-wireless&m=123678463704691&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12671
Subject		: uvc_status_cleanup(): undefined reference to `input_unregister_device'
Submitter	: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Date		: 2009-02-08 14:58 (42 days old)
References	: http://marc.info/?l=linux-kernel&m=123410529909318&w=4
Handled-By	: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Patch		: http://lkml.org/lkml/2009/2/15/172


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12667
Subject		: Badness at kernel/time/timekeeping.c:98 in pmud (timekeeping_suspended)
Submitter	: Paul Collins <paul-dsjeNyW6Qm/D+ROgJ3VA+kB+6BGkLq7r@public.gmane.org>
Date		: 2009-01-21 7:15 (60 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=1c5745aa380efb6417b5681104b007c8612fb496
References	: http://marc.info/?l=linux-kernel&m=123252215315106&w=4
Handled-By	: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
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
