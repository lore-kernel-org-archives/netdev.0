From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.32-rc5-git3: Reported regressions 2.6.30 -> 2.6.31
Date: Mon, 26 Oct 2009 20:26:08 +0100 (CET)
Message-ID: <G2WU8XrUVpF.A.lxF.Ref5KB@chimera>
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
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
  2009-10-26      170       37          32
  2009-10-12      161       45          35
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

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14476
Subject		: Unable to handle kernel paging request in nfs_write_mapping
Submitter	: Stephan von Krawczynski <skraw@ithnet.com>
Date		: 2009-10-14 9:53 (13 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125551421405656&w=3D=
4
Handled-By	: Trond Myklebust <Trond.Myklebust@netapp.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14474
Subject		: restorecond going crazy on 2.6.31.4 - inotify regression?
Submitter	: Robert Hancock <hancockrwd@gmail.com>
Date		: 2009-10-16 0:03 (11 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125565159520489&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14446
Subject		: battery status info broken/useless in 2.6.32-rc3 - MSI PR200=
 (possibly others, too)
Submitter	: Eddy Petri=C8=99or <eddy.petrisor+linbug@gmail.com>
Date		: 2009-10-20 08:25 (7 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14417
Subject		: [Regression] Wireless driver iwlagn+iwlcore doesn't work aft=
er resume (needs reloading)
Submitter	: Eddy Petri=C8=99or <eddy.petrisor+linbug@gmail.com>
Date		: 2009-10-16 11:07 (11 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14402
Subject		: Atheros ath9k module is not working with 2.6.31.1 on an Acer=
 Extensa 7630EZ
Submitter	: Bernhard <berndl81@gmx.at>
Date		: 2009-10-14 11:17 (13 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14400
Subject		: disable/enable wlan broken with ath5k
Submitter	: Daniel Bumke <danielbumke@gmail.com>
Date		: 2009-10-13 12:35 (14 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14391
Subject		: use after free of struct powernow_k8_data
Submitter	: Michal Schmidt <mschmidt@redhat.com>
Date		: 2009-09-24 14:51 (33 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125380383515615&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14388
Subject		: keyboard under X with 2.6.31
Submitter	: Fr=C3=A9d=C3=A9ric L. W. Meunier <fredlwm@gmail.com>
Date		: 2009-10-07 20:19 (20 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dhttp://git.kernel.org/?p=3Dlinux/kernel/=
git/torvalds/linux-2.6.git;a=3Dcommit;h=3De043e42bdb66885b3ac10d27a01cc=
b9972e2b0a3
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125494753228217&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14385
Subject		: DMAR regression in 2.6.31 leads to ext4 corruption?
Submitter	: Andy Isaacson <adi@hexapodia.org>
Date		: 2009-10-08 23:56 (19 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125504643703877&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14294
Subject		: kernel BUG at drivers/ide/ide-disk.c:187
Submitter	: Santiago Garcia Mantinan <manty@manty.net>
Date		: 2009-09-30 11:05 (27 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125430926311466&w=3D=
4
Handled-By	: David Miller <davem@davemloft.net>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14267
Subject		: Disassociating atheros wlan
Submitter	: Kristoffer Ericson <kristoffer.ericson@gmail.com>
Date		: 2009-09-24 10:16 (33 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125378723723384&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14265
Subject		: ifconfig: page allocation failure. order:5, mode:0x8020 w/ e=
100
Submitter	: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Date		: 2009-09-15 12:05 (42 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125301636509517&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14257
Subject		: Not able to boot on 32 bit System
Submitter	: Rishikesh <risrajak@linux.vnet.ibm.com>
Date		: 2009-09-21 15:25 (36 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125354604314412&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14256
Subject		: kernel BUG at fs/ext3/super.c:435
Submitter	: Mikael Pettersson <mikpe@it.uu.se>
Date		: 2009-09-21 7:29 (36 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125351816109264&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14252
Subject		: WARNING: at include/linux/skbuff.h:1382 w/ e1000
Submitter	: Stephan von Krawczynski <skraw@ithnet.com>
Date		: 2009-09-20 11:26 (37 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125344599006033&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14249
Subject		: BUG: oops in gss_validate on 2.6.31
Submitter	: Bastian Blank <bastian@waldi.eu.org>
Date		: 2009-09-16 10:29 (41 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125309700417283&w=3D=
4
Handled-By	: Trond Myklebust <trond.myklebust@fys.uio.no>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14248
Subject		: 2.6.31 wireless: WARNING: at net/wireless/ibss.c:34
Submitter	: Jurriaan <thunder8@xs4all.nl>
Date		: 2009-09-13 7:32 (44 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125282721113553&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14204
Subject		: MCE prevent booting on my computer(pentium iii @500Mhz)
Submitter	: GNUtoo <GNUtoo@no-log.org>
Date		: 2009-09-21 20:36 (36 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14181
Subject		: b43 causes panic at ifconfig down / shutdown
Submitter	: Jeremy Huddleston <jeremyhu@freedesktop.org>
Date		: 2009-09-15 18:34 (42 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14157
Subject		: end_request: I/O error, dev cciss/cXdX, sector 0
Submitter	:  <jiri.harcarik@gmail.com>
Date		: 2009-09-11 07:42 (46 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14141
Subject		: order 2 page allocation failures in iwlagn
Submitter	: Frans Pop <elendil@planet.nl>
Date		: 2009-09-06 7:40 (51 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D2ff05b2b4eac2e63d345fc731ea151a060247f53
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125222287419691&w=3D=
4
		  http://lkml.org/lkml/2009/10/2/86
		  http://lkml.org/lkml/2009/10/5/24
		  http://lkml.indiana.edu/hypermail/linux/kernel/0910.1/01395.html
Handled-By	: Pekka Enberg <penberg@cs.helsinki.fi>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14114
Subject		: Tuning a saa7134 based card is broken in kernel 2.6.31-rc7
Submitter	: Tsvety Petrov <Tsvetoslav.Petrov@itron.com>
Date		: 2009-09-03 21:06 (54 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14090
Subject		: WARNING: at fs/notify/inotify/inotify_user.c:394
Submitter	: Joerg Platte <bugzilla@jako.ping.de>
Date		: 2009-08-30 15:21 (58 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14058
Subject		: Oops in fsnotify
Submitter	: Grant Wilson <grant.wilson@zen.co.uk>
Date		: 2009-08-20 15:48 (68 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125078450923133&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13987
Subject		: Received NMI interrupt at resume
Submitter	: Christian Casteyde <casteyde.christian@free.fr>
Date		: 2009-08-15 07:55 (73 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Df41f3f373dd72344c65d801d6381fe83ef3a2c54


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13943
Subject		: WARNING: at net/mac80211/mlme.c:2292 with ath5k
Submitter	: Fabio Comolli <fabio.comolli@gmail.com>
Date		: 2009-08-06 20:15 (82 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124958978600600&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13941
Subject		: x86 Geode issue
Submitter	: Martin-=C3=89ric Racine <q-funk@iki.fi>
Date		: 2009-08-03 12:58 (85 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124930434732481&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13906
Subject		: Huawei E169 GPRS connection causes Ooops
Submitter	: Clemens Eisserer <linuxhippy@gmail.com>
Date		: 2009-08-04 09:02 (84 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13836
Subject		: suspend script fails, related to stdout?
Submitter	: Tomas M. <tmezzadra@gmail.com>
Date		: 2009-07-17 21:24 (102 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124785853811667&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13809
Subject		: oprofile: possible circular locking dependency detected
Submitter	: Jerome Marchand <jmarchan@redhat.com>
Date		: 2009-07-22 13:35 (97 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13733
Subject		: 2.6.31-rc2: irq 16: nobody cared
Submitter	: Niel Lambrechts <niel.lambrechts@gmail.com>
Date		: 2009-07-06 18:32 (113 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124690524027166&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13645
Subject		: NULL pointer dereference at (null) (level2_spare_pgt)
Submitter	: poornima nayak <mpnayak@linux.vnet.ibm.com>
Date		: 2009-06-17 17:56 (132 days old)
References	: http://lkml.org/lkml/2009/6/17/194


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14340
Subject		: speedstep-ich driver not working in 2.6.31
Submitter	:  <dave.mueller@gmx.ch>
Date		: 2009-10-07 08:16 (20 days old)
Handled-By	: Eric Pielbug <e.a.b.piel@tudelft.nl>
		  Rusty Russell <rusty@rustcorp.com.au>
Patch		: http://patchwork.kernel.org/patch/54672/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14258
Subject		: Memory leak in SCSI initialization
Submitter	: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Date		: 2009-09-22 4:18 (35 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125359311312243&w=3D=
4
Handled-By	: Michael Ellerman <michael@ellerman.id.au>
		  James Bottomley <James.Bottomley@suse.de>
Patch		: http://patchwork.kernel.org/patch/51412/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14253
Subject		: Oops in driversbasefirmware_class
Submitter	: Lars Ericsson <Lars_Ericsson@telia.com>
Date		: 2009-09-16 20:44 (41 days old)
References	: http://lkml.org/lkml/2009/9/16/461
Handled-By	: Frederik Deweerdt <frederik.deweerdt@xprog.eu>
Patch		: http://patchwork.kernel.org/patch/49914/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14137
Subject		: usb console regressions
Submitter	: Jason Wessel <jason.wessel@windriver.com>
Date		: 2009-09-05 21:08 (52 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125218501310512&w=3D=
4
Handled-By	: Jason Wessel <jason.wessel@windriver.com>
Patch		: http://patchwork.kernel.org/patch/45953/
		  http://patchwork.kernel.org/patch/45952/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14017
Subject		: _end symbol missing from Symbol.map
Submitter	: Hannes Reinecke <hare@suse.de>
Date		: 2009-08-13 6:45 (75 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D091e52c3551d3031343df24b573b770b4c6c72b6
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125014649102253&w=3D=
4
Handled-By	: Hannes Reinecke <hare@suse.de>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D125014649102253&w=3D4


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

--
To unsubscribe from this list: send the line "unsubscribe linux-acpi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
