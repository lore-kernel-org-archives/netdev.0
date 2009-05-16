From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.30-rc6: Reported regressions from 2.6.29
Date: Sat, 16 May 2009 21:14:37 +0200 (CEST)
Message-ID: <_AjETDMbIoL.A.DcH.RYzDKB@chimera>
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
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This message contains a list of some regressions from 2.6.29, for which=
 there
are no fixes in the mainline I know of.  If any of them have been fixed=
 already,
please let me know.

If you know of any other unresolved regressions from 2.6.29, please let=
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
  2009-05-16       81       36          33
  2009-04-25       55       36          26
  2009-04-17       37       35          28



Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13329
Subject		: cifs_close: NULL pointer dereference
Submitter	: Luca Tettamanti <kronos.it-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-05-16 16:28 (1 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124249133701702&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13328
Subject		: b44: eth0: BUG! Timeout waiting for bit 00000002 of register=
 42c to clear.
Submitter	: Francis Moreau <francis.moro-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-05-03 16:22 (14 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124136778012280&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13327
Subject		: Regression: 2.6.30-rc5 and rt2x00 / rt2500pci
Submitter	: Ken Lewis <kennylewis-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-05-15 14:40 (2 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124239988223614&w=3D=
4
Handled-By	: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13326
Subject		: Null pointer dereference in rtc-cmos driver
Submitter	: Ozan =C3=87a=C4=9Flayan <ozan-caicS1wCkhO6A22drWdTBw@public.gmane.org>
Date		: 2009-05-14 16:16 (3 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124231783704696&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13325
Subject		: 2.6.30-rc kills my box hard - and lockdep chains
Submitter	: Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>
Date		: 2009-05-14 15:49 (3 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124231630701394&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13324
Subject		: panic when loading oprofile
Submitter	: Brandeburg, Jesse <jesse.brandeburg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date		: 2009-05-13 22:30 (4 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124225384311631&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13323
Subject		: 2.6.30-rc deadline scheduler performance regression for iozo=
ne over NFS
Submitter	: Jeff Moyer <jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date		: 2009-04-23 14:01 (24 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124049547915450&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13321
Subject		: kernel crash with NULL pointer when boot
Submitter	: Martin Bammer <mrb74-RbZlAiThDcE@public.gmane.org>
Date		: 2009-05-16 12:37 (1 days old)
References	: http://lkml.org/lkml/2009/5/16/100


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13319
Subject		: Page allocation failures with b43 and p54usb
Submitter	: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Date		: 2009-04-29 21:01 (18 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124103897101088&w=3D=
4
Handled-By	: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13318
Subject		: AGP doesn't work anymore on nforce2
Submitter	: Karsten Mehrhoff <kawime-Mmb7MZpHnFY@public.gmane.org>
Date		: 2009-04-30 8:51 (17 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D59de2bebabc5027f93df999d59cc65df591c3e6e
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124108156417560&w=3D=
4
Handled-By	: Shaohua Li <shaohua.li-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13306
Subject		: hibernate slow on _second_ run
Submitter	: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date		: 2009-05-14 09:34 (3 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13298
Subject		: modprobe ipmi_si hangs under 2.6.30-rc5
Submitter	: Ferenc Wagner <wferi-eEbw3PyuezQ@public.gmane.org>
Date		: 2009-05-12 21:28 (5 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124216379407177&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13297
Subject		: kernel panic -  not syncing : fatel exception in interupt
Submitter	: rob <rob1-z2Ut7v/pTR/vt0rt8C/ehw@public.gmane.org>
Date		: 2009-05-12 19:34 (5 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124216126903309&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13296
Subject		: Lockdep violation at cleanup_workqueue_thread during suspend
Submitter	: Zdenek Kabelac <zdenek.kabelac-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-05-12 7:59 (5 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124211522525625&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13294
Subject		: i915: drm: xorg leaks drm objects massively
Submitter	: Sergei Trofimovich <slyich-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-05-10 19:56 (7 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124198547027903&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13293
Subject		: Kernel BUG under network load with gianfar
Submitter	: Michael Guntsche <mike-Z92qn3yYq0hWk0Htik3J/w@public.gmane.org>
Date		: 2009-05-03 13:36 (14 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D0fd56bb5be6455d0d42241e65aed057244665e5e
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124135824600924&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13285
Subject		: INTELFB: Colors display incorrectly
Submitter	: Dean Menezes <samanddeanus-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
Date		: 2009-05-12 01:40 (5 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13250
Subject		: Side channel of Intel HDA chip doesn't work anymore, did wor=
k with 2.6.29
Submitter	: Andreas Juch <kernel-bt-Sk8biX5uX1I@public.gmane.org>
Date		: 2009-05-05 10:14 (12 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13245
Subject		: possible circular locking dependency detected
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-05-04 16:56 (13 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13188
Subject		: horizontal strips of the screen frozen
Submitter	: Justin Madru <jdm64-u1xxEuL7cY4AvxtiuMwx3w@public.gmane.org>
Date		: 2009-04-24 20:59 (23 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D280b713b5b0fd84cf2469098aee88acbb5de859c
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124060685315937&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13180
Subject		: 2.6.30-rc2: WARNING at i915_gem.c for i915_gem_idle
Submitter	: Niel Lambrechts <niel.lambrechts-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-04-21 21:35 (26 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124034980819102&w=3D=
4
		  http://lkml.org/lkml/2009/4/27/290


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13179
Subject		: CD-R: wodim intermittent failures
Submitter	: Andy Isaacson <adi-3HqRAUrWAWyGglJvpFV4uA@public.gmane.org>
Date		: 2009-04-21 1:52 (26 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124027879214231&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13177
Subject		: 2.6.30-rc2-git7 build problem
Submitter	: Martin Knoblauch <spamtrap-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
Date		: 2009-04-21 13:39 (26 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124032163602132&w=3D=
4
		  http://lkml.org/lkml/2009/4/27/56


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13171
Subject		: 2.6.30-rc2 + xorg-intel-2.7.0 + DRM_I915_KMS =3D corruption
Submitter	: Alex Bennee <kernel-hacker-jriKODhXDevQT0dZR+AlfA@public.gmane.org>
Date		: 2009-04-19 6:27 (28 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124022460014812&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13156
Subject		: keyboard backlight brightness up/down keys doesn't work
Submitter	: Thomas Meyer <thomas-VsYtu1Qij5c@public.gmane.org>
Date		: 2009-04-23 20:46 (24 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13148
Subject		: resume after suspend-to-ram broken on Sony Vaio VGN-SR19VN w=
hen sony-laptop driver present
Submitter	: fanderay <fanderay4-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Date		: 2009-04-22 14:39 (25 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13126
Subject		: BUG: MAX_LOCKDEP_ENTRIES too low! when mounting rootfs
Submitter	: Alexander Beregalov <a.beregalov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-04-15 12:43 (32 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123979949820538&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13119
Subject		: Trouble with make-install from a NFS mount
Submitter	: Gregory Haskins <ghaskins-Et1tbQHTxzrQT0dZR+AlfA@public.gmane.org>
Date		: 2009-04-14 21:32 (33 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123974482327044&w=3D=
4
Handled-By	: H. Peter Anvin <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13118
Subject		: iptables very slow after commit 784544739a25c30637397ace5489=
eeb6e15d7d49
Submitter	: Jeff Chua <jeff.chua.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-04-10 16:05 (37 days old)
References	: http://lkml.org/lkml/2009/4/10/111
		  http://lkml.org/lkml/2009/4/25/83
Handled-By	: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13116
Subject		: Can't boot with nosmp
Submitter	: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Date		: 2009-04-15 4:18 (32 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123976917817920&w=3D=
4
Handled-By	: Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13107
Subject		: LTP 20080131 causes defunct processes w/2.6.30-rc1
Submitter	: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Date		: 2009-04-09 15:43 (38 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Db3bfa0cba867f23365b81658b47efd906830879b
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123929187208953&w=3D=
4
		  http://lkml.org/lkml/2009/4/10/193
Handled-By	: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13069
Subject		: regression in 2.6.29-git3 on SH/Dreamcast
Submitter	: Adrian McMenamin <adrian-TSF8l6Tg6afpT6hvJLqO3U8SxdOydiOw@public.gmane.org>
Date		: 2009-03-29 19:04 (49 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123835353115372&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13068
Subject		: Lockdep warining in inotify_dev_queue_event
Submitter	: Sachin Sant <sachinp-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
Date		: 2009-04-05 12:37 (42 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123893439229272&w=3D=
4


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13125
Subject		: active uvcvideo breaks over suspend
Submitter	: Alan Jenkins <alan-jenkins-cCz0Lq7MMjm9FHfhHBbuYA@public.gmane.org>
Date		: 2009-04-15 10:12 (32 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123979009508840&w=3D=
4
Handled-By	: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Patch		: http://lkml.org/lkml/2009/4/18/5


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13122
Subject		: reiserfs_delete_xattrs: Couldn't delete all xattrs (-13)
Submitter	: Alexander Beregalov <a.beregalov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-04-16 19:23 (31 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dd984561b326cd0fe0d1183d11b9b4fa1d011d21d
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123990989515105&w=3D=
4
Handled-By	: Jeff Mahoney <jeffm-IBi9RG/b67k@public.gmane.org>
Patch		: http://lkml.org/lkml/2009/5/10/91


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13109
Subject		: High latency on /sys/class/thermal
Submitter	: Tiago Sim=C3=B5es Batista <tiagosbatista-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-04-11 14:56 (36 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123946182301248&w=3D=
4
Handled-By	: Zhang Rui <rui.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
		  Alexey Starikovskiy <astarikovskiy-l3A5Bk7waGM@public.gmane.org>
Patch		: http://bugzilla.kernel.org/attachment.cgi?id=3D21061
		  http://bugzilla.kernel.org/attachment.cgi?id=3D21282


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions from 2=
=2E6.29,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D13070

Please let me know if there are any Bugzilla entries that should be add=
ed to
the list in there.

Thanks,
Rafael
