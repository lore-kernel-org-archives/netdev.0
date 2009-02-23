From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.29-rc6: Reported regressions from 2.6.28
Date: Mon, 23 Feb 2009 22:45:16 +0100 (CET)
Message-ID: <GVhknozYwrL.A.hiC.rozoJB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
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

This message contains a list of some regressions from 2.6.28, for which=
 there
are no fixes in the mainline I know of.  If any of them have been fixed=
 already,
please let me know.

If you know of any other unresolved regressions from 2.6.28, please let=
 me know
either and I'll add them to the list.  Also, please let me know if any =
of the
entries below are invalid.

Each entry from the list will be sent additionally in an automatic repl=
y to
this message with CCs to the people involved in reporting and handling =
the
issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2009-02-24       95       32          24
  2009-02-14       85       33          27
  2009-02-08       82       45          36
  2009-02-04       66       51          39
  2009-01-20       38       35          27
  2009-01-11       13       13          10


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12766
Subject		: Lots of smp_processor_id() in preemptible messages
Submitter	: Tilman Schmidt <t.schmidt-6eTgSDYuZyYd9SLi6J12IoQuADTiUCJX@public.gmane.org>
Date		: 2009-02-23 18:37 (1 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123541536414019&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12765
Subject		: i915 VT switch with AIGLX causes X lock up
Submitter	: Sitsofe Wheeler <sitsofe-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
Date		: 2009-02-21 15:38 (3 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123523074304955&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12764
Subject		: Can not ioremap virtual address for G33 hw status page
Submitter	: Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-02-23 14:46 (1 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D6fb88588555a18792a27f483887fe1f2af5f9c9b
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123540053219505&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12763
Subject		: Different cpu MHz values for processor0 and processor1
Submitter	: Matthew A. Bockol <mbockol-dmoCqaWXHRX2fBVCVOL8/A@public.gmane.org>
Date		: 2009-02-21 5:42 (3 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123519687807246&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12760
Subject		: 2.6.29-rc5 hanging at boot when CONFIG_LOCK_STAT=3Dy
Submitter	: Adam J. Richter <adam-7x81iamSd18S+FvcfC7Uqw@public.gmane.org>
Date		: 2009-02-16 6:50 (8 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123476768023893&w=3D=
4
Handled-By	: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12758
Subject		: ACPI exception with 2.6.29-rc6
Submitter	: Heinz Diehl <htd-HjJ2MNWy62to6+H+lsi3Gti2O/JbrIOy@public.gmane.org>
Date		: 2009-02-23 16:46 (1 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123540758700861&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12735
Subject		: Sound don't work with my toshiba X200 and kernel 2.6.29
Submitter	: chepioq <chepioq-PkbjNfxxIARGWvitb5QawA@public.gmane.org>
Date		: 2009-02-17 23:14 (7 days old)
Handled-By	: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12705
Subject		: X200: Brightness broken since 2.6.29-rc4-58-g4c098bc
Submitter	: Nico Schottelius <nico-linux-20090213-xuaVFQXs+5hIG4jRRZ66WA@public.gmane.org>
Date		: 2009-02-13 9:33 (11 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123451768406825&w=3D=
4
Handled-By	: Len Brown <lenb-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12681
Subject		: s2ram: fails to wake up on Acer Extensa 4220 (SMP disabled)
Submitter	: Orivej Desh <smpuj-5URONGGNgjI@public.gmane.org>
Date		: 2009-02-09 13:01 (15 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D1cfe62c8010ac56e1bd3827e30386a87cc2f3594


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12680
Subject		: Not having a VIA PadLock hardware incurs a long delay in pro=
bing on modules insertion attempt.
Submitter	: Valentin QUEQUET <v.quequet-techniques-1tsiiZ//OF9QFI55V6+gNQ@public.gmane.org>
Date		: 2009-02-09 09:12 (15 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12670
Subject		: BUG: unable to handle kernel paging request at pin_to_kill+0=
x21
Submitter	: Alessandro Bono <alessandro.bono-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-02-08 11:04 (16 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123409113223833&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12668
Subject		: USB flash disk surprise disconnect
Submitter	: Vegard Nossum <vegard.nossum-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-02-08 10:21 (16 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123408851821292&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12660
Subject		: Linux 2.6.28.3 freezing on a 32-bits x86 Thinkpad T43p
Submitter	: Mathieu Desnoyers <mathieu.desnoyers-scC8bbJcJLCw5LPnMra/2Q@public.gmane.org>
Date		: 2009-02-04 21:11 (20 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123378196022258&w=3D=
4
Handled-By	: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12617
Subject		: unable to compile e100 firmware into kernel
Submitter	: Andrey Borzenkov <arvidjaar-JGs/UdohzUI@public.gmane.org>
Date		: 2009-01-31 15:59 (24 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123341764915181&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12574
Subject		: possible circular locking dependency detected
Submitter	: Michael S. Tsirkin <m.s.tsirkin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-01-29 11:35 (26 days old)
References	: http://lkml.org/lkml/2009/2/9/205


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12551
Subject		: end_request: I/O error, dev cciss/c0d0, sector 87435720
Submitter	: Ralf Hildebrandt <ralf.hildebrandt-jq1tPX9l7E6ELgA04lAiVw@public.gmane.org>
Date		: 2009-01-27 06:51 (28 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12501
Subject		: build bug in eeepc-laptop.c
Submitter	: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Date		: 2009-01-14 17:25 (41 days old)
References	: http://lkml.org/lkml/2009/1/14/315


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12499
Subject		: Problem with using bluetooth adaper connected to usb port
Submitter	: Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-01-13 18:34 (42 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123187185426236&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12497
Subject		: new barrier warnings in 2.6.29-rc1
Submitter	: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Date		: 2009-01-12 15:46 (43 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123177528217154&w=3D=
4
Handled-By	: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12490
Subject		: ath5k related kernel panic in 2.6.29-rc1
Submitter	: Sergey S. Kostyliov <rathamahata-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-01-12 7:38 (43 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123174591509586&w=3D=
4
Handled-By	: Bob Copeland <me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12444
Subject		: X hangs following switch from radeonfb console - Bisected
Submitter	: Graham Murray <graham-0mDQKtL6jrwDXYZnReoRVg@public.gmane.org>
Date		: 2009-01-13 14:03 (42 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D7c1c2871a6a3a114853ec6836e9035ac1c0c7f7a


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12419
Subject		: possible circular locking dependency on i915 dma
Submitter	: Wang Chen <wangchen-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Date		: 2009-01-08 14:11 (47 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D546b0974c39657017407c86fe79811100b60700d
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123142399720125&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12418
Subject		: Repeated ioctl(4, 0x40046445, ..) loop in glxgears
Submitter	: Pallipadi, Venkatesh <venkatesh.pallipadi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date		: 2009-01-07 22:43 (48 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D7c1c2871a6a3a114853ec6836e9035ac1c0c7f7a
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123136836213319&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12414
Subject		: iwl4965 cannot use "ap auto" on latest 2.6.28/29?
Submitter	: Jeff Chua <jeff.chua.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-01-05 4:13 (50 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123112882127823&w=3D=
4


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12762
Subject		: Disk errors loop forever in 2.6.29
Submitter	: Sitsofe Wheeler <sitsofe-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
Date		: 2009-02-19 13:53 (5 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Db60af5b0adf0da24c673598c8d3fb4d4189a15ce
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123505185407604&w=3D=
4
Handled-By	: James Bottomley <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D123508030726900&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12761
Subject		: Bonding tied to IPV6 in 29-rc5
Submitter	: J.A. Magall=C3=B3n <jamagallon-sh/6fXdz2Rs@public.gmane.org>
Date		: 2009-02-17 8:52 (7 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123486078219980&w=3D=
4
Handled-By	: Brian Haley <brian.haley-VXdhtT5mjnY@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D123517631120945&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12706
Subject		: Oopses and ACPI problems (Linus 2.6.29-rc4)
Submitter	: Darren Salt <linux-Ym6Ivm/Ks7B65+NM0QMiFAbYiX8G1TQY9dF7HbQ/qKg@public.gmane.org>
Date		: 2009-02-09 18:26 (15 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123420431709877&w=3D=
4
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D123427814117781&w=3D2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12671
Subject		: uvc_status_cleanup(): undefined reference to `input_unregist=
er_device'
Submitter	: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Date		: 2009-02-08 14:58 (16 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123410529909318&w=3D=
4
Handled-By	: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Patch		: http://lkml.org/lkml/2009/2/15/172


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12667
Subject		: Badness at kernel/time/timekeeping.c:98 in pmud (timekeeping=
_suspended)
Submitter	: Paul Collins <paul-dsjeNyW6Qm/D+ROgJ3VA+kB+6BGkLq7r@public.gmane.org>
Date		: 2009-01-21 7:15 (34 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D1c5745aa380efb6417b5681104b007c8612fb496
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123252215315106&w=3D=
4
Handled-By	: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Patch		: http://lkml.org/lkml/2009/2/16/78


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12618
Subject		: hackbench [pthread mode] regression with 2.6.29-rc3
Submitter	: Zhang, Yanmin <yanmin_zhang-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Date		: 2009-02-01 7:30 (23 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D490dea45d00f01847ebebd007685d564aaf2cd98
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123347347726527&w=3D=
4
Handled-By	: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D123383366122146&w=3D4
		  http://marc.info/?l=3Dlinux-kernel&m=3D123383366222152&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12613
Subject		: [Suspend regression][DRM, RADEON]
Submitter	: etienne <etienne.basset-Bf/eaXMDFuuXqB7oj33eUg@public.gmane.org>
Date		: 2009-01-28 22:00 (27 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Da9d51a5ad1154b5b20add1e8d30a5564f8aabbe9
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123318030419558&w=3D=
4
		  http://marc.info/?l=3Dlinux-kernel&m=3D123334865404574&w=3D4
		  http://lkml.org/lkml/2009/2/8/203
Patch		: http://lkml.org/lkml/2009/2/15/28


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12491
Subject		: i915 lockdep warning
Submitter	: Brandeburg, Jesse <jesse.brandeburg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date		: 2009-01-13 23:17 (42 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123188898423532&w=3D=
4
Handled-By	: Roland Dreier <rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D123378709730700&w=3D2


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions from 2=
=2E6.28,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D12398

Please let me know if there are any Bugzilla entries that should be add=
ed to
the list in there.

Thanks,
Rafael
