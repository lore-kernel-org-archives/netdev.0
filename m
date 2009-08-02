From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.31-rc5: Reported regressions from 2.6.30
Date: Sun,  2 Aug 2009 20:49:40 +0200 (CEST)
Message-ID: <Su1q3S6JjyO.A.jeB.hcgdKB@chimera>
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
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This message contains a list of some regressions from 2.6.30, for which there
are no fixes in the mainline I know of.  If any of them have been fixed already,
please let me know.

If you know of any other unresolved regressions from 2.6.30, please let me know
either and I'll add them to the list.  Also, please let me know if any of the
entries below are invalid.

Each entry from the list will be sent additionally in an automatic reply to
this message with CCs to the people involved in reporting and handling the
issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2009-08-02       76       36          28
  2009-07-27       70       51          43
  2009-07-07       35       25          21
  2009-06-29       22       22          15


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13899
Subject		: Oops from tar, 2.6.31-rc5, 32 bit on quad core phenom.
Submitter	: Gene Heskett <gene.heskett-H+0wwilmMs3R7s880joybQ@public.gmane.org>
Date		: 2009-08-01 13:04 (2 days old)
References	: http://marc.info/?l=linux-kernel&m=124913190304149&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13896
Subject		: 2.6.31-rc4 broke expect and gcc's testsuite
Submitter	: Mikael Pettersson <mikpe-1zs4UD6AkMk@public.gmane.org>
Date		: 2009-07-29 11:00 (5 days old)
References	: http://marc.info/?l=linux-kernel&m=124885806406520&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13895
Subject		: 2.6.31-rc4 - slab entry tak_delay_info leaking ???
Submitter	: Paul Rolland <rol-hQZ2c1jdYO6sTnJN9+BGXg@public.gmane.org>
Date		: 2009-07-29 08:20 (5 days old)
References	: http://marc.info/?l=linux-kernel&m=124884847925375&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13894
Subject		: intermittent hibernation problem
Submitter	: Ferenc Wagner <wferi-eEbw3PyuezQ@public.gmane.org>
Date		: 2009-07-30 13:29 (4 days old)
References	: https://lists.linux-foundation.org/pipermail/linux-pm/2009-July/022095.html


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13869
Subject		: Radeon framebuffer (w/o KMS) corruption at boot.
Submitter	: Duncan <1i5t5.duncan-j9pdmedNgrk@public.gmane.org>
Date		: 2009-07-29 16:44 (5 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13848
Subject		: iwlwifi (4965) regression since 2.6.30
Submitter	: Lukas Hejtmanek <xhejtman-8qz54MUs51PtwjQa/ONI9g@public.gmane.org>
Date		: 2009-07-26 7:57 (8 days old)
References	: http://marc.info/?l=linux-kernel&m=124859658502866&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13846
Subject		: Possible regression in rt61pci driver
Submitter	: Chris Clayton <chris2553-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Date		: 2009-07-13 8:27 (21 days old)
References	: http://marc.info/?l=linux-kernel&m=124747418828398&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13842
Subject		: Oops when writing to /sys/block/ram0/queue/max_sectors_kb
Submitter	: Jens Rosenboom <jens-D7rluS+iyhCsTnJN9+BGXg@public.gmane.org>
Date		: 2009-07-23 15:30 (11 days old)
References	: http://marc.info/?l=linux-kernel&m=124836574403032&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13837
Subject		: Input : regression - touchpad not detected
Submitter	: Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-07-17 07:13 (17 days old)
References	: http://marc.info/?l=linux-kernel&m=124780763701571&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13836
Subject		: suspend script fails, related to stdout?
Submitter	: Tomas M. <tmezzadra-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-07-17 21:24 (17 days old)
References	: http://marc.info/?l=linux-kernel&m=124785853811667&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13833
Subject		: Kernel Oops when trying to suspend with ubifs mounted on block2mtd mtd device
Submitter	: Tobias Diedrich <ranma-YxUgxmcw2FPQD6PfKP4TzA@public.gmane.org>
Date		: 2009-07-15 14:20 (19 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=15bce40cb3133bcc07d548013df97e4653d363c1
References	: http://marc.info/?l=linux-kernel&m=124766049207807&w=4
		  http://marc.info/?l=linux-kernel&m=124704927819769&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13826
Subject		: thinkpad boots with backlight low
Submitter	: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Date		: 2009-07-15 15:13 (19 days old)
References	: http://marc.info/?l=linux-kernel&m=124756359126830&w=4
Handled-By	: Henrique de Moraes Holschuh <hmh-N3TV7GIv+o9fyO9Q7EP/yw@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13819
Subject		: system freeze when switching to console
Submitter	: Reinette Chatre <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date		: 2009-07-23 17:57 (11 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13815
Subject		: emacs -nw compilation doesn't show the error message
Submitter	: Aneesh Kumar K.V <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date		: 2009-07-23 06:22 (11 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=d945cb9cce20ac7143c2de8d88b187f62db99bdc


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13813
Subject		: Hangups in n_tty_read()
Submitter	: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Date		: 2009-07-16 18:48 (18 days old)
References	: http://marc.info/?l=linux-kernel&m=124777019920579&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13812
Subject		: Ooops on uplug
Submitter	: Daniel Mack <daniel-rDUAYElUppE@public.gmane.org>
Date		: 2009-07-20 17:51 (14 days old)
References	: http://marc.info/?l=linux-kernel&m=124811234302786&w=4
Handled-By	: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
		  Alan Cox <alan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13809
Subject		: oprofile: possible circular locking dependency detected
Submitter	: Jerome Marchand <jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date		: 2009-07-22 13:35 (12 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13770
Subject		: System freeze on XFS filesystem recovery on an external disk
Submitter	: Jean-Luc Coulon <jean.luc.coulon-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-07-14 10:31 (20 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13762
Subject		: AHCI on HP Compaq 6715s broken, did not detect slots/ports -> unable to boot
Submitter	: Matthias Tingelhoff <mindo83-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org>
Date		: 2009-07-11 20:48 (23 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=a76117dfd687ec4be0a9a05214f3009cc5f73a42


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13740
Subject		: X server crashes with 2.6.31-rc2 when options are changed
Submitter	: Michael S. Tsirkin <m.s.tsirkin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-07-07 15:19 (27 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13733
Subject		: 2.6.31-rc2: irq 16: nobody cared
Submitter	: Niel Lambrechts <niel.lambrechts-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-07-06 18:32 (28 days old)
References	: http://marc.info/?l=linux-kernel&m=124690524027166&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13731
Subject		: Inconsistent {IN-RECLAIM_FS-W} -> {RECLAIM_FS-ON-W} usage.
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-07-06 4:22 (28 days old)
References	: http://marc.info/?l=linux-kernel&m=124685417325348&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13726
Subject		: fio sync read 4k block size 35% regression
Submitter	: Zhang, Yanmin <yanmin_zhang-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Date		: 2009-07-01 11:25 (33 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=51daa88ebd8e0d437289f589af29d4b39379ea76
References	: http://lkml.org/lkml/2009/6/30/679
Handled-By	: Wu Fengguang <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13716
Subject		: The AIC-7892P controller does not work any more
Submitter	: Andrej Podzimek <andrej-+Hii8LNHG6Ng9hUCZPvPmw@public.gmane.org>
Date		: 2009-07-05 19:23 (29 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13713
Subject		: [drm/i915] Possible regression due to commit "Change GEM throttling to be 20ms (...)"
Submitter	:  <kazikcz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-07-05 10:49 (29 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=b962442e46a9340bdbc6711982c59ff0cc2b5afb


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13657
Subject		: Linux-2.6.31-rc1 Fails To Recognize Some USB Disks
Submitter	: Tarkan Erimer <tarkan.erimer-AMZSHK9Z0TXlajqSnzHT9w@public.gmane.org>
Date		: 2009-06-26 10:03 (38 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=3821d768912a47ddbd6cab52943a8284df88003c
References	: http://lkml.org/lkml/2009/6/26/34
Handled-By	: Martin K. Petersen <martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13656
Subject		: 2.6.31-rc1 crashes randomly on my Machine.
Submitter	: Zeno Davatz <zdavatz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-06-26 08:56 (38 days old)
References	: http://lkml.org/lkml/2009/6/26/27


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13645
Subject		: NULL pointer dereference at (null) (level2_spare_pgt)
Submitter	: poornima nayak <mpnayak-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date		: 2009-06-17 17:56 (47 days old)
References	: http://lkml.org/lkml/2009/6/17/194


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13891
Subject		: PCI resources allocation problem on HP nx6325
Submitter	: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>
Date		: 2009-08-02 13:37 (1 days old)
Handled-By	: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/38774/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13872
Subject		: cpufreq bug (null pointer dereference)
Submitter	: Christophe Lermytte <christophe.lermytte-L+G57L1VLRbR7s880joybQ@public.gmane.org>
Date		: 2009-07-21 22:07 (13 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=ee88415caf736b89500f16e0a545614541a45005
References	: http://marc.info/?l=linux-kernel&m=124820689011112&w=4
Handled-By	: Pallipadi, Venkatesh <venkatesh.pallipadi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/38229/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13861
Subject		: CIFS mounts ignore uid argument (ok in 2.6.30.3)
Submitter	:  <bugzilla.kernel.org-rFaUCAwe0VHnLTtGmMESvQ@public.gmane.org>
Date		: 2009-07-28 21:39 (6 days old)
Handled-By	: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/38498/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13840
Subject		: KMS oops on 945G system
Submitter	: Diego Calleja <diegocg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-07-21 20:50 (13 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=7662c8bd6545c12ac7b2b39e4554c3ba34789c50
References	: http://marc.info/?l=linux-kernel&m=124820945815030&w=4
Handled-By	: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>
Patch		: http://git.kernel.org/?p=linux/kernel/git/anholt/drm-intel.git;a=commit;h=dff33cfcefa31c30b72c57f44586754ea9e8f3e2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13838
Subject		: kernel BUG at include/net/netns/generic.h:41!
Submitter	: Luca Tettamanti <kronos.it-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-07-20 15:27 (14 days old)
References	: http://lkml.org/lkml/2009/7/20/105
Handled-By	: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/37779/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13825
Subject		: eeepc-laptop: fix hot-unplug on resume
Submitter	: Alan Jenkins <alan-jenkins-cCz0Lq7MMjm9FHfhHBbuYA@public.gmane.org>
Date		: 2009-06-29 13:12 (35 days old)
References	: http://lkml.org/lkml/2009/6/29/150
Handled-By	: Alan Jenkins <alan-jenkins-cCz0Lq7MMjm9FHfhHBbuYA@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/32926/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13781
Subject		: System freeze at resume after suspend to RAM
Submitter	: Christian Casteyde <casteyde.christian-GANU6spQydw@public.gmane.org>
Date		: 2009-07-15 18:42 (19 days old)
Handled-By	: Zhao Yakui <yakui.zhao-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Patch		: http://bugzilla.kernel.org/attachment.cgi?id=22463


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13742
Subject		: iwlagn (4965): regression when hardware rf switch is used
Submitter	: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Date		: 2009-06-29 11:28 (35 days old)
References	: http://lkml.org/lkml/2009/6/29/88
Handled-By	: Reinette Chatre <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Patch		: http://lkml.org/lkml/2009/6/30/224


For details, please visit the bug entries and follow the links given in
references.

As you can see, there is a Bugzilla entry for each of the listed regressions.
There also is a Bugzilla entry used for tracking the regressions from 2.6.30,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=13615

Please let me know if there are any Bugzilla entries that should be added to
the list in there.

Thanks,
Rafael
