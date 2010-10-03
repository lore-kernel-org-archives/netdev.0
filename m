From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.36-rc6-git2: Reported regressions 2.6.34 -> 2.6.35
Date: Sun,  3 Oct 2010 23:36:05 +0200 (CEST)
Message-ID: <OjxVjYbf_EJ.A.ReC.pTPqMB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Florian Mickler <florian-sVu6HhrpSfRAfugRpC6u6w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>
To: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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
  2010-10-03      141       21          17
  2010-09-26      139       24          21
  2010-09-20      137       27          25
  2010-09-12      135       26          25
  2010-08-30      124       38          34
  2010-08-01      100       27          23
  2010-07-23       94       33          25
  2010-07-09       79       45          37
  2010-06-21       46       37          26
  2010-06-09       15       13          10


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=19612
Subject		: Computer fails to hibernate - problem idling SMP CPU's
Submitter	:  <tempo444z-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-10-02 22:26 (2 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=19302
Subject		: PROBLEM: kernel crash on USB-modem (Huawei E1750) hangup.
Submitter	: O01eg <O01eg-o+MxOtu4lMCHXe+LvDLADg@public.gmane.org>
Date		: 2010-09-26 19:50 (8 days old)
Message-ID	: <op.vjnn1up1yohvy1@localhost>
References	: http://marc.info/?l=linux-kernel&m=128553111709569&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=18522
Subject		: cdrom drive doesn't detect removal
Submitter	: Maxim Levitsky <maximlevitsky-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-09-12 9:49 (22 days old)
First-Bad-Commit: http://git.kernel.org/linus/6b4517a7913a09d3259bb1d21c9cb300f12294bd
Message-ID	: <1284284969.2928.18.camel@maxim-laptop>
References	: http://marc.info/?l=linux-kernel&m=128428499013930&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17812
Subject		: Kernel completely frozen when memory is full
Submitter	: Mickey86 <mikael.cordon-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-09-05 13:09 (29 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17261
Subject		: Freezes on bootup
Submitter	: Dan Dart <dandart-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Date		: 2010-08-29 09:00 (36 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16891
Subject		: Kernel panic while loading intel module during boot
Submitter	: Anisse Astier <anisse-fwwRqrJYcP2HXe+LvDLADg@public.gmane.org>
Date		: 2010-08-24 13:19 (41 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16691
Subject		: IPW5100: iwlagn broken with 2.6.34.x to 2.6.35.2 update
Submitter	: Can Celasun <dcelasun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-08-21 08:28 (44 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16614
Subject		: [2.6.35] usb 2.0 em28xx  kernel panic general protection fault: 0000 [#1] SMP          RIP: 0010:[<ffffffffa004fbc5>]  [<ffffffffa004fbc5>] em28xx_isoc_copy_vbi+0x62e/0x812 [em28xx]
Submitter	: Sander Eikelenboom <linux-6SM94LqRVpn6gRhOQ7JHfg@public.gmane.org>
Date		: 2010-08-10 22:12 (55 days old)
Message-ID	: <61936849.20100811001257-6SM94LqRVpn6gRhOQ7JHfg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128152075830927&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16562
Subject		: 2.6.35: cpu_idle bug report / on i7 870 cpu (x86_64)
Submitter	: Justin Piszcz <jpiszcz-BP4nVm5VUdNhbmWW9KSYcQ@public.gmane.org>
Date		: 2010-08-06 22:09 (59 days old)
Message-ID	: <alpine.DEB.2.00.1008061800530.5241-0qmrozcXWo8bm2hyYBkBBg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128113260904048&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16549
Subject		: 2.6.35: suspicious rcu_dereference_check() usage
Submitter	: Vladislav Bolkhovitin <vst-d+Crzxg7Rs0@public.gmane.org>
Date		: 2010-08-04 10:56 (61 days old)
Message-ID	: <4C594740.1090608-d+Crzxg7Rs0@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128091938215177&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16525
Subject		: unexpected high load since 2.6.35
Submitter	: MadLoisae-hi6Y0CQ0nG0@public.gmane.org <MadLoisae-hi6Y0CQ0nG0@public.gmane.org>
Date		: 2010-08-02 20:53 (63 days old)
Message-ID	: <4C573041.1070103-hi6Y0CQ0nG0@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128078243726655&w=2
		  http://lkml.org/lkml/2010/9/14/105
		  http://lkml.org/lkml/2010/9/27/328


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16515
Subject		: [bisected] Radeon rv280 can't boot on kernel 2.6.35.
Submitter	: Albert Gall <ss3vdr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-08-04 16:10 (61 days old)
First-Bad-Commit: http://git.kernel.org/linus/https://bugzilla.kernel.org/attachment.cgi?id=27350
Handled-By	: Alex Deucher <alexdeucher-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16488
Subject		: [i915] Framebuffer ID error after suspend/hibernate leading to X crash
Submitter	: Milan Bouchet-Valat <nalimilan-pqIVbhRXszc@public.gmane.org>
Date		: 2010-08-01 08:55 (64 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16458
Subject		: Bluetooth disabled after resume
Submitter	: AttilaN <attila123456-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-07-25 09:33 (71 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16380
Subject		: Loop devices act strangely in 2.6.35
Submitter	: Artem S. Tashkinov <t.artem-VInPYn6yXxRWk0Htik3J/w@public.gmane.org>
Date		: 2010-07-13 23:21 (83 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16265
Subject		: Why is kslowd accumulating so much CPU time?
Submitter	: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>
Date		: 2010-06-09 18:36 (117 days old)
First-Bad-Commit: http://git.kernel.org/linus/fbf81762e385d3d45acad057b654d56972acf58c
Message-ID	: <E1OMQ88-0002a1-Gb-UK71uKi2zisAobODsErMgNi2O/JbrIOy@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=127610857819033&w=4
		  http://bugs.freedesktop.org/show_bug.cgi?id=29536
Handled-By	: Chris Wilson <chris-Y6uKTt2uX1cEflXRtASbqLVCufUGDwFn@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16221
Subject		: 2.6.35-rc2-git5 -- [drm:drm_mode_getfb] *ERROR* invalid framebuffer id
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-06-11 20:31 (115 days old)
Message-ID	: <AANLkTim0jVRyqkwlGOcrg_XTvUQwcBYfWJX-aRzkkrLG-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=127628828119623&w=2


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17772
Subject		: Unable to locate IOAPIC for GSI *
Submitter	: zersaa <zersaa-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-09-04 21:28 (30 days old)
Handled-By	: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Patch		: https://patchwork.kernel.org/patch/104501/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16462
Subject		: unable to connect to hidden SSID AP on legal channel 13
Submitter	: Daniel J Blueman <daniel.blueman-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-07-25 17:06 (71 days old)
Handled-By	: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=31862


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16312
Subject		: WARNING: at fs/fs-writeback.c:1127 __mark_inode_dirty
Submitter	: Zdenek Kabelac <zdenek.kabelac-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-06-28 9:40 (98 days old)
Message-ID	: <AANLkTin24fr5O4_q5Xbo9Y_NKkEmtcp6Hgmr9_4qXaFz-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=127771804806465&w=2
		  http://lkml.indiana.edu/hypermail/linux/kernel/1007.3/00884.html
Handled-By	: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
		  Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=30282


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16228
Subject		: BUG/boot failure on Dell Precision T3500 (pci/ahci_stop_engine)
Submitter	: Brian Bloniarz <brian.bloniarz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-06-16 17:57 (110 days old)
Handled-By	: Bjorn Helgaas <bjorn.helgaas-VXdhtT5mjnY@public.gmane.org>
Patch		: https://patchwork.kernel.org/patch/189182/
		  https://patchwork.kernel.org/patch/189232/
		  https://patchwork.kernel.org/patch/189242/
		  https://patchwork.kernel.org/patch/189252/


For details, please visit the bug entries and follow the links given in
references.

As you can see, there is a Bugzilla entry for each of the listed regressions.
There also is a Bugzilla entry used for tracking the regressions introduced
between 2.6.34 and 2.6.35, unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=16055

Please let the tracking team know if there are any Bugzilla entries that
should be added to the list in there.

Thanks!

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
