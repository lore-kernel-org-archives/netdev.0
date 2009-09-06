From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.31-rc9: Reported regressions 2.6.29 -> 2.6.30
Date: Sun,  6 Sep 2009 20:10:03 +0200 (CEST)
Message-ID: <aIL9jMAYJnG.A.WjH.M3BpKB@chimera>
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
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This message contains a list of some regressions introduced between 2.6=
=2E29 and
2.6.30, for which there are no fixes in the mainline I know of.  If any=
 of them
have been fixed already, please let me know.

If you know of any other unresolved regressions introduced between 2.6.=
29
and 2.6.30, please let me know either and I'll add them to the list.
Also, please let me know if any of the entries below are invalid.

Each entry from the list will be sent additionally in an automatic repl=
y to
this message with CCs to the people involved in reporting and handling =
the
issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2009-09-06      153       27          27
  2009-08-26      152       33          30
  2009-08-20      150       35          32
  2009-08-10      148       39          37
  2009-08-02      145       44          39
  2009-07-27      143       48          45
  2009-07-07      138       50          46
  2009-06-29      133       46          43
  2009-06-07      110       35          31
  2009-05-31      100       32          27
  2009-05-24       92       34          27
  2009-05-16       81       36          33
  2009-04-25       55       36          26
  2009-04-17       37       35          28


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14105
Subject		: pcmcia cards stop working after resuming from snapshot cycle=
 (hibernation)
Submitter	: Martin Steigerwald <Martin-SpPJhY7q8xqazgQtNeiOUg@public.gmane.org>
Date		: 2009-09-01 19:44 (6 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14049
Subject		: joydev: blacklist digitizers avoids recognition of Saitek X5=
2 joysticks
Submitter	: Janos Laube <janos.dev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-08-24 14:18 (14 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dd07a9cba6be5c0e947afc1014b5a62182a86f1f1


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13958
Subject		: ath5k Atheros AR5001 low signal
Submitter	: Marco Siviero <darker1985-LhojQA2xIZ1eoWH0uzbU5w@public.gmane.org>
Date		: 2009-08-10 15:03 (28 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13949
Subject		: XFS regression
Submitter	: Justin Piszcz <jpiszcz-BP4nVm5VUdNhbmWW9KSYcQ@public.gmane.org>
Date		: 2009-08-08 8:39 (30 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124972079229959&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13898
Subject		: Intel 3945ABG - problems on 2.6.30.X
Submitter	: dienet <dienet-IjDXvh/HVVUAvxtiuMwx3w@public.gmane.org>
Date		: 2009-07-31 15:17 (38 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124905346729959&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13797
Subject		: iBook G4 doesn't suspend since 2ed8d2b3a8
Submitter	: J=C3=B6rg Sommer <joerg-au2b9oQwubsjnolme5KbmQ@public.gmane.org>
Date		: 2009-07-18 20:18 (51 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13795
Subject		: abnormal boot and no suspend due to 'async' (fastboot)
Submitter	: Rafal Kaczynski <fscnoboot-5tc4TXWwyLM@public.gmane.org>
Date		: 2009-07-18 17:19 (51 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13780
Subject		: NULL pointer dereference loading powernowk8
Submitter	: Kurt Roeckx <kurt-burXGKnpAKGzQB+pC5nmwQ@public.gmane.org>
Date		: 2009-07-15 18:00 (54 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13770
Subject		: System freeze on XFS filesystem recovery on an external disk
Submitter	: Jean-Luc Coulon <jean.luc.coulon-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-07-14 10:31 (55 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13739
Subject		: 2.6.30 leaking keys on console switch
Submitter	: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>
Date		: 2009-07-07 8:44 (62 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124695628924382&w=3D=
4
Handled-By	: Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13682
Subject		: The webcam stopped working when upgrading from 2.6.29 to 2.6=
=2E30
Submitter	: Nathanael Schaeffer <nathanael.schaeffer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-06-30 13:34 (69 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13583
Subject		: pdflush uses 5% CPU on otherwise idle system
Submitter	: Paul Martin <pm-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org>
Date		: 2009-06-19 13:33 (80 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13581
Subject		: ath9k doesn't work with newer kernels
Submitter	: Matteo <rootkit85-whZMOeQn8C0@public.gmane.org>
Date		: 2009-06-19 12:04 (80 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13564
Subject		: random general protection fault at boot time caused by khubd=
=2E
Submitter	: Pauli <suokkos-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-06-18 12:44 (81 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13558
Subject		: Tracelog during resume
Submitter	: Cijoml Cijomlovic Cijomlov <cijoml-VIXq6x/3rUk@public.gmane.org>
Date		: 2009-06-17 11:32 (82 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13512
Subject		: D43 on 2.6.30 doesn't suspend anymore
Submitter	: Daniel Smolik <marvin-0pWKB23IDFjrBKCeMvbIDA@public.gmane.org>
Date		: 2009-06-11 20:12 (88 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13502
Subject		: GPE storm causes polling mode, which causes /proc/acpi/batte=
ry read to take 4 seconds - MacBookPro4,1
Submitter	:  <sveina-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-06-10 20:04 (89 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13408
Subject		: Performance regression in 2.6.30-rc7
Submitter	: Diego Calleja <diegocg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-05-30 18:51 (100 days old)
References	: http://lkml.org/lkml/2009/5/30/146


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13407
Subject		: adb trackpad disappears after suspend to ram
Submitter	: Jan Scholz <scholz-wOpdxP1gw6Cc+IqHO83+wjjhTm2NLCe8@public.gmane.org>
Date		: 2009-05-28 7:59 (102 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D2ed8d2b3a81bdbb0418301628ccdb008ac9f40b7
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124349762314976&w=3D=
4
Handled-By	: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13401
Subject		: pktcdvd writing is really slow with CFQ scheduler (bisected)
Submitter	: Laurent Riffard <laurent.riffard-GANU6spQydw@public.gmane.org>
Date		: 2009-05-28 18:43 (102 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13362
Subject		: rt2x00: slow wifi with correct basic rate bitmap
Submitter	: Alejandro Riveira <ariveira-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-05-22 13:32 (108 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13351
Subject		: 2.6.30 - 2.6.31 corrupts my system after suspend resume with=
 readonly mounted hard disk
Submitter	:  <unggnu-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Date		: 2009-05-20 14:09 (110 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D78a8b35bc7abf8b8333d6f625e08c0f7cc1c3742
Handled-By	: Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13341
Subject		: Random Oops at boot at loading ip6tables rules
Submitter	:  <patrick-nxAOmsU53hB6lmGzAMPh1A@public.gmane.org>
Date		: 2009-05-19 09:08 (111 days old)
Handled-By	: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13328
Subject		: b44: eth0: BUG! Timeout waiting for bit 00000002 of register=
 42c to clear.
Submitter	: Francis Moreau <francis.moro-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-05-03 16:22 (127 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124136778012280&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13318
Subject		: AGP doesn't work anymore on nforce2
Submitter	: Karsten Mehrhoff <kawime-Mmb7MZpHnFY@public.gmane.org>
Date		: 2009-04-30 8:51 (130 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D59de2bebabc5027f93df999d59cc65df591c3e6e
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124108156417560&w=3D=
4
Handled-By	: Shaohua Li <shaohua.li-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13306
Subject		: hibernate slow on _second_ run
Submitter	: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date		: 2009-05-14 09:34 (116 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13180
Subject		: 2.6.30-rc2: WARNING at i915_gem.c for i915_gem_idle
Submitter	: Niel Lambrechts <niel.lambrechts-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-04-21 21:35 (139 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124034980819102&w=3D=
4
		  http://lkml.org/lkml/2009/4/27/290


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions introd=
uced
between 2.6.29 and 2.6.30, unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D13070

Please let me know if there are any Bugzilla entries that should be add=
ed to
the list in there.

Thanks,
Rafael
