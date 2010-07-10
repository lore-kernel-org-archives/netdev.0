From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.35-rc4-git4: Reported regressions 2.6.33 -> 2.6.34
Date: Sat, 10 Jul 2010 02:24:54 +0200 (CEST)
Message-ID: <xkNyyYrLiTN.A.s_G.7p7NMB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maciej Rutecki <maciej.rutecki@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.freedesktop.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:34493 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753211Ab0GJAXt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 20:23:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NOTES:
 * This list seems to be shrinking at last.
 * The bug entries with the NEEDINFO status will be closed next round i=
f the
   reporters don't follow up.]

This message contains a list of some post-2.6.33 regressions introduced=
 before
2.6.34, for which there are no fixes in the mainline known to the track=
ing team.
If any of them have been fixed already, please let us know.

If you know of any other unresolved post-2.6.33 regressions, please let=
 us know
either and we'll add them to the list.  Also, please let us know if any
of the entries below are invalid.

Each entry from the list will be sent additionally in an automatic repl=
y to
this message with CCs to the people involved in reporting and handling =
the
issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2010-07-10      122       25          24
  2010-06-21      114       36          28
  2010-06-13      111       40          34
  2010-05-09       80       27          24
  2010-05-04       76       26          22
  2010-04-20       64       35          34
  2010-04-07       48       35          33
  2010-03-21       15       13          10


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16357
Subject		: acpi-cpufreq fails to load (No such device)
Submitter	: Ambroz Bizjak <ambrop7@gmail.com>
Date		: 2010-07-09 09:40 (1 days old)
Handled-By	: Thomas Renninger <trenn@suse.de>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16348
Subject		: kswapd continuously active when doing IO
Submitter	: Marius Tolzmann <tolzmann@molgen.mpg.de>
Date		: 2010-07-07 10:58 (3 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16320
Subject		: iwl3945 crashes, seems to be disconnecting from the PCI bus
Submitter	: Satish <eerpini@gmail.com>
Date		: 2010-07-01 08:24 (9 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16318
Subject		: macbook pro 5,1 does not boot with acpi
Submitter	:  <syamajala@gmail.com>
Date		: 2010-06-30 13:38 (10 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16300
Subject		: [2.6.34 regression] mplayer gets out of sync due to problems=
 with ALSA
Submitter	: Artem S. Tashkinov <t.artem@mailcity.com>
Date		: 2010-06-26 20:39 (14 days old)
Handled-By	: Takashi Iwai <tiwai@suse.de>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16270
Subject		: Image is a hit-or-a-miss. Often displayed green+purple
Submitter	: Vish <drkvi-a@yahoo.com>
Date		: 2010-06-22 10:47 (18 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/acef4a407ed6e0a9ed87a27=
47be592fe49e64bdd
Handled-By	: Jean-Francois Moine <moinejf@free.fr>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16233
Subject		: Fwd: [2.6.34] INFO: task rsync:20019 blocked for more than 1=
20 seconds.
Submitter	: Jan De Luyck <mailinglists+linuxkernel_20080830@kcore.org>
Date		: 2010-06-14 19:49 (26 days old)
Message-ID	: <AANLkTimutyh3WIALv3NIxA8Xt5JtU6tp4EWOnuSqhdyD@mail.gmail.=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127654498016377&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16207
Subject		: Suspend and VT switch hangs since 2.6.34
Submitter	: Tino Keitel <tino.keitel+xorg@tikei.de>
Date		: 2010-06-09 17:53 (31 days old)
Message-ID	: <20100609175356.GA17332@x61.home>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127610606214060&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16206
Subject		: PROBLEM: PPP and other serial port related application hangs=
 in kernel space
Submitter	: Ales Teska <ales.teska@gmail.com>
Date		: 2010-06-09 20:46 (31 days old)
Message-ID	: <900E3B14-5B92-4A37-9581-049DB40F4D1C@gmail.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127611640301071&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16170
Subject		: Leadtek Winfast DTV Dongle (STK7700P based) is not working i=
n 2.6.34
Submitter	:  <macjariel@gmail.com>
Date		: 2010-06-09 11:11 (31 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16158
Subject		: winxp guest hangs after idle for ~30 minutes
Submitter	:  <brimhall@pobox.com>
Date		: 2010-06-08 17:52 (32 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16139
Subject		: wait_even_interruptible_timeout(), signal, spin_lock() =3D s=
ystem hang
Submitter	: Shirish Pargaonkar <shirishpargaonkar@gmail.com>
Date		: 2010-05-28 16:44 (43 days old)
Message-ID	: <AANLkTiliRFydAhxH2-Dp1RKuz6sq7vgWIcMvLMi68ftg@mail.gmail.=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127506510328758&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16137
Subject		: Ooops in BTRFS in 2.6.34 / x86_64 when mounting subvolume by=
 name
Submitter	: armin walland <a.walland@focusmr.com>
Date		: 2010-05-27 12:27 (44 days old)
Message-ID	: <201005271428.01239.a.walland@focusmr.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127496434110736&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16097
Subject		: 2.6.34 on Samsung P460: reset after "Waiting for /dev to be =
fully populated"
Submitter	: Harald Dunkel <harald.dunkel@aixigo.de>
Date		: 2010-05-25 9:12 (46 days old)
Message-ID	: <4BFB947E.9080509@aixigo.de>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127477877432254&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16082
Subject		: host panic on kernel 2.6.34
Submitter	: Hao, Xudong <xudong.hao@intel.com>
Date		: 2010-05-24 8:23 (47 days old)
Message-ID	: <BC00F5384FCFC9499AF06F92E8B78A9E04DCCCE242@shsmsx502.ccr.=
corp.intel.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127468951208864&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16050
Subject		: The ibmcam driver is not working
Submitter	: Bill Davidsen <davidsen@tmr.com>
Date		: 2010-05-25 23:02 (46 days old)
Handled-By	: Hans de Goede <hdegoede@redhat.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16035
Subject		: Incorrect initial resolution of (external) vga monitor with =
KMS
Submitter	:  <andreas.eckstein@gmx.net>
Date		: 2010-05-23 12:28 (48 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15977
Subject		: WARNING: at lib/dma-debug.c:866 check_for_stack
Submitter	: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date		: 2010-05-14 8:56 (57 days old)
Message-ID	: <AANLkTikyx2eaxaiUCFDSfpmn1UG0t2GOxArz6F4wp1LJ@mail.gmail.=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127382742729825&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15912
Subject		: Audio/video sync and crackling issues with snd-hda-intel (AD=
1981 codec)
Submitter	: =C3=98yvind Stegard <oyvinst@ifi.uio.no>
Date		: 2010-05-05 16:20 (66 days old)
Handled-By	: Jaroslav Kysela <perex@perex.cz>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15862
Subject		: 2.6.34-rc4/5: iwlagn unusable until reload
Submitter	: Nico Schottelius <nico-linux-20100427@schottelius.org>
Date		: 2010-04-27 7:49 (74 days old)
Message-ID	: <20100427074934.GB3261@ikn.schottelius.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127235784004839&w=3D=
2
Handled-By	: Johannes Berg <johannes@sipsolutions.net>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15805
Subject		: reiserfs locking
Submitter	: Alexander Beregalov <a.beregalov@gmail.com>
Date		: 2010-04-15 21:02 (86 days old)
Message-ID	: <t2ka4423d671004151402n7b2dc425mdc9c6bb9640d63fb@mail.gmai=
l.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127136535323933&w=3D=
2
Handled-By	: Frederic Weisbecker <fweisbec@gmail.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15704
Subject		: [r8169] WARNING: at net/sched/sch_generic.c
Submitter	: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Date		: 2010-03-31 10:21 (101 days old)
Message-ID	: <20100331102142.GA3294@swordfish.minsk.epam.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127003090406108&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15673
Subject		: 2.6.34-rc2: "ima_dec_counts: open/free imbalance"?
Submitter	: Thomas Meyer <thomas@m3y3r.de>
Date		: 2010-03-28 11:31 (104 days old)
Message-ID	: <1269775909.5301.4.camel@localhost.localdomain>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126977593326800&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15664
Subject		: Graphics hang and kernel backtrace when starting Azureus wit=
h Compiz enabled
Submitter	: Alex Villacis Lasso <avillaci@ceibo.fiec.espol.edu.ec>
Date		: 2010-04-01 01:09 (100 days old)


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16007
Subject		: x86/pci Oops with CONFIG_SND_HDA_INTEL
Submitter	: Graham Ramsey <ramsey.graham@ntlworld.com>
Date		: 2010-05-19 17:09 (52 days old)
Handled-By	: Yinghai Lu <yinghai@kernel.org>
		  Bjorn Helgaas <bjorn.helgaas@hp.com>
Patch		: https://patchwork.kernel.org/patch/105662/


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions introd=
uced
between 2.6.33 and 2.6.34, unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D15310

Please let the tracking teak know if there are any Bugzilla entries tha=
t
should be added to the list in there.

Thanks!

