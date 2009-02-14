From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.29-rc5: Reported regressions 2.6.27 -> 2.6.28
Date: Sat, 14 Feb 2009 21:48:06 +0100 (CET)
Message-ID: <sTyoMUwdm9B.A.QCH.U40lJB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Natalie Protasevich <protasnb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Stable Kernel Team <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This message contains a list of some regressions introduced between 2.6.27 and
2.6.28, for which there are no fixes in the mainline I know of.  If any of them
have been fixed already, please let me know.

If you know of any other unresolved regressions introduced between 2.6.27
and 2.6.28, please let me know either and I'll add them to the list.
Also, please let me know if any of the entries below are invalid.

Each entry from the list will be sent additionally in an automatic reply to
this message with CCs to the people involved in reporting and handling the
issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2009-02-15      152       30          26
  2009-02-04      149       33          30
  2009-01-20      144       30          27
  2009-01-11      139       33          30
  2008-12-21      120       19          17
  2008-12-13      111       14          13
  2008-12-07      106       20          17
  2008-12-04      106       29          21
  2008-11-22       93       25          15
  2008-11-16       89       32          18
  2008-11-09       73       40          27
  2008-11-02       55       41          29
  2008-10-25       26       25          20


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12690
Subject		: DPMS (LCD powersave, poweroff) don't work
Submitter	: Antonin Kolisek <akolisek-T3ps84XAcx36AaHJ4hbVU+3CNBr840j2@public.gmane.org>
Date		: 2009-02-11 09:40 (4 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12658
Subject		: ThrustMaster Firestorm Dual Power 3 Gamepads stopped working
Submitter	: Frank Roscher <Frank-Roscher-hi6Y0CQ0nG0@public.gmane.org>
Date		: 2009-02-08 08:45 (7 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12645
Subject		: DMI low-memory-protect quirk causes resume hang on Samsung NC10
Submitter	: Patrick Walton <pcwalton-764C0pRuGfqVc3sceRu5cw@public.gmane.org>
Date		: 2009-02-06 18:35 (9 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=0af40a4b1050c050e62eb1dc30b82d5ab22bf221


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12634
Subject		: video distortion and lockup with i830 video chip and 2.6.28.3
Submitter	: Bob Raitz <pappy_mcfae-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
Date		: 2009-02-04 21:10 (11 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12619
Subject		: Regression 2.6.28 and last - boot failed
Submitter	: jan sonnek <ha2nny-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-02-01 19:59 (14 days old)
References	: http://marc.info/?l=linux-kernel&m=123351836213969&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12559
Subject		: Huawei E169 doesn't work as mass storage anymore
Submitter	: kpalberg <kpalberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-01-28 02:34 (18 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12500
Subject		: r8169: NETDEV WATCHDOG: eth0 (r8169): transmit timed out
Submitter	: Justin Piszcz <jpiszcz-BP4nVm5VUdNhbmWW9KSYcQ@public.gmane.org>
Date		: 2009-01-13 21:19 (33 days old)
References	: http://marc.info/?l=linux-kernel&m=123188160811322&w=4
Handled-By	: Francois Romieu <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12465
Subject		: KVM guests stalling on 2.6.28 (bisected)
Submitter	: Kevin Shanahan <kmshanah-biM/RbsGxha6c6uEtOJ/EA@public.gmane.org>
Date		: 2009-01-17 03:37 (29 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12421
Subject		: GPF on 2.6.28 and 2.6.28-rc9-git3, e1000e and e1000 issues
Submitter	: Doug Bazarnic <doug-nOyj/A09A+/k1uMJSBkQmQ@public.gmane.org>
Date		: 2009-01-09 21:26 (37 days old)
References	: http://marc.info/?l=linux-kernel&m=123153653120204&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12411
Subject		: 2.6.28: BUG in r8169
Submitter	: Andrey Vul <andrey.vul-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2008-12-31 18:37 (46 days old)
References	: http://marc.info/?l=linux-kernel&m=123074869611409&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12409
Subject		: NULL pointer dereference at get_stats()
Submitter	: Tetsuo Handa <penguin-kernel-1yMVhJb1mP/7nzcFbJAaVXf5DAMn2ifp@public.gmane.org>
Date		: 2008-12-30 12:53 (47 days old)
References	: http://marc.info/?l=linux-kernel&m=123064167008695&w=4
Handled-By	: Frederik Deweerdt <frederik.deweerdt-kjvbsxwSFqI@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12408
Subject		: Funny problem with 2.6.28: Kernel stalls
Submitter	: Michael Roth <mroth-+8Z3Oe2AQjqzQB+pC5nmwQ@public.gmane.org>
Date		: 2008-12-25 15:14 (52 days old)
References	: http://marc.info/?l=linux-kernel&m=123021931714282&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12407
Subject		: Kernel 2.6.28 regression: Hang after hibernate
Submitter	: Frank Groeneveld <frankgroeneveld-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2008-12-28 20:34 (49 days old)
References	: http://marc.info/?l=linux-kernel&m=123049651906081&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12405
Subject		: oops in __bounce_end_io_read under kvm
Submitter	: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Date		: 2008-12-26 17:36 (51 days old)
References	: http://marc.info/?l=linux-kernel&m=123031303400676&w=4
Handled-By	: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12404
Subject		: Oops in 2.6.28-rc9 and -rc8 -- mtrr issues / e1000e
Submitter	: Kernel <kernel-nOyj/A09A+/k1uMJSBkQmQ@public.gmane.org>
Date		: 2008-12-22 9:37 (55 days old)
References	: http://marc.info/?l=linux-kernel&m=122993873320150&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12403
Subject		: TTY problem on linux-2.6.28-rc7
Submitter	: sasa sasa <sasak.1983-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2008-12-22 4:23 (55 days old)
References	: http://marc.info/?l=linux-kernel&m=122991914600390&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12401
Subject		: 2.6.28 regression: xbacklight broken on ThinkPad X61s
Submitter	: Tino Keitel <tino.keitel-Mmb7MZpHnFY@public.gmane.org>
Date		: 2009-01-05 8:39 (41 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=22c13f9d8179f4c9caecfcb60a95214562b9addc
References	: http://marc.info/?l=linux-kernel&m=123114479110314&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12395
Subject		: 2.6.28-rc9: oprofile regression
Submitter	: Tim Blechmann <tim-xpEK/MU0Hawdnm+yROfE0A@public.gmane.org>
Date		: 2008-12-21 14:23 (56 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=b99170288421c79f0c2efa8b33e26e65f4bb7fb8
References	: http://marc.info/?l=linux-kernel&m=122986946614791&w=4
Handled-By	: Andi Kleen <ak-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12337
Subject		: ~100 extra wakeups reported by powertop
Submitter	: Alberto Gonzalez <luis6674-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
Date		: 2008-12-31 12:25 (46 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12265
Subject		: FPU emulation broken in 2.6.28-rc8 ?
Submitter	: Rogier Wolff <R.E.Wolff-bu/CaDbLbdHGjfRZg6uqBA@public.gmane.org>
Date		: 2008-12-17 8:56 (60 days old)
References	: http://marc.info/?l=linux-kernel&m=122950463030747&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12263
Subject		: Sata soft reset filling log
Submitter	: Justin Madru <bevicm-QP1aEjBt37AFQeE35raUng@public.gmane.org>
Date		: 2008-12-13 2:07 (64 days old)
References	: http://marc.info/?l=linux-kernel&m=122913412608533&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12224
Subject		: journal activity on inactive partition causes inactive harddrive spinup
Submitter	: C Sights <csights-97jfqw80gc6171pxa8y+qA@public.gmane.org>
Date		: 2008-12-14 11:39 (63 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=c87591b719737b4e91eb1a9fa8fd55a4ff1886d6
Handled-By	: Eric Sandeen <sandeen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12209
Subject		: oldish top core dumps (in its meminfo() function)
Submitter	: Andreas Mohr <andi-5+Cda9B46AM@public.gmane.org>
Date		: 2008-12-12 18:49 (65 days old)
References	: http://marc.info/?l=linux-kernel&m=122910784006472&w=4
		  http://marc.info/?l=linux-kernel&m=122907511319288&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12208
Subject		: uml is very slow on 2.6.28 host
Submitter	: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Date		: 2008-12-12 9:35 (65 days old)
References	: http://marc.info/?l=linux-kernel&m=122907463518593&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12160
Subject		: networking oops after resume from s2ram (2.6.28-rc6)
Submitter	: Marcin Slusarz <marcin.slusarz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2008-11-28 21:15 (79 days old)
References	: http://marc.info/?l=linux-kernel&m=122790701615723&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12061
Subject		: snd_hda_intel: power_save: sound cracks on powerdown
Submitter	: Jens Weibler <bugzilla-kernel-6hJTtV8wudIr9FUcG+3rRQ@public.gmane.org>
Date		: 2008-11-18 12:07 (89 days old)
Handled-By	: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12614
Subject		: WOL with forcedeth broken since f55c21fd9a92a444e55ad1ca4e4732d56661bf2e
Submitter	: Philipp Matthias Hahn <pmhahn-u4khhh1J0LzF41mA0N3lWw@public.gmane.org>
Date		: 2009-01-29 6:31 (17 days old)
References	: http://marc.info/?l=linux-kernel&m=123321232825316&w=4
Handled-By	: Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
		  Tobias Diedrich <ranma+kernel-YxUgxmcw2FPQD6PfKP4TzA@public.gmane.org>
Patch		: http://marc.info/?l=linux-kernel&m=123330459229248&w=4
		  http://marc.info/?l=linux-kernel&m=123411195117835&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12612
Subject		: hard lockup when interrupting cdda2wav
Submitter	: Matthias Reichl <hias-vtPv7MOkFPkAvxtiuMwx3w@public.gmane.org>
Date		: 2009-01-28 16:41 (18 days old)
References	: http://marc.info/?l=linux-kernel&m=123316111415677&w=4
Handled-By	: FUJITA Tomonori <fujita.tomonori-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
Patch		: http://marc.info/?l=linux-scsi&m=123371501613019&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12406
Subject		: 2.6.28 thinks that my PS/2 mouse is a touchpad
Submitter	: Alexander E. Patrakov <patrakov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2008-12-27 9:06 (50 days old)
References	: http://marc.info/?l=linux-kernel&m=123036893817280&w=4
Handled-By	: Arjan Opmeer <arjan-OssVvNj1wBysTnJN9+BGXg@public.gmane.org>
Patch		: http://marc.info/?l=linux-kernel&m=123092147703236&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12393
Subject		: debugging in dosemu causes lots of 'scheduling while atomic'
Submitter	: Michal Suchanek <hramrach-aRb0bU7PRFPrBKCeMvbIDA@public.gmane.org>
Date		: 2009-01-09 07:28 (37 days old)
Handled-By	: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Patch		: http://lkml.org/lkml/2009/1/13/445


For details, please visit the bug entries and follow the links given in
references.

As you can see, there is a Bugzilla entry for each of the listed regressions.
There also is a Bugzilla entry used for tracking the regressions introduced
between 2.6.27 and 2.6.28, unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=11808

Please let me know if there are any Bugzilla entries that should be added to
the list in there.

Thanks,
Rafael
