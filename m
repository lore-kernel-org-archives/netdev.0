From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.28-rc2-git7: Reported regressions from 2.6.27
Date: Sun,  2 Nov 2008 17:04:20 +0100 (CET)
Message-ID: <603i_OdVYPF.A.7_D.mjeDJB@chimera>
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
  2008-11-02       55       41          29
  2008-10-25       26       25          20


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11937
Subject		: ext3 __log_wait_for_space: no transactions
Submitter	: Meelis Roos <mroos-Y27EyoLml9s@public.gmane.org>
Date		: 2008-10-30 9:49 (4 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122536026105643&w=3D=
4
Handled-By	: Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11928
Subject		: ath5k gets lost with eeepc-laptop removal
Submitter	: Luiz Fernando N. Capitulino <lcapitulino-4qZELD6Fgxg39yzSjRtAkw@public.gmane.org>
Date		: 2008-10-31 13:05 (3 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122545827204957&w=3D=
4
Handled-By	: Nick Kossifidis <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11913
Subject		: USB/INPUT: slab error in cache_alloc_debugcheck_after(): dou=
ble free?
Submitter	: Helge Deller <deller-Mmb7MZpHnFY@public.gmane.org>
Date		: 2008-10-30 23:11 (4 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122540833301394&w=3D=
4
Handled-By	: Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>
		  Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11910
Subject		: System doesn't restart
Submitter	: Thomas Meyer <thomas-VsYtu1Qij5c@public.gmane.org>
Date		: 2008-10-30 20:35 (4 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122539897518110&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11909
Subject		: initrd fails to create bloc devices
Submitter	: Andrey Borzenkov <arvidjaar-JGs/UdohzUI@public.gmane.org>
Date		: 2008-10-30 18:48 (4 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122539280706439&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11908
Subject		: linux-2.6.28-rc2 regression : oprofile doesnt work anymore
Submitter	: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Date		: 2008-10-30 18:01 (4 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122539004100532&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11906
Subject		: 2.6.28-rc2 seems to fail at powering down the monitor when i=
t should
Submitter	: Gene Heskett <gene.heskett-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2008-10-30 6:39 (4 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122534879721424&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11905
Subject		: lots of extra timer interrupts costing 2W
Submitter	: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>
Date		: 2008-10-30 2:18 (4 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122533314305315&w=3D=
4
		  http://marc.info/?l=3Dlinux-kernel&m=3D122541849114444&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11901
Subject		: ath5k triggers WARN_ON in __ieee80211_rx
Submitter	: Bob Copeland <me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org>
Date		: 2008-10-30 09:15 (4 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11899
Subject		: sometime boot failed on T61 laptop
Submitter	: alexs <alex.shi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date		: 2008-10-30 02:04 (4 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11898
Subject		: mke2fs hang on AIC79 device.
Submitter	: alexs <alex.shi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date		: 2008-10-30 01:17 (4 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11894
Subject		: 2.6.28-rc2 / hso driver oops
Submitter	: Jonathan McDowell <noodles-4QvXXjU8Dv4@public.gmane.org>
Date		: 2008-10-29 16:40 (5 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122529846811013&w=3D=
4
Handled-By	: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11891
Subject		: resume from disk broken on hp/compaq nx7000 (DRM problem)
Submitter	: Markus Meier <maekke-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Date		: 2008-10-29 14:42 (5 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11882
Subject		: dbench 15% regression with 2.6.28-rc1
Submitter	: Zhang, Yanmin <yanmin_zhang-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Date		: 2008-10-28 8:41 (6 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122518333103345&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11881
Subject		: Linux 2.6.28-rc2 i/o error on /dev/ttyUSB0
Submitter	: Helge Hafting <helge.hafting-i5bjtSbraLbLX0NG8FE4ug@public.gmane.org>
Date		: 2008-10-28 11:19 (6 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122519319922377&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11875
Subject		: radeonfb lockup in .28-rc (bisected)
Submitter	: James Cloos <cloos-GRsvFm/Gh/pBDgjK7y7TUQ@public.gmane.org>
Date		: 2008-10-28 0:00 (6 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122515210200530&w=3D=
4
Handled-By	: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11873
Subject		: unable to mount ext3 root filesystem due to htree_dirblock_t=
o_tree
Submitter	: Jimmy.Jazz-hi6Y0CQ0nG0@public.gmane.org
Date		: 2008-10-28 05:09 (6 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11858
Subject		: Timeout regression introduced by 242f9dcb8ba6f68fcd217a119a7=
648a4f69290e9
Submitter	: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date		: 2008-10-26 9:46 (8 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122501447326698&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11856
Subject		: seq_file does not handle pread()
Submitter	: Petr Vandrovec <vandrove-hnqZr3NxcozrBKCeMvbIDA@public.gmane.org>
Date		: 2008-10-25 17:40 (9 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11854
Subject		: v2.6.28-rc1: readlink /proc/*/exe returns uninitialized data=
 to userspace
Submitter	: Vegard Nossum <vegard.nossum-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2008-10-25 17:14 (9 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122495490201663&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11849
Subject		: default IRQ affinity change in v2.6.27 (breaking several SMP=
 PPC based systems)
Submitter	: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Date		: 2008-10-24 12:45 (10 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122485245924125&w=3D=
4
Handled-By	: Chris Snook <csnook-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
		  Scott Wood <scottwood-KZfg59tc24xl57MIdRCFDg@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11841
Subject		: plenty of line "ACPI: EC: non-query interrupt received, swit=
ching to interrupt mode" in dmesg
Submitter	: Fran=C3=A7ois Valenduc <francois.valenduc-bmtTS95sd5BUM80lpFwj4w@public.gmane.org>
Date		: 2008-10-25 10:29 (9 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11834
Subject		: iwl3945: if I leave my machine running overnight, wifi will =
not work in the morning
Submitter	: Pavel Machek <pavel-AlSwsSmVLrQ@public.gmane.org>
Date		: 2008-10-19 21:40 (15 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122445440206101&w=3D=
4
Handled-By	: reinette chatre <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11828
Subject		: Linux 2.6.27-git3: no SD card reader
Submitter	: J.A. Magall=C3=B3n <jamagallon-sh/6fXdz2Rs@public.gmane.org>
Date		: 2008-10-14 0:54 (20 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122394573904699&w=3D=
4
Handled-By	: Pierre Ossman <drzeus-list-p3sGCRWkH8CeZLLa646FqQ@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11826
Subject		: extreme slowness of IO stuff using 2.6.28-rc1
Submitter	: Yves-Alexis Perez <corsac-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org>
Date		: 2008-10-25 04:25 (9 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122521238402963&w=3D=
4
Handled-By	: Arjan van de Ven <arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11822
Subject		: ACPI Warning (nspredef-0858): _SB_.PCI0.LPC_.EC__.BAT0._BIF:=
 Return Package type mismatch at index 9 - found Buffer, expected Strin=
g [20080926]
Submitter	: Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date		: 2008-10-25 01:26 (9 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11806
Subject		: iwl3945 fails with microcode error
Submitter	: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date		: 2008-10-22 02:36 (12 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122450235730661&w=3D=
4
Handled-By	: Reinette Chatre <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11799
Subject		: xorg can not start up with stolen memory
Submitter	: arrow zhang <arrow.ebd-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2008-10-21 06:08 (13 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11798
Subject		: [Radeon Xpress 1100 IGP] DRI fail on recent kernel updates
Submitter	: Gu Rui <chaos.proton-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2008-10-21 04:28 (13 days old)


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11940
Subject		: Unable to handle kernel paging request at iov_iter_copy_from=
_user_atomic
Submitter	: Alexander Beregalov <a.beregalov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2008-11-01 14:23 (2 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122554945922521&w=3D=
4
Handled-By	: Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122556602913200&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11927
Subject		: undefined reference to `save_stack_trace'
Submitter	: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2008-10-31 16:57 (3 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122547246401190&w=3D=
4
Handled-By	: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122548268920986&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11925
Subject		: cdrom: missing compat ioctls
Submitter	: Andreas Schwab <schwab-l3A5Bk7waGM@public.gmane.org>
Date		: 2008-10-31 14:02 (3 days old)
Handled-By	: Andreas Schwab <schwab-l3A5Bk7waGM@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122548923531545&w=3D2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11917
Subject		: Asus Eee PC hotkeys stop working after prolonged usage
Submitter	: Alan Jenkins <alan-jenkins-cCz0Lq7MMjm9FHfhHBbuYA@public.gmane.org>
Date		: 2008-10-31 03:21 (3 days old)
Handled-By	: Alexey Starikovskiy <astarikovskiy-l3A5Bk7waGM@public.gmane.org>
Patch		: http://bugzilla.kernel.org/attachment.cgi?id=3D18558&action=3D=
view


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11911
Subject		: new PCMCIA device instance after resume - orinoco can't down=
load firmware
Submitter	: Andrey Borzenkov <arvidjaar-JGs/UdohzUI@public.gmane.org>
Date		: 2008-10-28 19:19 (6 days old)
References	: http://marc.info/?l=3Dlinux-wireless&m=3D122522165719760&w=
=3D4
Handled-By	: Dave <kilroyd-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-wireless&m=3D122539058601588&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11903
Subject		: regression: vmalloc easily fail
Submitter	: Glauber Costa <glommer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date		: 2008-10-28 20:59 (6 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122522755530998&w=3D=
4
Handled-By	: Glauber Costa <glommer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
		  Nick Piggin <npiggin-l3A5Bk7waGM@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122522755530998&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11895
Subject		: 2.6.28-rc2 regression: keyboard dead after reboot on Toshiba=
 Portege 4000
Submitter	: Andrey Borzenkov <arvidjaar-JGs/UdohzUI@public.gmane.org>
Date		: 2008-10-28 19:05 (6 days old)
References	: http://marc.info/?l=3Dlinux-acpi&m=3D122522085418555&w=3D4
Handled-By	: Andrey Borzenkov <arvidjaar-JGs/UdohzUI@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122547719810921&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11852
Subject		: v2.6.28-rc1: Regression in ext3/jbd
Submitter	: Vegard Nossum <vegard.nossum-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2008-10-25 11:22 (9 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122493379905812&w=3D=
4
Handled-By	: Hidehiro Kawai <hidehiro.kawai.ez-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122510792614388&w=3D4
		  http://marc.info/?l=3Dlinux-kernel&m=3D122510828015045&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11847
Subject		: 2.6.28-rc1 fails building on allnoconfig
Submitter	: Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org>
Date		: 2008-10-24 17:09 (10 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D122487097728241&w=3D=
4
		  http://marc.info/?l=3Dlinux-pci&m=3D122485633732409&w=3D4
Handled-By	: Fenghua Yu <fenghua.yu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122487160129531&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11845
Subject		: Suspend regression on Lenovo x60
Submitter	: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Date		: 2008-10-24 18:02 (10 days old)
References	: http://marc.info/?l=3Dlinux-next&m=3D122487159829507&w=3D4
		  http://marc.info/?l=3Dlinux-kernel&m=3D122512449714310&w=3D4
Handled-By	: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>
		  Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122513311900482&w=3D4
		  http://marc.info/?l=3Dlinux-wireless&m=3D122518625308673&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11838
Subject		: general protection fault: =C2=A0from release_blocks_on_commi=
t
Submitter	: Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date		: 2008-10-21 14:03 (13 days old)
References	: http://lkml.org/lkml/2008/10/21/248
Handled-By	: Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D122516096811142&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D11824
Subject		: raw1394: possible deadlock if accessed by multithreaded app
Submitter	: Stefan Richter <stefan-r-bz-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>
Date		: 2008-10-25 02:08 (9 days old)
Handled-By	: Stefan Richter <stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>
Patch		: http://bugzilla.kernel.org/show_bug.cgi?id=3D11824#c3


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
