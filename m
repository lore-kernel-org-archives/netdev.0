From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.31-rc5-git5: Reported regressions 2.6.29 -> 2.6.30
Date: Sun,  9 Aug 2009 23:07:11 +0200 (CEST)
Message-ID: <YCu3FOC0QrC.A.MaE.RD2fKB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.sourceforge.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754281AbZHJABJ@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
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

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13949
Subject		: XFS regression
Submitter	: Justin Piszcz <jpiszcz@lucidpixels.com>
Date		: 2009-08-08 8:39 (2 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124972079229959&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13945
Subject		: Kernel freezes dual pentium-3 system
Submitter	: Martin Rogge <marogge@onlinehome.de>
Date		: 2009-08-03 16:25 (7 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124931667320530&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13898
Subject		: Intel 3945ABG - problems on 2.6.30.X
Submitter	: dienet <dienet@poczta.fm>
Date		: 2009-07-31 15:17 (10 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124905346729959&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13797
Subject		: iBook G4 doesn't suspend since 2ed8d2b3a8
Submitter	: J=C3=B6rg Sommer <joerg@alea.gnuu.de>
Date		: 2009-07-18 20:18 (23 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13795
Subject		: abnormal boot and no suspend due to 'async' (fastboot)
Submitter	: Rafal Kaczynski <fscnoboot@wp.pl>
Date		: 2009-07-18 17:19 (23 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13780
Subject		: NULL pointer dereference loading powernowk8
Submitter	: Kurt Roeckx <kurt@roeckx.be>
Date		: 2009-07-15 18:00 (26 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13770
Subject		: System freeze on XFS filesystem recovery on an external disk
Submitter	: Jean-Luc Coulon <jean.luc.coulon@gmail.com>
Date		: 2009-07-14 10:31 (27 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13739
Subject		: 2.6.30 leaking keys on console switch
Submitter	: Andi Kleen <andi@firstfloor.org>
Date		: 2009-07-07 8:44 (34 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124695628924382&w=3D=
4
Handled-By	: Jiri Kosina <jkosina@suse.cz>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13694
Subject		: i915 phantom TV
Submitter	: Maciek J=C3=B3ziewicz <mjoziew@gmail.com>
Date		: 2009-07-02 12:26 (39 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13682
Subject		: The webcam stopped working when upgrading from 2.6.29 to 2.6=
=2E30
Submitter	: Nathanael Schaeffer <nathanael.schaeffer@gmail.com>
Date		: 2009-06-30 13:34 (41 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13660
Subject		: Crashes during boot on 2.6.30 / 2.6.31-rc, random programs
Submitter	: Joao Correia <joaomiguelcorreia@gmail.com>
Date		: 2009-06-27 16:07 (44 days old)
References	: http://lkml.org/lkml/2009/6/27/95


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13646
Subject		: warn_on tty_io.c, broken bluetooth
Submitter	: Pavel Machek <pavel@ucw.cz>
Date		: 2009-06-19 17:05 (52 days old)
References	: http://lkml.org/lkml/2009/6/19/187


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13638
Subject		: rt2870 driver is broken for (some) cards
Submitter	: jakob gruber <jakob.gruber@kabelnet.at>
Date		: 2009-06-27 17:33 (44 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13634
Subject		: [drm:drm_wait_vblank] *ERROR* failed to acquire vblank count=
er, -22
Submitter	: Cijoml Cijomlovic Cijomlov <cijoml@volny.cz>
Date		: 2009-06-27 07:02 (44 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13621
Subject		: xfs hangs with assertion failed
Submitter	: Johannes Engel <jcnengel@googlemail.com>
Date		: 2009-06-25 10:07 (46 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13620
Subject		: acpi_enforce_resources broken - conflicting i2c module loade=
d on some EeePCs
Submitter	: Alan Jenkins <alan-jenkins@tuffmail.co.uk>
Date		: 2009-06-25 08:31 (46 days old)
References	: <http://lists.alioth.debian.org/pipermail/debian-eeepc-dev=
el/2009-June/002316.html>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13583
Subject		: pdflush uses 5% CPU on otherwise idle system
Submitter	: Paul Martin <pm@debian.org>
Date		: 2009-06-19 13:33 (52 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13581
Subject		: ath9k doesn't work with newer kernels
Submitter	: Matteo <rootkit85@yahoo.it>
Date		: 2009-06-19 12:04 (52 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13564
Subject		: random general protection fault at boot time caused by khubd=
=2E
Submitter	: Pauli <suokkos@gmail.com>
Date		: 2009-06-18 12:44 (53 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13558
Subject		: Tracelog during resume
Submitter	: Cijoml Cijomlovic Cijomlov <cijoml@volny.cz>
Date		: 2009-06-17 11:32 (54 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13514
Subject		: acer_wmi causes stack corruption
Submitter	: Rus <harbour@sfinx.od.ua>
Date		: 2009-06-12 08:13 (59 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13512
Subject		: D43 on 2.6.30 doesn't suspend anymore
Submitter	: Daniel Smolik <marvin@mydatex.cz>
Date		: 2009-06-11 20:12 (60 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13502
Subject		: GPE storm causes polling mode, which causes /proc/acpi/batte=
ry read to take 4 seconds - MacBookPro4,1
Submitter	:  <sveina@gmail.com>
Date		: 2009-06-10 20:04 (61 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13408
Subject		: Performance regression in 2.6.30-rc7
Submitter	: Diego Calleja <diegocg@gmail.com>
Date		: 2009-05-30 18:51 (72 days old)
References	: http://lkml.org/lkml/2009/5/30/146


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13407
Subject		: adb trackpad disappears after suspend to ram
Submitter	: Jan Scholz <scholz@fias.uni-frankfurt.de>
Date		: 2009-05-28 7:59 (74 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D2ed8d2b3a81bdbb0418301628ccdb008ac9f40b7
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124349762314976&w=3D=
4
Handled-By	: Rafael J. Wysocki <rjw@sisk.pl>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13401
Subject		: pktcdvd writing is really slow with CFQ scheduler (bisected)
Submitter	: Laurent Riffard <laurent.riffard@free.fr>
Date		: 2009-05-28 18:43 (74 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13374
Subject		: reiserfs blocked for more than 120secs
Submitter	: Harald Dunkel <harald.dunkel@t-online.de>
Date		: 2009-05-23 8:52 (79 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124306880410811&w=3D=
4
		  http://lkml.org/lkml/2009/5/29/389


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13373
Subject		: fbcon, intelfb, i915: INFO: possible circular locking depend=
ency detected
Submitter	: Miles Lane <miles.lane@gmail.com>
Date		: 2009-05-23 5:08 (79 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124305538130702&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13362
Subject		: rt2x00: slow wifi with correct basic rate bitmap
Submitter	: Alejandro Riveira <ariveira@gmail.com>
Date		: 2009-05-22 13:32 (80 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13351
Subject		: 2.6.30 corrupts my system after suspend resume with readonly=
 mounted hard disk
Submitter	:  <unggnu@googlemail.com>
Date		: 2009-05-20 14:09 (82 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D78a8b35bc7abf8b8333d6f625e08c0f7cc1c3742
Handled-By	: Yinghai Lu <yinghai@kernel.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13341
Subject		: Random Oops at boot at loading ip6tables rules
Submitter	:  <patrick@ostenberg.de>
Date		: 2009-05-19 09:08 (83 days old)
Handled-By	: Rusty Russell <rusty@rustcorp.com.au>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13328
Subject		: b44: eth0: BUG! Timeout waiting for bit 00000002 of register=
 42c to clear.
Submitter	: Francis Moreau <francis.moro@gmail.com>
Date		: 2009-05-03 16:22 (99 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124136778012280&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13318
Subject		: AGP doesn't work anymore on nforce2
Submitter	: Karsten Mehrhoff <kawime@gmx.de>
Date		: 2009-04-30 8:51 (102 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D59de2bebabc5027f93df999d59cc65df591c3e6e
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124108156417560&w=3D=
4
Handled-By	: Shaohua Li <shaohua.li@intel.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13306
Subject		: hibernate slow on _second_ run
Submitter	: Johannes Berg <johannes@sipsolutions.net>
Date		: 2009-05-14 09:34 (88 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13219
Subject		: Intel 440GX: Since kernel 2.6.30-rc1, computers hangs random=
ly but not with kernel <=3D 2.6.29.6
Submitter	: David Hill <hilld@binarystorm.net>
Date		: 2009-05-01 16:57 (101 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13180
Subject		: 2.6.30-rc2: WARNING at i915_gem.c for i915_gem_idle
Submitter	: Niel Lambrechts <niel.lambrechts@gmail.com>
Date		: 2009-04-21 21:35 (111 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124034980819102&w=3D=
4
		  http://lkml.org/lkml/2009/4/27/290


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13109
Subject		: High latency on /sys/class/thermal
Submitter	: Tiago Sim=C3=B5es Batista <tiagosbatista@gmail.com>
Date		: 2009-04-11 14:56 (121 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D123946182301248&w=3D=
4
Handled-By	: Zhang Rui <rui.zhang@intel.com>
		  Alexey Starikovskiy <astarikovskiy@suse.de>


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13389
Subject		: Warning 'Invalid throttling state, reset' gets displayed whe=
n it should not be
Submitter	: Frans Pop <elendil@planet.nl>
Date		: 2009-05-26 15:24 (76 days old)
Handled-By	: Frans Pop <elendil@planet.nl>
Patch		: http://bugzilla.kernel.org/attachment.cgi?id=3D21671
		  http://bugzilla.kernel.org/attachment.cgi?id=3D21672


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13319
Subject		: Page allocation failures with b43 and p54usb
Submitter	: Larry Finger <Larry.Finger@lwfinger.net>
Date		: 2009-04-29 21:01 (103 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124103897101088&w=3D=
4
		  http://lkml.org/lkml/2009/6/7/136
		  http://lkml.org/lkml/2009/7/26/213
Handled-By	: Johannes Berg <johannes@sipsolutions.net>
		  David Rientjes <rientjes@google.com>
Patch		: http://patchwork.kernel.org/patch/37655/


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
