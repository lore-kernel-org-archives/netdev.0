From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.35-rc3: Reported regressions 2.6.33 -> 2.6.34
Date: Mon, 21 Jun 2010 00:32:02 +0200 (CEST)
Message-ID: <g77CuMUl7QI.A.qMH.4ZpHMB@chimera>
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
	DRI <dri-devel@lists.sourceforge.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-acpi-owner@vger.kernel.org
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
  2010-06-21      114       36          28
  2010-06-13      111       40          34
  2010-05-09       80       27          24
  2010-05-04       76       26          22
  2010-04-20       64       35          34
  2010-04-07       48       35          33
  2010-03-21       15       13          10


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16254
Subject		: TCP stream performance regression due to c377411f2494a931ff7=
facdbb3a6839b1266bcf6
Submitter	: Alex,Shi <alex.shi@intel.com>
Date		: 2010-06-18 7:17 (3 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/c377411f2494a931ff7facd=
bb3a6839b1266bcf6
Message-ID	: <1276845448.2118.346.camel@debian>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127684931020672&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16233
Subject		: Fwd: [2.6.34] INFO: task rsync:20019 blocked for more than 1=
20 seconds.
Submitter	: Jan De Luyck <mailinglists+linuxkernel_20080830@kcore.org>
Date		: 2010-06-14 19:49 (7 days old)
Message-ID	: <AANLkTimutyh3WIALv3NIxA8Xt5JtU6tp4EWOnuSqhdyD@mail.gmail.=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127654498016377&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16207
Subject		: Suspend hangs since 2.6.34
Submitter	: Tino Keitel <tino.keitel+xorg@tikei.de>
Date		: 2010-06-09 17:53 (12 days old)
Message-ID	: <20100609175356.GA17332@x61.home>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127610606214060&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16206
Subject		: PROBLEM: PPP and other serial port related application hangs=
 in kernel space
Submitter	: Ales Teska <ales.teska@gmail.com>
Date		: 2010-06-09 20:46 (12 days old)
Message-ID	: <900E3B14-5B92-4A37-9581-049DB40F4D1C@gmail.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127611640301071&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16170
Subject		: Leadtek Winfast DTV Dongle (STK7700P based) is not working i=
n 2.6.34
Submitter	:  <macjariel@gmail.com>
Date		: 2010-06-09 11:11 (12 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16162
Subject		: SSD + sata_nv + btrfs oops
Submitter	: Dave Airlie <airlied@gmail.com>
Date		: 2010-06-01 3:04 (20 days old)
Message-ID	: <AANLkTilqsIdlzZgUf7TMLHYKqHDZoVkcs42vcG8wXKEr@mail.gmail.=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127536149022333&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16158
Subject		: winxp guest hangs after idle for ~30 minutes
Submitter	:  <brimhall@pobox.com>
Date		: 2010-06-08 17:52 (13 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16139
Subject		: wait_even_interruptible_timeout(), signal, spin_lock() =3D s=
ystem hang
Submitter	: Shirish Pargaonkar <shirishpargaonkar@gmail.com>
Date		: 2010-05-28 16:44 (24 days old)
Message-ID	: <AANLkTiliRFydAhxH2-Dp1RKuz6sq7vgWIcMvLMi68ftg@mail.gmail.=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127506510328758&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16137
Subject		: Ooops in BTRFS in 2.6.34 / x86_64 when mounting subvolume by=
 name
Submitter	: armin walland <a.walland@focusmr.com>
Date		: 2010-05-27 12:27 (25 days old)
Message-ID	: <201005271428.01239.a.walland@focusmr.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127496434110736&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16135
Subject		: [BUG] kacpi_notify goes into an infinite loop (luckly it cal=
ls cond_resched)
Submitter	: Steven Rostedt <rostedt@goodmis.org>
Date		: 2010-05-29 1:01 (23 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/fa80945269f312bc609e838=
4302f58b03c916e12
Message-ID	: <1275094882.22648.607.camel@gandalf.stny.rr.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127509490405845&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16111
Subject		: hostap_pci: infinite registered netdevice wifi0
Submitter	: Petr Pisar <petr.pisar@atlas.cz>
Date		: 2010-06-02 20:55 (19 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16097
Subject		: 2.6.34 on Samsung P460: reset after "Waiting for /dev to be =
fully populated"
Submitter	: Harald Dunkel <harald.dunkel@aixigo.de>
Date		: 2010-05-25 9:12 (27 days old)
Message-ID	: <4BFB947E.9080509@aixigo.de>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127477877432254&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16084
Subject		: iwl3945 bug in 2.6.34
Submitter	: Satish Eerpini <eerpini@gmail.com>
Date		: 2010-05-23 6:37 (29 days old)
Message-ID	: <AANLkTik_7rxDBc0TKlAfoYyM5S6Cf_Hyxbr4W5ORnTsq@mail.gmail.=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127459596015626&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16082
Subject		: host panic on kernel 2.6.34
Submitter	: Hao, Xudong <xudong.hao@intel.com>
Date		: 2010-05-24 8:23 (28 days old)
Message-ID	: <BC00F5384FCFC9499AF06F92E8B78A9E04DCCCE242@shsmsx502.ccr.=
corp.intel.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127468951208864&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16050
Subject		: The ibmcam driver is not working
Submitter	: Bill Davidsen <davidsen@tmr.com>
Date		: 2010-05-25 23:02 (27 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16035
Subject		: Incorrect initial resolution of (external) vga monitor with =
KMS
Submitter	:  <andreas.eckstein@gmx.net>
Date		: 2010-05-23 12:28 (29 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16034
Subject		: 2.6.34: dlm: possible circular locking dependency detected
Submitter	: CaT <cat@zip.com.au>
Date		: 2010-05-21 6:59 (31 days old)
Message-ID	: <20100521065933.GH2657@zip.com.au>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127442519608471&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15977
Subject		: WARNING: at lib/dma-debug.c:866 check_for_stack
Submitter	: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date		: 2010-05-14 8:56 (38 days old)
Message-ID	: <AANLkTikyx2eaxaiUCFDSfpmn1UG0t2GOxArz6F4wp1LJ@mail.gmail.=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127382742729825&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15936
Subject		: Suspicious rcu_dereference_check() usage detected during 2.6=
=2E34-rc6 boot on PPC64/p5 processor
Submitter	: Subrata Modak <subrata@linux.vnet.ibm.com>
Date		: 2010-05-06 7:29 (46 days old)
Message-ID	: <1273130279.4898.5.camel@subratamodak.linux.ibm.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127313031922395&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15924
Subject		: kacpid consumes ~100% CPU, system freezes randomly
Submitter	: Jaroslav Kamen=C3=ADk <jaroslav@kamenik.cz>
Date		: 2010-05-06 21:12 (46 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15862
Subject		: 2.6.34-rc4/5: iwlagn unusable until reload
Submitter	: Nico Schottelius <nico-linux-20100427@schottelius.org>
Date		: 2010-04-27 7:49 (55 days old)
Message-ID	: <20100427074934.GB3261@ikn.schottelius.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127235784004839&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15805
Subject		: reiserfs locking
Submitter	: Alexander Beregalov <a.beregalov@gmail.com>
Date		: 2010-04-15 21:02 (67 days old)
Message-ID	: <t2ka4423d671004151402n7b2dc425mdc9c6bb9640d63fb@mail.gmai=
l.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127136535323933&w=3D=
2
Handled-By	: Frederic Weisbecker <fweisbec@gmail.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15717
Subject		: bluetooth oops
Submitter	: Pavel Machek <pavel@ucw.cz>
Date		: 2010-03-14 20:14 (99 days old)
Message-ID	: <20100314201434.GE22059@elf.ucw.cz>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126859771528426&w=3D=
4
Handled-By	: Marcel Holtmann <marcel@holtmann.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15704
Subject		: [r8169] WARNING: at net/sched/sch_generic.c
Submitter	: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Date		: 2010-03-31 10:21 (82 days old)
Message-ID	: <20100331102142.GA3294@swordfish.minsk.epam.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127003090406108&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15673
Subject		: 2.6.34-rc2: "ima_dec_counts: open/free imbalance"?
Submitter	: Thomas Meyer <thomas@m3y3r.de>
Date		: 2010-03-28 11:31 (85 days old)
Message-ID	: <1269775909.5301.4.camel@localhost.localdomain>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126977593326800&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15671
Subject		: intel graphic card hanging (Hangcheck timer elapsed... GPU h=
ung)
Submitter	: Norbert Preining <preining@logic.at>
Date		: 2010-03-27 16:11 (86 days old)
Message-ID	: <20100327161104.GA12043@gamma.logic.tuwien.ac.at>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126970883105262&w=3D=
2
Handled-By	: Jesse Barnes <jbarnes@virtuousgeek.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15669
Subject		: INFO: suspicious rcu_dereference_check()
Submitter	: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date		: 2010-03-08 1:26 (105 days old)
Message-ID	: <c4e36d111003250348q678eb2e6w4f3e8133e7fd6e58@mail.gmail.c=
om>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126801163107713&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15664
Subject		: Graphics hang and kernel backtrace when starting Azureus wit=
h Compiz enabled
Submitter	: Alex Villacis Lasso <avillaci@ceibo.fiec.espol.edu.ec>
Date		: 2010-04-01 01:09 (81 days old)


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16147
Subject		: ksoftirq hogs the CPU
Submitter	: Thomas Jarosch <thomas.jarosch@intra2net.com>
Date		: 2010-06-07 15:17 (14 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/ae74e823cb7d4cd476f623f=
ce9a38f625f6c09a8
Handled-By	: Martin Wilck <martin.wilck@ts.fujitsu.com>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=3D26732


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16138
Subject		: PCMCIA regression
Submitter	: Mikulas Patocka <mpatocka@redhat.com>
Date		: 2010-05-25 20:25 (27 days old)
Message-ID	: <Pine.LNX.4.64.1005251619020.12278@hs20-bc2-1.build.redhat=
=2Ecom>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127481913909672&w=3D=
2
Handled-By	: Dominik Brodowski <linux@brodo.de>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=3D26685


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16054
Subject		: UML broken for CONFIG_SLAB
Submitter	: Parag Warudkar <parag.lkml@gmail.com>
Date		: 2010-05-23 21:40 (29 days old)
Message-ID	: <alpine.DEB.2.00.1005231149100.605@parag-laptop>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127465083806617&w=3D=
2
Handled-By	: Borislav Petkov <bp@alien8.de>
Patch		: http://git.kernel.org/tip/055c47272b8f5679d08ccc57efea3cb4aaeb=
5fc6


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16040
Subject		: kacpid consumes ~40% of cpu all the time beginning with 2.6.=
34
Submitter	: Mehmet Giritli <mehmet@giritli.eu>
Date		: 2010-05-24 07:32 (28 days old)
Patch		: https://patchwork.kernel.org/patch/104903/
		  https://patchwork.kernel.org/patch/104912/
		  https://patchwork.kernel.org/patch/104909/
		  https://patchwork.kernel.org/patch/104911/
		  https://patchwork.kernel.org/patch/104910/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16007
Subject		: x86/pci Oops with CONFIG_SND_HDA_INTEL
Submitter	: Graham Ramsey <ramsey.graham@ntlworld.com>
Date		: 2010-05-19 17:09 (33 days old)
Handled-By	: Yinghai Lu <yinghai@kernel.org>
Patch		: https://patchwork.kernel.org/patch/105662/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15951
Subject		: commit 9630bdd9 changes behavior of the poweroff
Submitter	: Michal Hocko <mhocko@suse.cz>
Date		: 2010-04-01 13:39 (81 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/9630bdd9b15d2f489c646d8=
bc04b60e53eb5ec78
Message-ID	: <20100401133923.GA4104@tiehlicka.suse.cz>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127012918316305&w=3D=
4
Handled-By	: Rafael J. Wysocki <rjw@sisk.pl>
Patch		: https://patchwork.kernel.org/patch/106701/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15863
Subject		: 2.6.34-rc5-git7 (plus all patches) -- another suspicious rcu=
_dereference_check() usage.
Submitter	: Miles Lane <miles.lane@gmail.com>
Date		: 2010-04-27 0:51 (55 days old)
Message-ID	: <h2ya44ae5cd1004261751waa5cb65ei3d139cbcfa2cc5cf@mail.gmai=
l.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127232949104878&w=3D=
2
Handled-By	: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Patch		: https://patchwork.kernel.org/patch/96096/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15589
Subject		: 2.6.34-rc1: Badness at fs/proc/generic.c:316
Submitter	: Christian Kujau <lists@nerdbynature.de>
Date		: 2010-03-13 23:53 (100 days old)
Message-ID	: < <AANLkTikNcCtUn9SQwKu2b3IE6NiAwAhciHsm1HVH4EJh@mail.gmai=
l.com>>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126852442903680&w=3D=
2
Handled-By	: Michael Ellerman <michael@ellerman.id.au>
		  Jind=C5=99ich Makovi=C4=8Dka <makovick@gmail.com>
Patch		: http://patchwork.ozlabs.org/patch/52978/
		  http://lkml.indiana.edu/hypermail/linux/kernel/1006.0/00137.html


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

--
To unsubscribe from this list: send the line "unsubscribe linux-acpi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
