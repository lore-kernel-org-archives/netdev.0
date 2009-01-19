From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.29-rc2-git1: Reported regressions 2.6.27 -> 2.6.28
Date: Mon, 19 Jan 2009 22:41:39 +0100 (CET)
Message-ID: <KTnguC9mFUC.A.VNB.TJRdJB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
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

This message contains a list of some regressions introduced between 2.6=
=2E27 and
2.6.28, for which there are no fixes in the mainline I know of.  If any=
 of them
have been fixed already, please let me know.

If you know of any other unresolved regressions introduced between 2.6.=
27
and 2.6.28, please let me know either and I'll add them to the list.
Also, please let me know if any of the entries below are invalid.

Each entry from the list will be sent additionally in an automatic repl=
y to
this message with CCs to the people involved in reporting and handling =
the
issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
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

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12500
Subject		: r8169: NETDEV WATCHDOG: eth0 (r8169): transmit timed out
Submitter	: Justin Piszcz <jpiszcz-BP4nVm5VUdNhbmWW9KSYcQ@public.gmane.org>
Date		: 2009-01-13 21:19 (7 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123188160811322&w=3D=
4
Handled-By	: Francois Romieu <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12483
Subject		: Reference to inexistent struct dmi_device_id breaks the buil=
d
Submitter	: Jean Delvare <khali-PUYAD+kWke1g9hUCZPvPmw@public.gmane.org>
Date		: 2009-01-19 01:29 (1 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12465
Subject		: KVM guests stalling on 2.6.28 (bisected)
Submitter	: Kevin Shanahan <kmshanah-biM/RbsGxha6c6uEtOJ/EA@public.gmane.org>
Date		: 2009-01-17 03:37 (3 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12426
Subject		: TMDC Joystick no longer works in kernel 2.6.28
Submitter	: Andrew S. Johnson <andy-9eXmkf4BiQ2aMJb+Lgu22Q@public.gmane.org>
Date		: 2009-01-10 21:53 (10 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123162486415366&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12421
Subject		: GPF on 2.6.28 &amp; 2.6.28-rc9-git3 =C2=A0 =C2=A0e1000e / e1=
000 issues
Submitter	: Doug Bazarnic <doug-nOyj/A09A+/k1uMJSBkQmQ@public.gmane.org>
Date		: 2009-01-09 21:26 (11 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123153653120204&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12411
Subject		: 2.6.28: BUG in r8169
Submitter	: Andrey Vul <andrey.vul-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2008-12-31 18:37 (20 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123074869611409&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12409
Subject		: NULL pointer dereference at get_stats()
Submitter	: Tetsuo Handa <penguin-kernel-1yMVhJb1mP/7nzcFbJAaVXf5DAMn2ifp@public.gmane.org>
Date		: 2008-12-30 12:53 (21 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123064167008695&w=3D=
4
Handled-By	: Frederik Deweerdt <frederik.deweerdt-kjvbsxwSFqI@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12408
Subject		: Funny problem with 2.6.28: Kernel stalls
Submitter	: Michael Roth <mroth-+8Z3Oe2AQjqzQB+pC5nmwQ@public.gmane.org>
Date		: 2008-12-25 15:14 (26 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123021931714282&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12407
Subject		: Kernel 2.6.28 regression: Hang after hibernate
Submitter	: Frank Groeneveld <frankgroeneveld-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2008-12-28 20:34 (23 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123049651906081&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12405
Subject		: oops in __bounce_end_io_read under kvm
Submitter	: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Date		: 2008-12-26 17:36 (25 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123031303400676&w=3D=
4
Handled-By	: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12404
Subject		: Oops in 2.6.28-rc9 and -rc8 -- mtrr issues / e1000e
Submitter	: Kernel <kernel-nOyj/A09A+/k1uMJSBkQmQ@public.gmane.org>
Date		: 2008-12-22 9:37 (29 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122993873320150&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12403
Subject		: TTY problem on linux-2.6.28-rc7
Submitter	: sasa sasa <sasak.1983-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2008-12-22 4:23 (29 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122991914600390&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12401
Subject		: 2.6.28 regression: xbacklight broken on ThinkPad X61s
Submitter	: Tino Keitel <tino.keitel-Mmb7MZpHnFY@public.gmane.org>
Date		: 2009-01-05 8:39 (15 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D22c13f9d8179f4c9caecfcb60a95214562b9addc
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123114479110314&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12395
Subject		: 2.6.28-rc9: oprofile regression
Submitter	: Tim Blechmann <tim-xpEK/MU0Hawdnm+yROfE0A@public.gmane.org>
Date		: 2008-12-21 14:23 (30 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Db99170288421c79f0c2efa8b33e26e65f4bb7fb8
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122986946614791&w=3D=
4
Handled-By	: Andi Kleen <ak-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12393
Subject		: debugging in dosemu causes lots of 'scheduling while atomic'
Submitter	: Michal Suchanek <hramrach-aRb0bU7PRFPrBKCeMvbIDA@public.gmane.org>
Date		: 2009-01-09 07:28 (11 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12391
Subject		: Processor does not go below C2 state until usb.autosuspend i=
s enabled
Submitter	: Gergely Imreh <imrehg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-01-09 02:35 (11 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12337
Subject		: ~100 extra wakeups reported by powertop
Submitter	: Alberto Gonzalez <luis6674-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
Date		: 2008-12-31 12:25 (20 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12265
Subject		: FPU emulation broken in 2.6.28-rc8 ?
Submitter	: Rogier Wolff <R.E.Wolff-bu/CaDbLbdHGjfRZg6uqBA@public.gmane.org>
Date		: 2008-12-17 8:56 (34 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122950463030747&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12264
Subject		: i915: switching from kwin in opengl mode to a VT then back t=
o x11, x11 freezes
Submitter	: Caleb Cushing <xenoterracide-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2008-12-16 11:40 (35 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122942777030666&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12263
Subject		: Sata soft reset filling log
Submitter	: Justin Madru <bevicm-QP1aEjBt37AFQeE35raUng@public.gmane.org>
Date		: 2008-12-13 2:07 (38 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122913412608533&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12224
Subject		: journal activity on inactive partition causes inactive hardd=
rive spinup
Submitter	: C Sights <csights-97jfqw80gc6171pxa8y+qA@public.gmane.org>
Date		: 2008-12-14 11:39 (37 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dc87591b719737b4e91eb1a9fa8fd55a4ff1886d6
Handled-By	: Eric Sandeen <sandeen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12209
Subject		: oldish top core dumps (in its meminfo() function)
Submitter	: Andreas Mohr <andi-5+Cda9B46AM@public.gmane.org>
Date		: 2008-12-12 18:49 (39 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122910784006472&w=3D=
4
		  http://marc.info/?l=3Dlinux-kernel&m=3D122907511319288&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12208
Subject		: uml is very slow on 2.6.28 host
Submitter	: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Date		: 2008-12-12 9:35 (39 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122907463518593&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12160
Subject		: networking oops after resume from s2ram (2.6.28-rc6)
Submitter	: Marcin Slusarz <marcin.slusarz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2008-11-28 21:15 (53 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122790701615723&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12159
Subject		: 2.6.28-rc6-git1 -- No sound produced from Intel HDA ALSA dri=
ver
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2008-11-27 20:33 (54 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122781805620212&w=3D=
4
Handled-By	: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12061
Subject		: snd_hda_intel: power_save: sound cracks on powerdown
Submitter	: Jens Weibler <bugzilla-kernel-6hJTtV8wudIr9FUcG+3rRQ@public.gmane.org>
Date		: 2008-11-18 12:07 (63 days old)
Handled-By	: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11849
Subject		: default IRQ affinity change in v2.6.27 (breaking several SMP=
 PPC based systems)
Submitter	: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Date		: 2008-10-24 12:45 (88 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122485245924125&w=3D=
4


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12406
Subject		: 2.6.28 thinks that my PS/2 mouse is a touchpad
Submitter	: Alexander E. Patrakov <patrakov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2008-12-27 9:06 (24 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123036893817280&w=3D=
4
Handled-By	: Arjan Opmeer <arjan-OssVvNj1wBysTnJN9+BGXg@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D123092147703236&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12396
Subject		: hwinfo problem since 2.6.28
Submitter	: Beschorner Daniel <Daniel.Beschorner-cdG02ZADnvLQT0dZR+AlfA@public.gmane.org>
Date		: 2009-01-06 8:53 (14 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123123277800835&w=3D=
4
Handled-By	: Suresh Siddha <suresh.b.siddha-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D123154005127497&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D12260
Subject		: Regression due to commit 2b80848e3818fb1c (p54usb: support L=
M87 firmwares)
Submitter	: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Date		: 2008-12-20 10:45 (31 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D2b80848e3818fb1c8ccddc105b065a86c68afa9d
Patch		: http://bugzilla.kernel.org/show_bug.cgi?id=3D12260


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions introd=
uced
between 2.6.27 and 2.6.28, unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D11808

Please let me know if there are any Bugzilla entries that should be add=
ed to
the list in there.

Thanks,
Rafael
