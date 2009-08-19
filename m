From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.31-rc6-git5: Reported regressions from 2.6.30
Date: Wed, 19 Aug 2009 22:20:25 +0200 (CEST)
Message-ID: <jCYznkTxcLB.A.EPH.eNIjKB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
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

This message contains a list of some regressions from 2.6.30, for which=
 there
are no fixes in the mainline I know of.  If any of them have been fixed=
 already,
please let me know.

If you know of any other unresolved regressions from 2.6.30, please let=
 me know
either and I'll add them to the list.  Also, please let me know if any =
of the
entries below are invalid.

Each entry from the list will be sent additionally in an automatic repl=
y to
this message with CCs to the people involved in reporting and handling =
the
issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2009-08-20      102       32          29
  2009-08-10       89       27          24
  2009-08-02       76       36          28
  2009-07-27       70       51          43
  2009-07-07       35       25          21
  2009-06-29       22       22          15


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14018
Subject		: kernel freezes, inotify problem
Submitter	: Christoph Thielecke <christoph.thielecke-Mmb7MZpHnFY@public.gmane.org>
Date		: 2009-08-19 12:48 (1 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125068616818353&w=3D=
4
Handled-By	: Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14016
Subject		: mm/ipw2200 regression
Submitter	: Bartlomiej Zolnierkiewicz <bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-08-15 16:56 (5 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125036437221408&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14015
Subject		: pty regressed again, breaking expect and gcc's testsuite
Submitter	: Mikael Pettersson <mikpe-1zs4UD6AkMk@public.gmane.org>
Date		: 2009-08-14 23:41 (6 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125029329805643&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14014
Subject		: kernel bug at shut down
Submitter	: Norbert Preining <preining-DX+603jRYB8@public.gmane.org>
Date		: 2009-08-14 9:11 (6 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125024112418870&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14013
Subject		: hd don't show up
Submitter	: Tim Blechmann <tim-xpEK/MU0Hawdnm+yROfE0A@public.gmane.org>
Date		: 2009-08-14 8:26 (6 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125023842514480&w=3D=
4
Handled-By	: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14012
Subject		: latest git fried my x86_64 imac
Submitter	: Justin P. Mattock <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-08-13 07:20 (7 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125014080427090&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14011
Subject		: Kernel paging request failed in kmem_cache_alloc
Submitter	: Matthias Dahl <ml_kernel-Rk1lLwyeSiSCvTm3UDtA3g@public.gmane.org>
Date		: 2009-08-10 22:26 (10 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124993603825082&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14003
Subject		: Infinite loop on bootup while handling DMAR
Submitter	: Bernhard Rosenkraenzer <bero-9zdaV+82baBg9hUCZPvPmw@public.gmane.org>
Date		: 2009-08-18 14:54 (2 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14002
Subject		: WARNING: at net/ipv4/af_inet.c:154 inet_sock_destruct+0x164/=
0x1c0()
Submitter	: Ralf Hildebrandt <ralf.hildebrandt-jq1tPX9l7E6ELgA04lAiVw@public.gmane.org>
Date		: 2009-08-18 12:37 (2 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13987
Subject		: Received NMI interrupt at resume
Submitter	: Christian Casteyde <casteyde.christian-GANU6spQydw@public.gmane.org>
Date		: 2009-08-15 07:55 (5 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13960
Subject		: rtl8187 not connect to wifi
Submitter	: okias <d.okias-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-08-10 19:16 (10 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13950
Subject		: Oops when USB Serial disconnected while in use
Submitter	: Bruno Pr=C3=A9mont <bonbons-ud5FBsm0p/xEiooADzr8i9i2O/JbrIOy@public.gmane.org>
Date		: 2009-08-08 17:47 (12 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124975432900466&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13947
Subject		: Libertas: Association request to the driver failed
Submitter	: Daniel Mack <daniel-rDUAYElUppE@public.gmane.org>
Date		: 2009-08-07 19:11 (13 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D57921c312e8cef72ba35a4cfe870b376da0b1b87
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124967234311481&w=3D=
4
Handled-By	: Roel Kluin <roel.kluin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13943
Subject		: WARNING: at net/mac80211/mlme.c:2292 with ath5k
Submitter	: Fabio Comolli <fabio.comolli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-08-06 20:15 (14 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124958978600600&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13942
Subject		: Troubles with AoE and uninitialized object
Submitter	: Bruno Pr=C3=A9mont <bonbons-ud5FBsm0p/xEiooADzr8i9i2O/JbrIOy@public.gmane.org>
Date		: 2009-08-04 10:12 (16 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124938117104811&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13941
Subject		: x86 Geode issue
Submitter	: Martin-=C3=89ric Racine <q-funk-X3B1VOXEql0@public.gmane.org>
Date		: 2009-08-03 12:58 (17 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124930434732481&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13940
Subject		: iwlagn and sky2 stopped working, ACPI-related
Submitter	: Ricardo Jorge da Fonseca Marques Ferreira <storm@sys49152.n=
et>
Date		: 2009-08-07 22:33 (13 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124968457731107&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13935
Subject		: 2.6.31-rcX breaks Apple MightyMouse (Bluetooth version)
Submitter	: Adrian Ulrich <kernel-4ZM2p5qjiQGewZBzVTKGGg@public.gmane.org>
Date		: 2009-08-08 22:08 (12 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dfa047e4f6fa63a6e9d0ae4d7749538830d14a343


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13914
Subject		: e1000e reports invalid NVM Checksum on 82566DM-2 (bisected)
Submitter	:  <jsbronder-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Date		: 2009-08-04 18:06 (16 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13906
Subject		: Huawei E169 GPRS connection causes Ooops
Submitter	: Clemens Eisserer <linuxhippy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-08-04 09:02 (16 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13899
Subject		: Oops from tar, 2.6.31-rc5, 32 bit on quad core phenom.
Submitter	: Gene Heskett <gene.heskett-H+0wwilmMs3R7s880joybQ@public.gmane.org>
Date		: 2009-08-01 13:04 (19 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124913190304149&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13869
Subject		: Radeon framebuffer (w/o KMS) corruption at boot.
Submitter	: Duncan <1i5t5.duncan-j9pdmedNgrk@public.gmane.org>
Date		: 2009-07-29 16:44 (22 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13848
Subject		: iwlwifi (4965) regression since 2.6.30
Submitter	: Lukas Hejtmanek <xhejtman-8qz54MUs51PtwjQa/ONI9g@public.gmane.org>
Date		: 2009-07-26 7:57 (25 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124859658502866&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13836
Subject		: suspend script fails, related to stdout?
Submitter	: Tomas M. <tmezzadra-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-07-17 21:24 (34 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124785853811667&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13819
Subject		: system freeze when switching to console
Submitter	: Reinette Chatre <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date		: 2009-07-23 17:57 (28 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13809
Subject		: oprofile: possible circular locking dependency detected
Submitter	: Jerome Marchand <jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date		: 2009-07-22 13:35 (29 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13740
Subject		: X server crashes with 2.6.31-rc2 when options are changed
Submitter	: Michael S. Tsirkin <m.s.tsirkin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-07-07 15:19 (44 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13733
Subject		: 2.6.31-rc2: irq 16: nobody cared
Submitter	: Niel Lambrechts <niel.lambrechts-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-07-06 18:32 (45 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124690524027166&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13645
Subject		: NULL pointer dereference at (null) (level2_spare_pgt)
Submitter	: poornima nayak <mpnayak-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date		: 2009-06-17 17:56 (64 days old)
References	: http://lkml.org/lkml/2009/6/17/194


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14017
Subject		: _end symbol missing from Symbol.map
Submitter	: Hannes Reinecke <hare-l3A5Bk7waGM@public.gmane.org>
Date		: 2009-08-13 6:45 (7 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D091e52c3551d3031343df24b573b770b4c6c72b6
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125014649102253&w=3D=
4
Handled-By	: Hannes Reinecke <hare-l3A5Bk7waGM@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D125014649102253&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13948
Subject		: ath5k broken after suspend-to-ram
Submitter	: Johannes Stezenbach <js-FF7aIK3TAVNeoWH0uzbU5w@public.gmane.org>
Date		: 2009-08-07 21:51 (13 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124968192727854&w=3D=
4
Handled-By	: Nick Kossifidis <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/38550/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13946
Subject		: x86 MCE malfunction on Thinkpad T42p
Submitter	: Johannes Stezenbach <js-FF7aIK3TAVNeoWH0uzbU5w@public.gmane.org>
Date		: 2009-08-07 17:09 (13 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124966500232399&w=3D=
4
Handled-By	: Bartlomiej Zolnierkiewicz <bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/37908/


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions from 2=
=2E6.30,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D13615

Please let me know if there are any Bugzilla entries that should be add=
ed to
the list in there.

Thanks,
Rafael
