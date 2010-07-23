From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.35-rc6: Reported regressions 2.6.33 -> 2.6.34
Date: Fri, 23 Jul 2010 14:11:49 +0200 (CEST)
Message-ID: <wQMMFC59mnE.A.v-E.iUYSMB@chimera>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
  2010-07-23      128       27          25
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

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16388
Subject		: i915 drm BUG: unable to handle kernel paging request at a5e8=
9046
Submitter	:  <lists@clanduggan.org>
Date		: 2010-07-14 16:59 (10 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16377
Subject		: X.org crash while running a OpenGL composited KDE 4.4.4 sess=
ion with Radeon KMS
Submitter	: Martin Steigerwald <Martin@Lichtvoll.de>
Date		: 2010-07-13 12:41 (11 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16376
Subject		: random - possibly Radeon DRM KMS related - freezes
Submitter	: Martin Steigerwald <Martin@Lichtvoll.de>
Date		: 2010-07-13 09:24 (11 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16371
Subject		: Regression 2.6.33->2.6.34: OOPS at boot, kmalloc corruption?
Submitter	: Torsten Kaiser <just.for.lkml@googlemail.com>
Date		: 2010-07-11 18:55 (13 days old)
Message-ID	: <AANLkTimVSZ584-dTIJFalTStvT1kPBQmnDdgUTsoSFQT@mail.gmail.=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127887455203944&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16361
Subject		: KMS not working on Radeon Mobility 3430
Submitter	: Ruslan <ruslan.st@gmail.com>
Date		: 2010-07-10 13:32 (14 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/d594e46ace22afa1621254f=
6f669e65430048153


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16357
Subject		: acpi-cpufreq fails to load (No such device) if CONFIG_SMP=3D=
n
Submitter	: Ambroz Bizjak <ambrop7@gmail.com>
Date		: 2010-07-09 09:40 (15 days old)
Handled-By	: Thomas Renninger <trenn@suse.de>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16348
Subject		: kswapd continuously active when doing IO
Submitter	: Marius Tolzmann <tolzmann@molgen.mpg.de>
Date		: 2010-07-07 10:58 (17 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16320
Subject		: iwl3945 crashes, seems to be disconnecting from the PCI bus
Submitter	: Satish <eerpini@gmail.com>
Date		: 2010-07-01 08:24 (23 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16300
Subject		: [2.6.34 regression] mplayer gets out of sync due to problems=
 with ALSA
Submitter	: Artem S. Tashkinov <t.artem@mailcity.com>
Date		: 2010-06-26 20:39 (28 days old)
Handled-By	: Takashi Iwai <tiwai@suse.de>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16270
Subject		: Image is a hit-or-a-miss. Often displayed green+purple
Submitter	: Vish <drkvi-a@yahoo.com>
Date		: 2010-06-22 10:47 (32 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/acef4a407ed6e0a9ed87a27=
47be592fe49e64bdd
Handled-By	: Jean-Francois Moine <moinejf@free.fr>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16233
Subject		: Fwd: [2.6.34] INFO: task rsync:20019 blocked for more than 1=
20 seconds.
Submitter	: Jan De Luyck <mailinglists+linuxkernel_20080830@kcore.org>
Date		: 2010-06-14 19:49 (40 days old)
Message-ID	: <AANLkTimutyh3WIALv3NIxA8Xt5JtU6tp4EWOnuSqhdyD@mail.gmail.=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127654498016377&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16207
Subject		: Suspend and VT switch hangs since 2.6.34
Submitter	: Tino Keitel <tino.keitel+xorg@tikei.de>
Date		: 2010-06-09 17:53 (45 days old)
Message-ID	: <20100609175356.GA17332@x61.home>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127610606214060&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16206
Subject		: PROBLEM: PPP and other serial port related application hangs=
 in kernel space
Submitter	: Ales Teska <ales.teska@gmail.com>
Date		: 2010-06-09 20:46 (45 days old)
Message-ID	: <900E3B14-5B92-4A37-9581-049DB40F4D1C@gmail.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127611640301071&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16170
Subject		: Leadtek Winfast DTV Dongle (STK7700P based) is not working i=
n 2.6.34
Submitter	:  <macjariel@gmail.com>
Date		: 2010-06-09 11:11 (45 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16139
Subject		: wait_even_interruptible_timeout(), signal, spin_lock() =3D s=
ystem hang
Submitter	: Shirish Pargaonkar <shirishpargaonkar@gmail.com>
Date		: 2010-05-28 16:44 (57 days old)
Message-ID	: <AANLkTiliRFydAhxH2-Dp1RKuz6sq7vgWIcMvLMi68ftg@mail.gmail.=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127506510328758&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16137
Subject		: Ooops in BTRFS in 2.6.34 / x86_64 when mounting subvolume by=
 name
Submitter	: armin walland <a.walland@focusmr.com>
Date		: 2010-05-27 12:27 (58 days old)
Message-ID	: <201005271428.01239.a.walland@focusmr.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127496434110736&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16097
Subject		: 2.6.34 on Samsung P460: reset after "Waiting for /dev to be =
fully populated"
Submitter	: Harald Dunkel <harald.dunkel@aixigo.de>
Date		: 2010-05-25 9:12 (60 days old)
Message-ID	: <4BFB947E.9080509@aixigo.de>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127477877432254&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16082
Subject		: host panic on kernel 2.6.34
Submitter	: Hao, Xudong <xudong.hao@intel.com>
Date		: 2010-05-24 8:23 (61 days old)
Message-ID	: <BC00F5384FCFC9499AF06F92E8B78A9E04DCCCE242@shsmsx502.ccr.=
corp.intel.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127468951208864&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16035
Subject		: Incorrect initial resolution of (external) vga monitor with =
KMS
Submitter	:  <andreas.eckstein@gmx.net>
Date		: 2010-05-23 12:28 (62 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15977
Subject		: WARNING: at lib/dma-debug.c:866 check_for_stack
Submitter	: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date		: 2010-05-14 8:56 (71 days old)
Message-ID	: <AANLkTikyx2eaxaiUCFDSfpmn1UG0t2GOxArz6F4wp1LJ@mail.gmail.=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127382742729825&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15912
Subject		: Audio/video sync and crackling issues with snd-hda-intel (AD=
1981 codec)
Submitter	: =C3=98yvind Stegard <oyvinst@ifi.uio.no>
Date		: 2010-05-05 16:20 (80 days old)
Handled-By	: Jaroslav Kysela <perex@perex.cz>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15862
Subject		: 2.6.34-rc4/5: iwlagn unusable until reload
Submitter	: Nico Schottelius <nico-linux-20100427@schottelius.org>
Date		: 2010-04-27 7:49 (88 days old)
Message-ID	: <20100427074934.GB3261@ikn.schottelius.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127235784004839&w=3D=
2
Handled-By	: Johannes Berg <johannes@sipsolutions.net>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15704
Subject		: [r8169] WARNING: at net/sched/sch_generic.c
Submitter	: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Date		: 2010-03-31 10:21 (115 days old)
Message-ID	: <20100331102142.GA3294@swordfish.minsk.epam.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127003090406108&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15673
Subject		: 2.6.34-rc2: "ima_dec_counts: open/free imbalance"?
Submitter	: Thomas Meyer <thomas@m3y3r.de>
Date		: 2010-03-28 11:31 (118 days old)
Message-ID	: <1269775909.5301.4.camel@localhost.localdomain>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126977593326800&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15664
Subject		: Graphics hang and kernel backtrace when starting Azureus wit=
h Compiz enabled
Submitter	: Alex Villacis Lasso <avillaci@ceibo.fiec.espol.edu.ec>
Date		: 2010-04-01 01:09 (114 days old)


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16111
Subject		: hostap_pci: infinite registered netdevice wifi0
Submitter	: Petr Pisar <petr.pisar@atlas.cz>
Date		: 2010-06-02 20:55 (52 days old)
Handled-By	: Tim Gardner <tim.gardner@canonical.com>
		   Petr Pisar <petr.pisar@atlas.cz>
Patch		: https://patchwork.kernel.org/patch/105008/
		  https://bugzilla.kernel.org/attachment.cgi?id=3D27109


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16007
Subject		: x86/pci Oops with CONFIG_SND_HDA_INTEL
Submitter	: Graham Ramsey <ramsey.graham@ntlworld.com>
Date		: 2010-05-19 17:09 (66 days old)
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
