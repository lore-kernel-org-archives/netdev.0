From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.31-rc7-git2: Reported regressions from 2.6.30
Date: Tue, 25 Aug 2009 22:00:19 +0200 (CEST)
Message-ID: <riPp5fx5ECC.A.2IG.qsGlKB@chimera>
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
  2009-08-26      108       33          26
  2009-08-20      102       32          29
  2009-08-10       89       27          24
  2009-08-02       76       36          28
  2009-07-27       70       51          43
  2009-07-07       35       25          21
  2009-06-29       22       22          15


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14060
Subject		: oops: sysfs_remove_link and i915
Submitter	: Dominik Brodowski <linux-X3ehHDuj6sIIGcDfoQAp7OTW4wlIGRCZ@public.gmane.org>
Date		: 2009-08-22 5:48 (4 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125092139113955&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14058
Subject		: Oops in fsnotify
Submitter	: Grant Wilson <grant.wilson-1HOZaDBbGgxaa/9Udqfwiw@public.gmane.org>
Date		: 2009-08-20 15:48 (6 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125078450923133&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14057
Subject		: Strange network timeouts w/ e100
Submitter	: Walt Holman <walt-Wo+ox+avW/9ByuSxxbvQtw@public.gmane.org>
Date		: 2009-08-20 0:21 (6 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125072831831443&w=3D=
4
Handled-By	: Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14031
Subject		: dvb_usb_af9015: Oops on hotplugging
Submitter	: Stefan Lippers-Hollmann <s.L-H-Mmb7MZpHnFY@public.gmane.org>
Date		: 2009-08-05 20:32 (21 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124949716608828&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14018
Subject		: kernel freezes, inotify problem
Submitter	: Christoph Thielecke <christoph.thielecke-Mmb7MZpHnFY@public.gmane.org>
Date		: 2009-08-19 12:48 (7 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125068616818353&w=3D=
4
Handled-By	: Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14016
Subject		: mm/ipw2200 regression
Submitter	: Bartlomiej Zolnierkiewicz <bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-08-15 16:56 (11 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125036437221408&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14015
Subject		: pty regressed again, breaking expect and gcc's testsuite
Submitter	: Mikael Pettersson <mikpe-1zs4UD6AkMk@public.gmane.org>
Date		: 2009-08-14 23:41 (12 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125029329805643&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14013
Subject		: hd don't show up
Submitter	: Tim Blechmann <tim-xpEK/MU0Hawdnm+yROfE0A@public.gmane.org>
Date		: 2009-08-14 8:26 (12 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125023842514480&w=3D=
4
Handled-By	: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14012
Subject		: latest git fried my x86_64 imac
Submitter	: Justin P. Mattock <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-08-13 07:20 (13 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125014080427090&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14011
Subject		: Kernel paging request failed in kmem_cache_alloc
Submitter	: Matthias Dahl <ml_kernel-Rk1lLwyeSiSCvTm3UDtA3g@public.gmane.org>
Date		: 2009-08-10 22:26 (16 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124993603825082&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13987
Subject		: Received NMI interrupt at resume
Submitter	: Christian Casteyde <casteyde.christian-GANU6spQydw@public.gmane.org>
Date		: 2009-08-15 07:55 (11 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13950
Subject		: Oops when USB Serial disconnected while in use
Submitter	: Bruno Pr=C3=A9mont <bonbons-ud5FBsm0p/xEiooADzr8i9i2O/JbrIOy@public.gmane.org>
Date		: 2009-08-08 17:47 (18 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124975432900466&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13943
Subject		: WARNING: at net/mac80211/mlme.c:2292 with ath5k
Submitter	: Fabio Comolli <fabio.comolli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-08-06 20:15 (20 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124958978600600&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13942
Subject		: Troubles with AoE and uninitialized object
Submitter	: Bruno Pr=C3=A9mont <bonbons-ud5FBsm0p/xEiooADzr8i9i2O/JbrIOy@public.gmane.org>
Date		: 2009-08-04 10:12 (22 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124938117104811&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13941
Subject		: x86 Geode issue
Submitter	: Martin-=C3=89ric Racine <q-funk-X3B1VOXEql0@public.gmane.org>
Date		: 2009-08-03 12:58 (23 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124930434732481&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13940
Subject		: iwlagn and sky2 stopped working, ACPI-related
Submitter	: Ricardo Jorge da Fonseca Marques Ferreira <storm@sys49152.n=
et>
Date		: 2009-08-07 22:33 (19 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124968457731107&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13935
Subject		: 2.6.31-rcX breaks Apple MightyMouse (Bluetooth version)
Submitter	: Adrian Ulrich <kernel-4ZM2p5qjiQGewZBzVTKGGg@public.gmane.org>
Date		: 2009-08-08 22:08 (18 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dfa047e4f6fa63a6e9d0ae4d7749538830d14a343


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13906
Subject		: Huawei E169 GPRS connection causes Ooops
Submitter	: Clemens Eisserer <linuxhippy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-08-04 09:02 (22 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13869
Subject		: Radeon framebuffer (w/o KMS) corruption at boot.
Submitter	: Duncan <1i5t5.duncan-j9pdmedNgrk@public.gmane.org>
Date		: 2009-07-29 16:44 (28 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13848
Subject		: iwlwifi (4965) regression since 2.6.30
Submitter	: Lukas Hejtmanek <xhejtman-8qz54MUs51PtwjQa/ONI9g@public.gmane.org>
Date		: 2009-07-26 7:57 (31 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124859658502866&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13836
Subject		: suspend script fails, related to stdout?
Submitter	: Tomas M. <tmezzadra-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-07-17 21:24 (40 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124785853811667&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13819
Subject		: system freeze when switching to console
Submitter	: Reinette Chatre <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date		: 2009-07-23 17:57 (34 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13809
Subject		: oprofile: possible circular locking dependency detected
Submitter	: Jerome Marchand <jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date		: 2009-07-22 13:35 (35 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13740
Subject		: X server crashes with 2.6.31-rc2 when options are changed
Submitter	: Michael S. Tsirkin <m.s.tsirkin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-07-07 15:19 (50 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13733
Subject		: 2.6.31-rc2: irq 16: nobody cared
Submitter	: Niel Lambrechts <niel.lambrechts-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-07-06 18:32 (51 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124690524027166&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13645
Subject		: NULL pointer dereference at (null) (level2_spare_pgt)
Submitter	: poornima nayak <mpnayak-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date		: 2009-06-17 17:56 (70 days old)
References	: http://lkml.org/lkml/2009/6/17/194


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14062
Subject		: Failure to boot as xen guest
Submitter	: Arnd Hannemann <hannemann-JasiFyN5vQG662+jY7v6MhvVK+yQ3ZXh@public.gmane.org>
Date		: 2009-08-25 15:48 (1 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D83b519e8b9572c319c8e0c615ee5dd7272856090
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125121534229538&w=3D=
4
Handled-By	: Jeremy Fitzhardinge <jeremy-TSDbQ3PG+2Y@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/43799/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14061
Subject		: Crash due to buggy flat_phys_pkg_id
Submitter	: Ravikiran G Thirumalai <kiran-HAaLjvVgespg9hUCZPvPmw@public.gmane.org>
Date		: 2009-08-24 18:26 (2 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125114085701508&w=3D=
4
Handled-By	: Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/43806/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14030
Subject		: Kernel NULL pointer dereference at 0000000000000008, pty-rel=
ated
Submitter	: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Date		: 2009-08-20 5:46 (6 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125074724623423&w=3D=
4
Handled-By	: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/43679/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14017
Subject		: _end symbol missing from Symbol.map
Submitter	: Hannes Reinecke <hare-l3A5Bk7waGM@public.gmane.org>
Date		: 2009-08-13 6:45 (13 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D091e52c3551d3031343df24b573b770b4c6c72b6
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125014649102253&w=3D=
4
Handled-By	: Hannes Reinecke <hare-l3A5Bk7waGM@public.gmane.org>
Patch		: http://marc.info/?l=3Dlinux-kernel&m=3D125014649102253&w=3D4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13960
Subject		: rtl8187 not connect to wifi
Submitter	: okias <d.okias-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-08-10 19:16 (16 days old)
Handled-By	: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Patch		: http://bugzilla.kernel.org/attachment.cgi?id=3D22798


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13948
Subject		: ath5k broken after suspend-to-ram
Submitter	: Johannes Stezenbach <js-FF7aIK3TAVNeoWH0uzbU5w@public.gmane.org>
Date		: 2009-08-07 21:51 (19 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124968192727854&w=3D=
4
Handled-By	: Nick Kossifidis <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/38550/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D13947
Subject		: Libertas: Association request to the driver failed
Submitter	: Daniel Mack <daniel-rDUAYElUppE@public.gmane.org>
Date		: 2009-08-07 19:11 (19 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D57921c312e8cef72ba35a4cfe870b376da0b1b87
References	: http://marc.info/?l=3Dlinux-kernel&m=3D124967234311481&w=3D=
4
Handled-By	: Roel Kluin <roel.kluin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
		  Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/43114/


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
