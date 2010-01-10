From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.33-rc3-git3: Reported regressions 2.6.31 -> 2.6.32
Date: Sun, 10 Jan 2010 23:45:48 +0100 (CET)
Message-ID: <nzLqtSp97aP.A.RGB.hglSLB@chimera>
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
=2E31 and
2.6.32, for which there are no fixes in the mainline I know of.  If any=
 of them
have been fixed already, please let me know.

If you know of any other unresolved regressions introduced between 2.6.=
31
and 2.6.32, please let me know either and I'll add them to the list.
Also, please let me know if any of the entries below are invalid.

Each entry from the list will be sent additionally in an automatic repl=
y to
this message with CCs to the people involved in reporting and handling =
the
issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2010-01-10      130       44          40
  2009-12-29      124       60          57
  2009-11-21       86       29          25
  2009-11-16       84       46          41
  2009-10-26       66       42          37
  2009-10-12       48       31          27
  2009-10-02       22       15           9


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15042
Subject		: socket(PF_INET6 hangs when ipv6 not yet initialized
Submitter	: Marc Haber <mh+linux-kernel-ciUMMiFYEj8OIzVOb1FTxg@public.gmane.org>
Date		: 2010-01-10 14:28 (1 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126313553029280&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14970
Subject		: IBM Trackpoint Device changed - Scrolling doesn't work
Submitter	: Victor Hooi <victorhooi-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
Date		: 2010-01-01 21:53 (10 days old)
Handled-By	: Dmitry Torokhov <dmitry.torokhov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14943
Subject		: nfs regression?
Submitter	: Nikola Ciprich <extmaillist-Jp3n8lUXroTtwjQa/ONI9g@public.gmane.org>
Date		: 2009-12-28 12:10 (14 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126200276223524&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14939
Subject		: drm: random hang with i915
Submitter	: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Date		: 2009-12-07 17:30 (35 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126020704125723&w=3D=
4
Handled-By	: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14933
Subject		: OOM killer unexpectedly called
Submitter	: A. Boulan <arnaud.boulan-TDf4sKD1mxeHlu7OokbhRg@public.gmane.org>
Date		: 2009-12-24 23:42 (18 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126169821317492&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14922
Subject		: 2.6.32 seemed to have broken nVidia MCP7A sata controller
Submitter	: Mike Cui <cuicui-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-12-19 6:13 (23 days old)
References	: http://marc.info/?l=3Dlinux-ide&m=3D126120323407742&w=3D4
Handled-By	: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
		  Robert Hancock <hancockrwd-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14903
Subject		: Kernel panic - not syncing: Attempted to kill init!
Submitter	: Zhiyong Wu <zwu.kernel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-12-18 4:08 (24 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126110931124738&w=3D=
4
Handled-By	: Am=C3=A9rico Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14898
Subject		: ksoftirqd problem
Submitter	: Nico <segfault2-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org>
Date		: 2009-12-13 19:05 (29 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126073114325690&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14897
Subject		: i915: Commit 0e442c60 causes flickering
Submitter	: David John <davidjon-XRr60H37pjdAfugRpC6u6w@public.gmane.org>
Date		: 2009-12-09 17:26 (33 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D0e442c60dd39ac6924b11a20497734bd2303744c
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126037889600769&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14895
Subject		: BUG in kernel 2.6.32 when using luks encrypted root and RAID=
0..
Submitter	: r4 <mk_4-aRb0bU7PRFPrBKCeMvbIDA@public.gmane.org>
Date		: 2009-12-03 18:24 (39 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125986664904751&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14894
Subject		: pohmelfs: NULL pointer dereference
Submitter	: Alexander Beregalov <a.beregalov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-12-02 1:11 (40 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125971633107940&w=3D=
4
Handled-By	: Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14892
Subject		: intel, KMS, suspend2ram resume, screen black
Submitter	: Norbert Preining <preining-DX+603jRYB8@public.gmane.org>
Date		: 2009-11-24 4:35 (48 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125903731125558&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14891
Subject		: Deadlock regression related to NFS root
Submitter	: Stephen R. van den Berg <srb-PCMv+cxZuL0@public.gmane.org>
Date		: 2009-11-24 0:24 (48 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125902279909452&w=3D=
4
Handled-By	: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14886
Subject		: Asus P2B-DS not detected as SMP moterboard
Submitter	: Lorenzo Buzzi <flinco-VGgt2q2+T+FeoWH0uzbU5w@public.gmane.org>
Date		: 2009-12-27 17:20 (15 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14868
Subject		: flood of "don't try to register things with the same name in=
 the same directory." on upgrade to 2.6.32
Submitter	: Rich Ercolani <rercola-YxllIAoeIHiVc3sceRu5cw@public.gmane.org>
Date		: 2009-12-24 02:44 (18 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14841
Subject		: unable to enumerate USB device on port X after suspend/resum=
e
Submitter	: Fruhwirth Clemens <clemens-Yy/aLhJqNSaEi8DpZVb4nw@public.gmane.org>
Date		: 2009-12-19 11:45 (23 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14817
Subject		: When is system under load, then freeze/HD fail
Submitter	: okias <d.okias-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-12-15 11:12 (27 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14783
Subject		: Unhandled IRQ on Thinkpad R61i: "irq 16: nobody cared"
Submitter	: Stefan Zegenhagen <sz-QdrG9jWwCLEAvxtiuMwx3w@public.gmane.org>
Date		: 2009-12-10 19:14 (32 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14782
Subject		: Suspend hangs Lenovo SL300 after gdm login
Submitter	: Gary Trakhman <gary.trakhman-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-12-10 18:53 (32 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3D03ba3782e8dcc5b0e1efe440d33084f066e38cae


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14748
Subject		: e1000e NIC not working after reboot
Submitter	: Maciek Sitarz <macieks-yngNwrTfnRnVItvQsEIGlw@public.gmane.org>
Date		: 2009-12-06 13:04 (36 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14747
Subject		: bisected 2.6.32 regression: synaptics touchpad doesn't work
Submitter	: Fran=C3=A7ois Valenduc <francois.valenduc-bmtTS95sd5BUM80lpFwj4w@public.gmane.org>
Date		: 2009-12-06 11:16 (36 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14742
Subject		: 2.6.32 new menu idle governor causes very high CPU temp
Submitter	:  <akwatts-DaQTI0RpDDMAvxtiuMwx3w@public.gmane.org>
Date		: 2009-12-05 17:24 (37 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14695
Subject		: regression in karmic thermal control
Submitter	: Bugie <public-ZA6dAAr5zYM@public.gmane.org>
Date		: 2009-11-26 08:45 (46 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14670
Subject		: i915: playing video via XVideo extension makes the screen fl=
icker
Submitter	: Thomas Meyer <thomas-VsYtu1Qij5c@public.gmane.org>
Date		: 2009-11-23 13:15 (49 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14667
Subject		: bisected 2.6.32 EC regression - Temperatures not correctly d=
etected after suspend - Dell Studio XPS 16 laptop
Submitter	: Federico Chiacchiaretta <federico.chia-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-11-22 20:42 (50 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14657
Subject		: perf subsystem breakage in 2.6.32-rc7
Submitter	: Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Date		: 2009-11-19 19:50 (53 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125866013419738&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14656
Subject		: Oops at __rmqueue+0x98 with 2.6.32-rc6
Submitter	: Lucas C. Villa Real <lucasvr-9gmU7qdNRpmhPH1hqNUYSQ@public.gmane.org>
Date		: 2009-11-19 3:48 (53 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125860255229092&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14625
Subject		: Commit d451564 breaks ARM
Submitter	: Russell King <rmk+lkml-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Date		: 2009-11-13 15:11 (59 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dd4515646699b6ad7b1a98ceb871296b957f3ef47
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125812520315835&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14624
Subject		: ath9k: BUG kmalloc-8192: Poison overwritten
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-11-12 4:58 (60 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125800196520396&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14621
Subject		: specjbb2005 and aim7 regression with 2.6.32-rc kernels
Submitter	: Zhang, Yanmin <yanmin_zhang-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Date		: 2009-11-06 7:38 (66 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125749310413174&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14504
Subject		: intermittent hibernation problem again
Submitter	: Ferenc W=C3=A1gner <wferi-eEbw3PyuezQ@public.gmane.org>
Date		: 2009-10-28 23:49 (75 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14487
Subject		: PANIC: early exception 08 rip 246:10 error ffffffff810251b5 =
cr2 0
Submitter	: Justin P. Mattock <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-23 16:45 (80 days old)
References	: http://lkml.org/lkml/2009/10/23/252


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14482
Subject		: kernel BUG at fs/dcache.c:670 +lvm +md +ext3
Submitter	: Alexander Clouter <alex-L4GPcECwBoDe9xe1eoZjHA@public.gmane.org>
Date		: 2009-10-23 10:30 (80 days old)
References	: http://lkml.org/lkml/2009/10/23/50


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14442
Subject		: resume after hibernate: /dev/sdb drops and returns as /dev/s=
de
Submitter	: Duncan <1i5t5.duncan-j9pdmedNgrk@public.gmane.org>
Date		: 2009-10-20 01:52 (83 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14426
Subject		: CE: hpet increasing min_delta_ns flood
Submitter	: Thibault Mondary <thibm-GANU6spQydw@public.gmane.org>
Date		: 2009-10-17 09:29 (86 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14417
Subject		: [Regression] Wireless driver iwlagn+iwlcore doesn't work aft=
er resume (needs reloading)
Submitter	: Eddy Petri=C8=99or <eddy.petrisor+linbug-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-16 11:07 (87 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14406
Subject		: uvcvideo stopped work on Toshiba
Submitter	: okias <d.okias-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-14 19:08 (89 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14376
Subject		: Kernel NULL pointer dereference/ kvm subsystem
Submitter	: Don Dupuis <dondster-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-06 14:38 (97 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125484025021737&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14298
Subject		: warning at manage.c:361 (set_irq_wake), matrix-keypad relate=
d?
Submitter	: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Date		: 2009-09-30 20:07 (103 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125434130703538&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14297
Subject		: console resume broken since ba15ab0e8d
Submitter	: Sascha Hauer <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Date		: 2009-09-30 15:11 (103 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125432349404060&w=3D=
4


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15040
Subject		: High cpu temperature with 2.6.32
Submitter	: Dimitrios Apostolou <jimis-hi6Y0CQ0nG0@public.gmane.org>
Date		: 2010-01-06 17:39 (5 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126279952723036&w=3D=
4
Handled-By	: Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/71962/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14896
Subject		: REGRESSION for RT2561/RT61 in 2.6.32, related to power savin=
g
Submitter	: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Date		: 2009-12-06 22:12 (36 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126013756829691&w=3D=
4
Handled-By	: Gertjan van Wingerde <gwingerde-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/67338/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14889
Subject		: System wakeup by time not working anymore
Submitter	: Malte Schr=C3=B6der <maltesch-Mmb7MZpHnFY@public.gmane.org>
Date		: 2009-12-03 18:06 (39 days old)
=46irst-Bad-Commit: http://git.kernel.org/?p=3Dlinux/kernel/git/torvald=
s/linux-2.6.git;a=3Dcommit;h=3Dabd6633c67925f90775bb74755f9c547e30f1f20
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125986362631900&w=3D=
4
Handled-By	: OGAWA Hirofumi <hirofumi-UIVanBePwB70ZhReMnHkpc8NsWr+9BEh@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/70212/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14483
Subject		: Interrupts enabled after irqrouter_resume - iMac9,1
Submitter	: Justin Mattock <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-25 19:58 (78 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125650070420168&w=3D=
4
Handled-By	: Xiaotian Feng <dfeng-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/64771/


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions introd=
uced
between 2.6.31 and 2.6.32, unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D14230

Please let me know if there are any Bugzilla entries that should be add=
ed to
the list in there.

Thanks,
Rafael
