From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.32-rc1-git2: Reported regressions 2.6.30 -> 2.6.31
Date: Thu,  1 Oct 2009 21:53:40 +0200 (CEST)
Message-ID: <3onW63eFtRF.A.xXH.oMTxKB@chimera>
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
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754145AbZJAXE3@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Notes:

 * Quite a number of new regressions from 2.6.30 has been reported duri=
ng
   the last three weeks.

 * The number of unresolved regressions 2.6.30 -> 2.6.31 is now the sec=
ond
   highest ever.]

This message contains a list of some regressions introduced between 2.6=
=2E30 and
2.6.31, for which there are no fixes in the mainline I know of.  If any=
 of them
have been fixed already, please let me know.

If you know of any other unresolved regressions introduced between 2.6.=
30
and 2.6.31, please let me know either and I'll add them to the list.
Also, please let me know if any of the entries below are invalid.

Each entry from the list will be sent additionally in an automatic repl=
y to
this message with CCs to the people involved in reporting and handling =
the
issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2009-10-02      151       49          42
  2009-09-06      123       34          27
  2009-08-26      108       33          26
  2009-08-20      102       32          29
  2009-08-10       89       27          24
  2009-08-02       76       36          28
  2009-07-27       70       51          43
  2009-07-07       35       25          21
  2009-06-29       22       22          15


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14301
Subject		: WARNING: at net/ipv4/af_inet.c:154
Submitter	: Ralf Hildebrandt <Ralf.Hildebrandt@charite.de>
Date		: 2009-09-30 12:24 (2 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125431350218137&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14294
Subject		: kernel BUG at drivers/ide/ide-disk.c:187
Submitter	: Santiago Garcia Mantinan <manty@manty.net>
Date		: 2009-09-30 11:05 (2 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125430926311466&w=3D=
4
Handled-By	: David Miller <davem@davemloft.net>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14270
Subject		: Cannot boot on a PIII Celeron
Submitter	: Michael Tokarev <mjt@tls.msk.ru>
Date		: 2009-09-28 15:26 (4 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125415160524110&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14267
Subject		: Disassociating atheros wlan
Submitter	: Kristoffer Ericson <kristoffer.ericson@gmail.com>
Date		: 2009-09-24 10:16 (8 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125378723723384&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14266
Subject		: regression in page writeback
Submitter	: Shaohua Li <shaohua.li@intel.com>
Date		: 2009-09-22 5:49 (10 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dd7831a0bdf06b9f722b947bb0c205ff7d77cebd8
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125359858117176&w=3D=
4
Handled-By	: Wu Fengguang <fengguang.wu@intel.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14265
Subject		: ifconfig: page allocation failure. order:5, mode:0x8020 w/ e=
100
Submitter	: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Date		: 2009-09-15 12:05 (17 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125301636509517&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14264
Subject		: ehci problem - mouse dead on scroll
Submitter	: Volker Armin Hemmann <volkerarmin@googlemail.com>
Date		: 2009-09-12 7:46 (20 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125274202707893&w=3D=
4
Handled-By	: Alan Stern <stern@rowland.harvard.edu>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14257
Subject		: Not able to boot on 32 bit System
Submitter	: Rishikesh <risrajak@linux.vnet.ibm.com>
Date		: 2009-09-21 15:25 (11 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125354604314412&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14256
Subject		: kernel BUG at fs/ext3/super.c:435
Submitter	: Mikael Pettersson <mikpe@it.uu.se>
Date		: 2009-09-21 7:29 (11 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125351816109264&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14255
Subject		: WARNING: at drivers/char/tty_io.c:1267
Submitter	: Heinz Diehl <htd@fancy-poultry.org>
Date		: 2009-09-20 11:37 (12 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125344629506309&w=3D=
4
		  http://lkml.org/lkml/2009/9/8/393
Handled-By	: Linus Torvalds <torvalds@linux-foundation.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14254
Subject		: Hibernation broken by clocksource: Save mult_orig in clockso=
urce_disable()
Submitter	: Ondrej Zary <linux@rainbow-software.org>
Date		: 2009-09-19 19:55 (13 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dc7121843685de2bf7f3afd3ae1d6a146010bf1fc
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125339012527719&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14252
Subject		: WARNING: at include/linux/skbuff.h:1382 w/ e1000
Submitter	: Stephan von Krawczynski <skraw@ithnet.com>
Date		: 2009-09-20 11:26 (12 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125344599006033&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14251
Subject		: 2.6.31: no login prompt
Submitter	: Fr=C3=A9d=C3=A9ric L. W. Meunier <fredlwm@gmail.com>
Date		: 2009-09-19 22:43 (13 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125340020804711&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14249
Subject		: BUG: oops in gss_validate on 2.6.31
Submitter	: Bastian Blank <bastian@waldi.eu.org>
Date		: 2009-09-16 10:29 (16 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125309700417283&w=3D=
4
Handled-By	: Trond Myklebust <trond.myklebust@fys.uio.no>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14248
Subject		: 2.6.31 wireless: WARNING: at net/wireless/ibss.c:34
Submitter	: Jurriaan <thunder8@xs4all.nl>
Date		: 2009-09-13 7:32 (19 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125282721113553&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14222
Subject		: Hibernation oopses for the 2nd time with 2.6.31 (won't fit t=
he screen)
Submitter	: Ondrej Zary <linux@rainbow-software.org>
Date		: 2009-09-24 14:07 (8 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dc7121843685de2bf7f3afd3ae1d6a146010bf1fc


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14205
Subject		: Intel DX58SO mainboard - powering off takes really long
Submitter	: Tomasz Chmielewski <tch@wpkg.org>
Date		: 2009-09-22 10:14 (10 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14204
Subject		: MCE prevent booting on my computer(pentium iii @500Mhz)
Submitter	: GNUtoo <GNUtoo@no-log.org>
Date		: 2009-09-21 20:36 (11 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14185
Subject		: Oops in driversbasefirmware_class
Submitter	:  <lars_ericsson@telia.com>
Date		: 2009-09-17 05:09 (15 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D6e03a201bbe8137487f340d26aa662110e324b20


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14181
Subject		: b43 causes panic at system shutdown
Submitter	: Jeremy Huddleston <jeremyhu@freedesktop.org>
Date		: 2009-09-15 18:34 (17 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14157
Subject		: end_request: I/O error, dev cciss/cXdX, sector 0
Submitter	:  <jiri.harcarik@gmail.com>
Date		: 2009-09-11 07:42 (21 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14143
Subject		: OOPS when setting nr_requests for md devices
Submitter	: aCaB <acab@clamav.net>
Date		: 2009-09-08 08:48 (24 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14141
Subject		: order 2 page allocation failures in iwlagn
Submitter	: Frans Pop <elendil@planet.nl>
Date		: 2009-09-06 7:40 (26 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125222287419691&w=3D=
4
Handled-By	: Pekka Enberg <penberg@cs.helsinki.fi>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14133
Subject		: WARNING: at arch/x86/kernel/smp.c:117 native_smp_send_resche=
dule
Submitter	: Jens Axboe <jens.axboe@oracle.com>
Date		: 2009-08-31 20:43 (32 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125175143918050&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14114
Subject		: Tuning a saa7134 based card is broken in kernel 2.6.31-rc7
Submitter	: Tsvety Petrov <Tsvetoslav.Petrov@itron.com>
Date		: 2009-09-03 21:06 (29 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14090
Subject		: WARNING: at fs/notify/inotify/inotify_user.c:394
Submitter	: Joerg Platte <bugzilla@jako.ping.de>
Date		: 2009-08-30 15:21 (33 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14070
Subject		: lockdep warning triggered by dup_fd
Submitter	: Bart Van Assche <bart.vanassche@gmail.com>
Date		: 2009-08-23 09:36 (40 days old)
References	: http://lkml.org/lkml/2009/8/23/8


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14058
Subject		: Oops in fsnotify
Submitter	: Grant Wilson <grant.wilson@zen.co.uk>
Date		: 2009-08-20 15:48 (43 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125078450923133&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14013
Subject		: hd don't show up
Submitter	: Tim Blechmann <tim@klingt.org>
Date		: 2009-08-14 8:26 (49 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125023842514480&w=3D=
4
Handled-By	: Tejun Heo <tj@kernel.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13987
Subject		: Received NMI interrupt at resume
Submitter	: Christian Casteyde <casteyde.christian@free.fr>
Date		: 2009-08-15 07:55 (48 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13950
Subject		: Oops when USB Serial disconnected while in use
Submitter	: Bruno Pr=C3=A9mont <bonbons@linux-vserver.org>
Date		: 2009-08-08 17:47 (55 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124975432900466&w=3D=
4
Handled-By	: Alan Stern <stern@rowland.harvard.edu>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13943
Subject		: WARNING: at net/mac80211/mlme.c:2292 with ath5k
Submitter	: Fabio Comolli <fabio.comolli@gmail.com>
Date		: 2009-08-06 20:15 (57 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124958978600600&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13942
Subject		: Troubles with AoE and uninitialized object
Submitter	: Bruno Pr=C3=A9mont <bonbons@linux-vserver.org>
Date		: 2009-08-04 10:12 (59 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124938117104811&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13941
Subject		: x86 Geode issue
Submitter	: Martin-=C3=89ric Racine <q-funk@iki.fi>
Date		: 2009-08-03 12:58 (60 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124930434732481&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13940
Subject		: iwlagn and sky2 stopped working, ACPI-related
Submitter	: Ricardo Jorge da Fonseca Marques Ferreira <storm@sys49152.n=
et>
Date		: 2009-08-07 22:33 (56 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124968457731107&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13935
Subject		: 2.6.31-rcX breaks Apple MightyMouse (Bluetooth version)
Submitter	: Adrian Ulrich <kernel@blinkenlights.ch>
Date		: 2009-08-08 22:08 (55 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dfa047e4f6fa63a6e9d0ae4d7749538830d14a343


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13906
Subject		: Huawei E169 GPRS connection causes Ooops
Submitter	: Clemens Eisserer <linuxhippy@gmail.com>
Date		: 2009-08-04 09:02 (59 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13869
Subject		: Radeon framebuffer (w/o KMS) corruption at boot.
Submitter	: Duncan <1i5t5.duncan@cox.net>
Date		: 2009-07-29 16:44 (65 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13836
Subject		: suspend script fails, related to stdout?
Submitter	: Tomas M. <tmezzadra@gmail.com>
Date		: 2009-07-17 21:24 (77 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124785853811667&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13809
Subject		: oprofile: possible circular locking dependency detected
Submitter	: Jerome Marchand <jmarchan@redhat.com>
Date		: 2009-07-22 13:35 (72 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13733
Subject		: 2.6.31-rc2: irq 16: nobody cared
Submitter	: Niel Lambrechts <niel.lambrechts@gmail.com>
Date		: 2009-07-06 18:32 (88 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124690524027166&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13645
Subject		: NULL pointer dereference at (null) (level2_spare_pgt)
Submitter	: poornima nayak <mpnayak@linux.vnet.ibm.com>
Date		: 2009-06-17 17:56 (107 days old)
References	: http://lkml.org/lkml/2009/6/17/194


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14275
Subject		: kernel>=3D2.6.31: ahci.c: do not force unconditionally sb600=
 to 32bit dma any more?
Submitter	: gabriele balducci <balducci@units.it>
Date		: 2009-09-30 15:02 (2 days old)
Patch		: http://bugzilla.kernel.org/show_bug.cgi?id=3D14275#c0


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14261
Subject		: e1000e jumbo frames no longer work: 'Unsupported MTU setting=
'
Submitter	: Nix <nix@esperi.org.uk>
Date		: 2009-09-26 11:16 (6 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125396433321342&w=3D=
4
Handled-By	: Alexander Duyck <alexander.duyck@gmail.com>
Patch		: http://patchwork.kernel.org/patch/50277/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14258
Subject		: Memory leak in SCSI initialization
Submitter	: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Date		: 2009-09-22 4:18 (10 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125359311312243&w=3D=
4
Handled-By	: Michael Ellerman <michael@ellerman.id.au>
Patch		: http://patchwork.kernel.org/patch/49258/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14253
Subject		: Oops in driversbasefirmware_class
Submitter	: Lars Ericsson <Lars_Ericsson@telia.com>
Date		: 2009-09-16 20:44 (16 days old)
References	: http://lkml.org/lkml/2009/9/16/461
Handled-By	: Frederik Deweerdt <frederik.deweerdt@xprog.eu>
Patch		: http://patchwork.kernel.org/patch/49914/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14137
Subject		: usb console regressions
Submitter	: Jason Wessel <jason.wessel@windriver.com>
Date		: 2009-09-05 21:08 (27 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125218501310512&w=3D=
4
Handled-By	: Jason Wessel <jason.wessel@windriver.com>
Patch		: http://patchwork.kernel.org/patch/45953/
		  http://patchwork.kernel.org/patch/45952/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14017
Subject		: _end symbol missing from Symbol.map
Submitter	: Hannes Reinecke <hare@suse.de>
Date		: 2009-08-13 6:45 (50 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D091e52c3551d3031343df24b573b770b4c6c72b6
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125014649102253&w=3D=
4
Handled-By	: Hannes Reinecke <hare@suse.de>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D125014649102253&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13948
Subject		: ath5k broken after suspend-to-ram
Submitter	: Johannes Stezenbach <js@sig21.net>
Date		: 2009-08-07 21:51 (56 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124968192727854&w=3D=
4
Handled-By	: Nick Kossifidis <mickflemm@gmail.com>
Patch		: http://patchwork.kernel.org/patch/38550/


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions introd=
uced
between 2.6.30 and 2.6.31, unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D13615

Please let me know if there are any Bugzilla entries that should be add=
ed to
the list in there.

Thanks,
Rafael
