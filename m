From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.32-rc8-git1: Reported regressions 2.6.30 -> 2.6.31
Date: Sat, 21 Nov 2009 15:59:44 +0100 (CET)
Message-ID: <7qTjLRFNcGF.A.eSE.kCACLB@chimera>
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
  2009-11-21      178       35          31
  2009-11-17      176       34          30
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

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14658
Subject		: Regression in efi.c
Submitter	: indexer <indexer-CkBdp7X+a1oIQCUVoCVjmQ@public.gmane.org>
Date		: 2009-11-17 14:54 (5 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125846988820120&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14649
Subject		: KMS not working
Submitter	: Martin Bammer <mrb74-RbZlAiThDcE@public.gmane.org>
Date		: 2009-11-20 23:00 (2 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14640
Subject		: Suspend/resume failed on Thinkpad running Linux with kernel =
2.6.31
Submitter	: Wayne <wayne.zhang-Y9sIeH5OGRo@public.gmane.org>
Date		: 2009-11-19 03:57 (3 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14623
Subject		: Mount -o sync regression in 2.6.31
Submitter	: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Date		: 2009-11-11 20:33 (11 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125797165709131&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14588
Subject		: Kernel panic - not syncing: stack-protector: Kernel stack is=
 corrupted in: ccccb5b0
Submitter	: Hideki Yamane <henrich-8fiUuRrzOP3bmG5+kqVDhQ@public.gmane.org>
Date		: 2009-11-12 02:25 (10 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14484
Subject		: no video output after suspend
Submitter	: Riccardo Magliocchetti <riccardo.magliocchetti-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-25 20:57 (28 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125650430123713&w=3D=
4
Handled-By	: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14476
Subject		: Unable to handle kernel paging request in nfs_write_mapping
Submitter	: Stephan von Krawczynski <skraw-DcQCyzbjH0jQT0dZR+AlfA@public.gmane.org>
Date		: 2009-10-14 9:53 (39 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125551421405656&w=3D=
4
Handled-By	: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14474
Subject		: restorecond going crazy on 2.6.31.4 - inotify regression?
Submitter	: Robert Hancock <hancockrwd-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-16 0:03 (37 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125565159520489&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14460
Subject		: No wireless connection with Ralink RT2500 since update to ke=
rnel 2.6.31
Submitter	: Filipp Andjelo <andjelo-hi6Y0CQ0nG0@public.gmane.org>
Date		: 2009-10-24 21:18 (29 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14450
Subject		: [2.6.31] Network interfaces are dead with 2.6.31 (iwlagn and=
 sky2)
Submitter	: A. G. <orion.linbug-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-21 07:30 (32 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14448
Subject		: PAT cpu feature is absent but detected by Xorg and others, c=
uses video driver problems
Submitter	: Aleksei Lukin <lukin-YfdFxnIOohD3fQ9qLvQP4Q@public.gmane.org>
Date		: 2009-10-20 17:54 (33 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14400
Subject		: disable/enable wlan broken with ath5k
Submitter	: Daniel Bumke <danielbumke-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-13 12:35 (40 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14391
Subject		: use after free of struct powernow_k8_data
Submitter	: Michal Schmidt <mschmidt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date		: 2009-09-24 14:51 (59 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125380383515615&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14385
Subject		: DMAR regression in 2.6.31 leads to ext4 corruption?
Submitter	: Andy Isaacson <adi-3HqRAUrWAWyGglJvpFV4uA@public.gmane.org>
Date		: 2009-10-08 23:56 (45 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125504643703877&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14294
Subject		: kernel BUG at drivers/ide/ide-disk.c:187
Submitter	: Santiago Garcia Mantinan <manty-gaW6/AuhO2xeoWH0uzbU5w@public.gmane.org>
Date		: 2009-09-30 11:05 (53 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125430926311466&w=3D=
4
Handled-By	: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14267
Subject		: Disassociating atheros wlan
Submitter	: Kristoffer Ericson <kristoffer.ericson-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-09-24 10:16 (59 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125378723723384&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14265
Subject		: ifconfig: page allocation failure. order:5, mode:0x8020 w/ e=
100
Submitter	: Karol Lewandowski <karol.k.lewandowski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-09-15 12:05 (68 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125301636509517&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14257
Subject		: Not able to boot on 32 bit System
Submitter	: Rishikesh <risrajak-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date		: 2009-09-21 15:25 (62 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125354604314412&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14256
Subject		: kernel BUG at fs/ext3/super.c:435
Submitter	: Mikael Pettersson <mikpe-1zs4UD6AkMk@public.gmane.org>
Date		: 2009-09-21 7:29 (62 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125351816109264&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14252
Subject		: WARNING: at include/linux/skbuff.h:1382 w/ e1000
Submitter	: Stephan von Krawczynski <skraw-DcQCyzbjH0jQT0dZR+AlfA@public.gmane.org>
Date		: 2009-09-20 11:26 (63 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125344599006033&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14204
Subject		: MCE prevent booting on my computer(pentium iii @500Mhz)
Submitter	: GNUtoo <GNUtoo-n+LsquliYkMdnm+yROfE0A@public.gmane.org>
Date		: 2009-09-21 20:36 (62 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14157
Subject		: end_request: I/O error, dev cciss/cXdX, sector 0
Submitter	:  <jiri.harcarik-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-09-11 07:42 (72 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14141
Subject		: order 2 page allocation failures in iwlagn
Submitter	: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Date		: 2009-09-06 7:40 (77 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D2ff05b2b4eac2e63d345fc731ea151a060247f53
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125222287419691&w=3D=
4
		  http://lkml.org/lkml/2009/10/2/86
		  http://lkml.org/lkml/2009/10/5/24
		  http://lkml.indiana.edu/hypermail/linux/kernel/0910.1/01395.html
Handled-By	: Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14114
Subject		: Tuning a saa7134 based card is broken in kernel 2.6.31-rc7
Submitter	: Tsvety Petrov <Tsvetoslav.Petrov-qXmYkbEmOXkAvxtiuMwx3w@public.gmane.org>
Date		: 2009-09-03 21:06 (80 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13987
Subject		: Received NMI interrupt at resume
Submitter	: Christian Casteyde <casteyde.christian-GANU6spQydw@public.gmane.org>
Date		: 2009-08-15 07:55 (99 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Df41f3f373dd72344c65d801d6381fe83ef3a2c54


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13943
Subject		: WARNING: at net/mac80211/mlme.c:2292 with ath5k
Submitter	: Fabio Comolli <fabio.comolli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-08-06 20:15 (108 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124958978600600&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13941
Subject		: x86 Geode issue
Submitter	: Martin-=C3=89ric Racine <q-funk-X3B1VOXEql0@public.gmane.org>
Date		: 2009-08-03 12:58 (111 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124930434732481&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13836
Subject		: suspend script fails, related to stdout?
Submitter	: Tomas M. <tmezzadra-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-07-17 21:24 (128 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124785853811667&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13809
Subject		: oprofile: possible circular locking dependency detected
Submitter	: Jerome Marchand <jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date		: 2009-07-22 13:35 (123 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13733
Subject		: 2.6.31-rc2: irq 16: nobody cared
Submitter	: Niel Lambrechts <niel.lambrechts-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-07-06 18:32 (139 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124690524027166&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13645
Subject		: NULL pointer dereference at (null) (level2_spare_pgt)
Submitter	: poornima nayak <mpnayak-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date		: 2009-06-17 17:56 (158 days old)
References	: http://lkml.org/lkml/2009/6/17/194


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14340
Subject		: speedstep-ich driver not working in 2.6.31
Submitter	:  <dave.mueller-OI3hZJvNYWs@public.gmane.org>
Date		: 2009-10-07 08:16 (46 days old)
Handled-By	: Eric Pielbug <e.a.b.piel-hGVxb2UgFK3z+pZb47iToQ@public.gmane.org>
		  Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/54672/
		  http://patchwork.kernel.org/patch/54671/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14253
Subject		: Oops in driversbasefirmware_class
Submitter	: Lars Ericsson <Lars_Ericsson-zq6IREYz3ykAvxtiuMwx3w@public.gmane.org>
Date		: 2009-09-16 20:44 (67 days old)
References	: http://lkml.org/lkml/2009/9/16/461
Handled-By	: Frederik Deweerdt <frederik.deweerdt-kjvbsxwSFqI@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/49914/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14137
Subject		: usb console regressions
Submitter	: Jason Wessel <jason.wessel-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
Date		: 2009-09-05 21:08 (78 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125218501310512&w=3D=
4
Handled-By	: Jason Wessel <jason.wessel-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/45953/
		  http://patchwork.kernel.org/patch/45952/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14017
Subject		: _end symbol missing from Symbol.map
Submitter	: Hannes Reinecke <hare-l3A5Bk7waGM@public.gmane.org>
Date		: 2009-08-13 6:45 (101 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D091e52c3551d3031343df24b573b770b4c6c72b6
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125014649102253&w=3D=
4
Handled-By	: Hannes Reinecke <hare-l3A5Bk7waGM@public.gmane.org>
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
