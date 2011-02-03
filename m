From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.38-rc3-git1: Reported regressions 2.6.36 -> 2.6.37
Date: Thu,  3 Feb 2011 01:03:41 +0100 (CET)
Message-ID: <e9vOd5LzdBK.A.dyD.h6eSNB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maciej Rutecki <maciej.rutecki@gmail.com>,
	Florian Mickler <florian@mickler.org>,
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
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This message contains a list of some post-2.6.36 regressions introduced=
 before
2.6.37, for which there are no fixes in the mainline known to the track=
ing team.
If any of them have been fixed already, please let us know.

If you know of any other unresolved post-2.6.36 regressions, please let=
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
  2011-02-03      118       36          31
  2010-12-30       85       32          26
  2010-12-19       73       28          24
  2010-12-03       55       25          19
  2010-11-19       39       29          25


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D27892
Subject		: SNB: GPU hang with Slip xscreensaver
Submitter	: Takashi Iwai <tiwai@suse.de>
Date		: 2011-01-31 12:06 (3 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D27842
Subject		: [regression?] hang with 2.6.37 on a BTRFS test machine
Submitter	: Martin Steigerwald <Martin@lichtvoll.de>
Date		: 2011-01-23 12:06 (11 days old)
Message-ID	: <201101231306.23069.Martin@lichtvoll.de>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129578445613283&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D27642
Subject		: 2.6.37 says WARNING: at arch/x86/kernel/apic/apic.c:1287 set=
up_local_APIC+0x18f/0x263()
Submitter	: Rob Landley <rlandley@parallels.com>
Date		: 2011-01-18 13:11 (16 days old)
Message-ID	: <4D359188.3040408@parallels.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129535632319892&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D27532
Subject		: ath9k prevents CPU from entering lower C-states
Submitter	: Thomas B=C3=A4chler <thomas@archlinux.org>
Date		: 2011-01-24 22:43 (10 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D27402
Subject		: Atheros adapter no longer loads firmware
Submitter	: Michal Vaner <vorner@ucw.cz>
Date		: 2011-01-23 15:29 (11 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/be93112accb42c5586a4596=
83d71975cc70673ca


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D27152
Subject		: VGA output broken at cold boot
Submitter	: Takashi Iwai <tiwai@suse.de>
Date		: 2011-01-20 13:26 (14 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D27132
Subject		: flush-btrfs gets into an infinite loop
Submitter	: Artem Anisimov <aanisimov@inbox.ru>
Date		: 2011-01-20 11:51 (14 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D26942
Subject		: radeon: screen distortion on resume
Submitter	: Brett Witherspoon <spoonb@exherbo.org>
Date		: 2011-01-17 13:23 (17 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D26932
Subject		: [SNB mobile] Oops in DRM intel driver, esp. during S3/S4 str=
ess test
Submitter	: Matthias Hopf <mat@mshopf.de>
Date		: 2011-01-17 11:45 (17 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D26842
Subject		: [2.6.37 regression] threads with CPU affinity cannot be kill=
ed
Submitter	: tim blechmann <tim@klingt.org>
Date		: 2011-01-16 13:39 (18 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D26802
Subject		: b43: Suspend failed
Submitter	: Patrick Matth=C3=A4i <patrick@linux-dev.org>
Date		: 2011-01-15 18:56 (19 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D26582
Subject		: NULL pointer dereference on pipe creation
Submitter	: Ferenc W=C3=A1gner <wferi@niif.hu>
Date		: 2011-01-12 13:30 (22 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D26552
Subject		: Screen flickering with 2.6.37 [ATI X1600]
Submitter	: Andrea Iob <andrea_iob@yahoo.it>
Date		: 2011-01-11 22:53 (23 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D26212
Subject		: kernel NULL pointer dereference in pxa3xx_nand_probe
Submitter	: Sven Neumann <s.neumann@raumfeld.com>
Date		: 2011-01-05 11:43 (29 days old)
Message-ID	: <1294227801.3996.62.camel@sven>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129422903703756&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D26112
Subject		: [LogFS] [2.6.37-rc8+] Kernel BUG at logfs/readwrite.c:297!
Submitter	: Prasad Joshi <prasadjoshi124@gmail.com>
Date		: 2011-01-02 21:22 (32 days old)
Message-ID	: <AANLkTinpoM8FuG8UkF88xs_V37dz_wgE8t-s0JPzaS-w@mail.gmail.=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129400335910652&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D26102
Subject		: [2.6.37-rc8] BUG kmalloc-256: Poison overwritten.
Submitter	: Pawel Sikora <pluto@agmk.net>
Date		: 2010-12-30 15:08 (35 days old)
Message-ID	: <201012301608.40859.pluto@agmk.net>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129372388925679&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D25922
Subject		: IdeaPad Y530 brightness keys not functioning
Submitter	: Tomasz <tm.temp@gmx.com>
Date		: 2010-12-30 12:48 (35 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D25832
Subject		: kernel crashes upon resume if usb devices are removed when s=
uspended
Submitter	: rocko <rockorequin@hotmail.com>
Date		: 2010-12-29 11:47 (36 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D25732
Subject		: i915 turns picture green when display switched off-on
Submitter	: T=C3=B5nu Raitviir <jussuf@linux.ee>
Date		: 2010-12-27 22:14 (38 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/3c17fe4b8f40a112a85758a=
9ab2aebf772bdd647
Handled-By	: Chris Wilson <chris@chris-wilson.co.uk>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D25432
Subject		: Alpha fails to build with gcc 4.4
Submitter	: Ben Hutchings <ben@decadent.org.uk>
Date		: 2010-12-22 01:55 (43 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D25402
Subject		: kernel (2.6.37-8-generic_amd64) panic on boot (with message =
"map_single: bounce buffer is not DMA'ble) - possible regression !!!
Submitter	: carlos <carlos.palma@ono.com>
Date		: 2010-12-21 19:58 (44 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D25072
Subject		: backlight level is not maintened during LID close/open
Submitter	: Lukas Hejtmanek <xhejtman@fi.muni.cz>
Date		: 2010-12-17 11:56 (48 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D24882
Subject		: PM/Hibernate: Memory corruption patch introduces regression =
(2.6.36.2)
Submitter	:  <akwatts@ymail.com>
Date		: 2010-12-14 04:00 (51 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D24822
Subject		: Embedded DisplayPort is detected wrongly on HP ProBook 5320m
Submitter	: Takashi Iwai <tiwai@suse.de>
Date		: 2010-12-13 11:09 (52 days old)
Handled-By	: Chris Wilson <chris@chris-wilson.co.uk>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D24762
Subject		: BUG at perf_ctx_adjust_freq (kernel/perf_event.c:1582)
Submitter	: Chris Wilson <chris@chris-wilson.co.uk>
Date		: 2010-12-10 12:00 (55 days old)
Message-ID	: <c6d829$pqibha@fmsmga001.fm.intel.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129198247531612&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D24582
Subject		: Kernel Oops at tty_buffer_request_room when using pppd progr=
am (2.6.37-rc4)
Submitter	: baoyb <baoyb@avit.org.cn>
Date		: 2010-12-08 13:55 (57 days old)
Message-ID	: <EF6DDE218DB34702B1FA84D6CD7EA771@baoyb>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129181763525738&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D22942
Subject		: [2.6.37-rc1, OOM] virtblk: OOM in do_virtblk_request()
Submitter	: Dave Chinner <david@fromorbit.com>
Date		: 2010-11-05 1:30 (90 days old)
Message-ID	: <20101105013003.GE13830@dastard>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128892062917641&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D22912
Subject		: spi_lm70llp module crash on unload (2.6.37-rc1)
Submitter	: Randy Dunlap <randy.dunlap@oracle.com>
Date		: 2010-11-05 0:16 (90 days old)
Message-ID	: <20101104171620.00d8c95d.randy.dunlap@oracle.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128891627913647&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D22882
Subject		: (2.6.37-rc1) amd64-agp module crashed on second load
Submitter	: Randy Dunlap <randy.dunlap@oracle.com>
Date		: 2010-11-05 0:13 (90 days old)
Message-ID	: <20101104171333.fea1f498.randy.dunlap@oracle.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128891605213447&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D22642
Subject		: 2.6.37-rc1: Disk takes 10 seconds to resume - MacBook2,1
Submitter	: Tobias <devnull@plzk.org>
Date		: 2010-11-10 19:33 (85 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D22542
Subject		: [2.6.37-rc1] drm:i195 errors
Submitter	: Paul Rolland <rol@witbe.net>
Date		: 2010-11-02 14:58 (93 days old)
Message-ID	: <20101102155813.09cb2c6e@tux.DEF.witbe.net>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128870991628970&w=3D=
2


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D27202
Subject		: Remote control of saa7134-based tv card "ASUSTeK P7131 Hybri=
d" stopped working in 2.6.37
Submitter	:  <acaizzo@gmail.com>
Date		: 2011-01-20 17:23 (14 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/4651918a4afdd49bdea21d2=
f919b189ef17a6399
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=3D44532


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D26242
Subject		: BUG: unable to handle kernel NULL pointer dereference at   (=
null)
Submitter	: Steffen Michalke <StMichalke@web.de>
Date		: 2011-01-06 20:59 (28 days old)
Patch		: http://www.spinics.net/lists/linux-btrfs/msg08051.html


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D25822
Subject		: [BUG] kernel BUG at mm/truncate.c:479! on 2.6.37-rc8
Submitter	: Gurudas Pai <gurudas.pai@oracle.com>
Date		: 2010-12-29 6:58 (36 days old)
Message-ID	: <4D1AD935.1020504@oracle.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129360511222037&w=3D=
2
Patch		: https://lkml.org/lkml/2010/12/29/131


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D25442
Subject		: ixp4xx defines FREQ macro; conflicts with gspca/ov519 driver
Submitter	: Ben Hutchings <ben@decadent.org.uk>
Date		: 2010-12-22 02:02 (43 days old)
Handled-By	: Ben Hutchings <ben@decadent.org.uk>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=3D41252


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D23472
Subject		: 2.6.37-rc2 vs. 2.6.36 laptop backlight changes?
Submitter	: Patrick Schaaf <netdev@bof.de>
Date		: 2010-11-17 13:41 (78 days old)
Message-ID	: <1290001262.5727.2.camel@lat1>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D129000127920912&w=3D=
2
Handled-By	: Indan Zupancic <indan@nul.nu>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=3D43482


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions introd=
uced
between 2.6.36 and 2.6.37, unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D21782

Please let the tracking team know if there are any Bugzilla entries tha=
t
should be added to the list in there.

Thanks!

--
To unsubscribe from this list: send the line "unsubscribe linux-acpi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
