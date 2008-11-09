From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.28-rc3-git6: Reported regressions from 2.6.27
Date: Sun,  9 Nov 2008 18:53:01 +0100 (CET)
Message-ID: <YrUCLn0F-xH.A.fhE.E4zFJB@chimera>
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
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This message contains a list of some regressions from 2.6.27, for which=
 there
are no fixes in the mainline I know of.  If any of them have been fixed=
 already,
please let me know.

If you know of any other unresolved regressions from 2.6.27, please let=
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
  2008-11-09       73       40          27
  2008-11-02       55       41          29
  2008-10-25       26       25          20


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11996
Subject		: Tracing framework regression in 2.6.28-rc3
Submitter	: Pekka Paalanen <pq-X3B1VOXEql0@public.gmane.org>
Date		: 2008-11-09 10:13 (1 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122624392229317&w=3D=
4
Handled-By	: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11994
Subject		: Computer doesn't power down after commit CPI: EC: do transac=
tion from interrupt context
Submitter	: Fran=C3=A7ois Valenduc <francois.valenduc-bmtTS95sd5BUM80lpFwj4w@public.gmane.org>
Date		: 2008-11-09 02:02 (1 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D5ceb40417bca2045350e77f740e0c4c94875fff2
Handled-By	: ykzhao <yakui.zhao-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11989
Subject		: Suspend failure on NForce4-based boards due to chanes in sto=
p_machine
Submitter	: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>
Date		: 2008-11-03 0:28 (7 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dc9583e55fa2b08a230c549bd1e3c0bde6c50d9cc
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122567187604356&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11987
Subject		: Bootup time regression from 2.6.27 to 2.6.28-rc3+
Submitter	: Lukas Hejtmanek <xhejtman-8qz54MUs51PtwjQa/ONI9g@public.gmane.org>
Date		: 2008-11-04 17:33 (6 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122582006601658&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11986
Subject		: 2.6.28-rc2-git1: spitz still won't boot
Submitter	: Pavel Machek <pavel-AlSwsSmVLrQ@public.gmane.org>
Date		: 2008-11-05 14:23 (5 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122589528016337&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11984
Subject		: regression when switching TTY-&gt;X, input related?
Submitter	: Bernhard Schmidt <berni-wpePDvIxQxvMZTq/7ZfH4Q@public.gmane.org>
Date		: 2008-11-05 22:04 (5 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122592278403853&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11970
Subject		: gettimeofday return a old time in mmbench
Submitter	: alexs <alex.shi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date		: 2008-11-06 23:57 (4 days old)
Handled-By	: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11965
Subject		: regression introduced by - timers: fix itimer/many thread ha=
ng
Submitter	: Doug Chapman <doug.chapman-VXdhtT5mjnY@public.gmane.org>
Date		: 2008-11-06 11:03 (4 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Df06febc96ba8e0af80bcc3eaec0a109e88275fac
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122596943416648&w=3D=
4
Handled-By	: Frank Mayhar <fmayhar-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
		  Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
		  Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11958
Subject		: [2.6.27.x =3D&gt; 2.6.28-rc3] Xorg crash with xf86MapVidMem =
error
Submitter	: Tomasz Chmielewski <tch-Nem3ZqsbT/g@public.gmane.org>
Date		: 2008-11-05 05:37 (5 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11947
Subject		: 2.6.28-rc VC switching with Intel graphics broken
Submitter	: Romano Giannetti <romano.giannetti-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2008-11-03 12:10 (7 days old)
Handled-By	: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11928
Subject		: ath5k gets lost with eeepc-laptop removal
Submitter	: Luiz Fernando N. Capitulino <lcapitulino-4qZELD6Fgxg39yzSjRtAkw@public.gmane.org>
Date		: 2008-10-31 13:05 (10 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122545827204957&w=3D=
4
Handled-By	: Nick Kossifidis <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11913
Subject		: USB/INPUT: slab error in cache_alloc_debugcheck_after(): dou=
ble free?
Submitter	: Helge Deller <deller-Mmb7MZpHnFY@public.gmane.org>
Date		: 2008-10-30 23:11 (11 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dcb8f488c33539f096580e202f5438a809195008f
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122540833301394&w=3D=
4
Handled-By	: Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>
		  Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
		  Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>
		  Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
		  Denys Vlasenko <vda.linux-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11908
Subject		: linux-2.6.28-rc2 regression : oprofile doesnt work anymore
Submitter	: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Date		: 2008-10-30 18:01 (11 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dc493756e2a8a78bcaae30668317890dcfe86e7c3
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122539004100532&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11906
Subject		: 2.6.28-rc2 seems to fail at powering down the monitor when i=
t should
Submitter	: Gene Heskett <gene.heskett-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2008-10-30 6:39 (11 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122534879721424&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11905
Subject		: lots of extra timer interrupts costing 2W
Submitter	: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>
Date		: 2008-10-30 2:18 (11 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dfb02fbc14d17837b4b7b02dbb36142c16a7bf208
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122533314305315&w=3D=
4
		  http://marc.info/?l=3Dlinux-kernel&m=3D122541849114444&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11899
Subject		: sometime boot failed on T61 laptop
Submitter	: alexs <alex.shi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date		: 2008-10-30 02:04 (11 days old)
Handled-By	: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11896
Subject		: [2.6.28-rc2] EeePC ACPI errors &amp; exceptions
Submitter	: Darren Salt <linux-Ym6Ivm/Ks7B65+NM0QMiFAbYiX8G1TQY9dF7HbQ/qKg@public.gmane.org>
Date		: 2008-10-27 22:52 (14 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122514911328761&w=3D=
4
Handled-By	: Alexey Starikovskiy <aystarik-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
		  Zhao Yakui <yakui.zhao-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11891
Subject		: resume from disk broken on hp/compaq nx7000 (DRM problem)
Submitter	: Markus Meier <maekke-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Date		: 2008-10-29 14:42 (12 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D0a3e67a4caac273a3bfc4ced3da364830b1ab241
Handled-By	: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11875
Subject		: radeonfb lockup in .28-rc (bisected)
Submitter	: James Cloos <cloos-GRsvFm/Gh/pBDgjK7y7TUQ@public.gmane.org>
Date		: 2008-10-28 0:00 (13 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Db1ee26bab14886350ba12a5c10cbc0696ac679bf
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122515210200530&w=3D=
4
Handled-By	: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11873
Subject		: unable to mount ext3 root filesystem due to htree_dirblock_t=
o_tree
Submitter	: Jimmy.Jazz-hi6Y0CQ0nG0@public.gmane.org
Date		: 2008-10-28 05:09 (13 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D4c46501d1659475dc6c89554af6ce7fe6ecf615c
Handled-By	: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
		  Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11858
Subject		: Timeout regression introduced by 242f9dcb8ba6f68fcd217a119a7=
648a4f69290e9
Submitter	: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date		: 2008-10-26 9:46 (15 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D242f9dcb8ba6f68fcd217a119a7648a4f69290e9
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122501447326698&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11849
Subject		: default IRQ affinity change in v2.6.27 (breaking several SMP=
 PPC based systems)
Submitter	: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Date		: 2008-10-24 12:45 (17 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122485245924125&w=3D=
4
Handled-By	: Chris Snook <csnook-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
		  Scott Wood <scottwood-KZfg59tc24xl57MIdRCFDg@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11834
Subject		: iwl3945: if I leave my machine running overnight, wifi will =
not work in the morning
Submitter	: Pavel Machek <pavel-AlSwsSmVLrQ@public.gmane.org>
Date		: 2008-10-19 21:40 (22 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122445440206101&w=3D=
4
Handled-By	: reinette chatre <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11828
Subject		: Linux 2.6.27-git3: no SD card reader
Submitter	: J.A. Magall=C3=B3n <jamagallon-sh/6fXdz2Rs@public.gmane.org>
Date		: 2008-10-14 0:54 (27 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122394573904699&w=3D=
4
Handled-By	: Pierre Ossman <drzeus-list-p3sGCRWkH8CeZLLa646FqQ@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11826
Subject		: extreme slowness of IO stuff using 2.6.28-rc1
Submitter	: Yves-Alexis Perez <corsac-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org>
Date		: 2008-10-25 04:25 (16 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Ddc4304f7deee29fcdf6a2b62f7146ea7f505fd42
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122521238402963&w=3D=
4
Handled-By	: Arjan van de Ven <arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11822
Subject		: ACPI Warning (nspredef-0858): _SB_.PCI0.LPC_.EC__.BAT0._BIF:=
 Return Package type mismatch at index 9 - found Buffer, expected Strin=
g [20080926]
Submitter	: Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date		: 2008-10-25 01:26 (16 days old)
Handled-By	: Robert Moore <Robert.Moore-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11799
Subject		: xorg can not start up with stolen memory
Submitter	: arrow zhang <arrow.ebd-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2008-10-21 06:08 (20 days old)


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11988
Subject		: Eliminate recursive mutex in compat fb ioctl path
Submitter	: Keith Packard <keithp-aN4HjG94KOLQT0dZR+AlfA@public.gmane.org>
Date		: 2008-11-03 7:06 (7 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122569604828448&w=3D=
4
Handled-By	: Keith Packard <keithp-aN4HjG94KOLQT0dZR+AlfA@public.gmane.org>
		  Geert Uytterhoeven <Geert.Uytterhoeven-osDt5Q4Chk1BDgjK7y7TUQ@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122569604828448&w=3D4
		  http://lkml.org/lkml/2008/10/31/162


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11985
Subject		: 2.6.28-rc3 truncates nfsd results
Submitter	: Doug Nazar <nazard-9NxrcwDPlTov2OKnPYDugg@public.gmane.org>
Date		: 2008-11-04 18:27 (6 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122582366509153&w=3D=
4
Handled-By	: Doug Nazar <nazard-9NxrcwDPlTov2OKnPYDugg@public.gmane.org>
		  J. Bruce Fields <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122592648119790&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11982
Subject		: Fan level 7 after resume wit 2.6.28-rc3
Submitter	: Tino Keitel <tino.keitel-rAwCM5oiXHA@public.gmane.org>
Date		: 2008-11-05 7:33 (5 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122587043409186&w=3D=
4
Handled-By	: Henrique de Moraes Holschuh <hmh-N3TV7GIv+o9fyO9Q7EP/yw@public.gmane.org>
Patch		: http://bugzilla.kernel.org/attachment.cgi?id=3D18744&action=3D=
view


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11942
Subject		: AMD64 reboot regression
Submitter	: Michael B. Trausch <mike-cRPrJ27hGUicqzYg7KEe8g@public.gmane.org>
Date		: 2008-11-02 20:30 (8 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122565790519736&w=3D=
4
Handled-By	: Len Brown <lenb-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Patch		: http://bugzilla.kernel.org/show_bug.cgi?id=3D11942#c11


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11937
Subject		: ext3 __log_wait_for_space: no transactions
Submitter	: Meelis Roos <mroos-Y27EyoLml9s@public.gmane.org>
Date		: 2008-10-30 9:49 (11 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122536026105643&w=3D=
4
Handled-By	: Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>
Patch		: http://lkml.org/lkml/2008/11/1/61


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11925
Subject		: cdrom: missing compat ioctls
Submitter	: Andreas Schwab <schwab-l3A5Bk7waGM@public.gmane.org>
Date		: 2008-10-31 14:02 (10 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D33c2dca4957bd0da3e1af7b96d0758d97e708ef6
Handled-By	: Andreas Schwab <schwab-l3A5Bk7waGM@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122548923531545&w=3D2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11917
Subject		: Asus Eee PC hotkeys stop working after prolonged usage
Submitter	: Alan Jenkins <alan-jenkins-cCz0Lq7MMjm9FHfhHBbuYA@public.gmane.org>
Date		: 2008-10-31 03:21 (10 days old)
Handled-By	: Alexey Starikovskiy <astarikovskiy-l3A5Bk7waGM@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-acpi&m=3D122603281422097&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11911
Subject		: new PCMCIA device instance after resume - orinoco can't down=
load firmware
Submitter	: Andrey Borzenkov <arvidjaar-JGs/UdohzUI@public.gmane.org>
Date		: 2008-10-28 19:19 (13 days old)
References	: http://marc.info/?l=3Dlinux-wireless&m=3D122522165719760&w=
=3D4
Handled-By	: Dave <kilroyd-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-wireless&m=3D122539058601588&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11903
Subject		: regression: vmalloc easily fail
Submitter	: Glauber Costa <glommer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date		: 2008-10-28 20:59 (13 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Ddb64fe02258f1507e13fe5212a989922323685ce
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122522755530998&w=3D=
4
Handled-By	: Glauber Costa <glommer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
		  Nick Piggin <npiggin-l3A5Bk7waGM@public.gmane.org>
		  Glauber Costa <glommer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122609055221549&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11898
Subject		: mke2fs hang on AIC79 device.
Submitter	: alexs <alex.shi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date		: 2008-10-30 01:17 (11 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Df0c0a376d0fcd4c5579ecf5e95f88387cba85211
Handled-By	: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Patch		: http://bugzilla.kernel.org/show_bug.cgi?id=3D11898#c28


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11895
Subject		: 2.6.28-rc2 regression: keyboard dead after reboot on Toshiba=
 Portege 4000
Submitter	: Andrey Borzenkov <arvidjaar-JGs/UdohzUI@public.gmane.org>
Date		: 2008-10-28 19:05 (13 days old)
References	: http://marc.info/?l=3Dlinux-acpi&m=3D122522085418555&w=3D4
Handled-By	: Andrey Borzenkov <arvidjaar-JGs/UdohzUI@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122547719810921&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11841
Subject		: plenty of line "ACPI: EC: non-query interrupt received, swit=
ching to interrupt mode" in dmesg and system not powering down
Submitter	: Fran=C3=A7ois Valenduc <francois.valenduc-bmtTS95sd5BUM80lpFwj4w@public.gmane.org>
Date		: 2008-10-25 10:29 (16 days old)
Handled-By	: Alan Jenkins <alan-jenkins-cCz0Lq7MMjm9FHfhHBbuYA@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-acpi&m=3D122603281922125&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11806
Subject		: iwl3945 fails with microcode error
Submitter	: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date		: 2008-10-22 02:36 (19 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122450235730661&w=3D=
4
Handled-By	: Reinette Chatre <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-wireless&m=3D122583010822172&w=3D2


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions from 2=
=2E6.27,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D11808

Please let me know if there are any Bugzilla entries that should be add=
ed to
the list in there.

Thanks,
Rafael
