From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.33-rc7: Reported regressions 2.6.31 -> 2.6.32
Date: Mon,  8 Feb 2010 01:13:35 +0100 (CET)
Message-ID: <2uzMDuY-7_O.A.M1G.7X1bLB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
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

This message contains a list of some post-2.6.31 regressions introduced=
 before
2.6.32, for which there are no fixes in the mainline known to the track=
ing team.
If any of them have been fixed already, please let us know.

If you know of any other unresolved post-2.6.31 regressions, please let=
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
  2010-02-08      155       47          37
  2010-02-01      149       50          45
  2010-01-24      140       45          43
  2010-01-10      130       44          40
  2009-12-29      124       60          57
  2009-11-21       86       29          25
  2009-11-16       84       46          41
  2009-10-26       66       42          37
  2009-10-12       48       31          27
  2009-10-02       22       15           9


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15220
Subject		: Kernel freezes when playing DVB stream and having 3D acceler=
ation in the same time
Submitter	: Cijoml Cijomlovic Cijomlov <cijoml-VIXq6x/3rUk@public.gmane.org>
Date		: 2010-02-03 20:34 (5 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15206
Subject		: uvcvideo fails to work since 2.6.32
Submitter	: Rich Ercolani <rercola-YxllIAoeIHiVc3sceRu5cw@public.gmane.org>
Date		: 2010-02-01 12:51 (7 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15205
Subject		: blank screen with KMS if lid is closed before kernel boots
Submitter	: Sven Joachim <svenjoac-Mmb7MZpHnFY@public.gmane.org>
Date		: 2010-02-01 09:08 (7 days old)
=46irst-Bad-Commit: http://git.kernel.org/git/linus/b42d4c5c6a872815d71=
1e5d51a600f5122c38eee


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15193
Subject		: kswapd continuously active
Submitter	: Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>
Date		: 2010-01-22 23 (17 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126420434519039&w=3D=
4
Handled-By	: Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15190
Subject		: second suspend fails and system freezes in hp 6910P laptop
Submitter	: Jithin Emmanuel <jithin1987-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-01-31 15:53 (8 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15188
Subject		: Graphic subsystem freeze
Submitter	: aix27249 <i27249-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-01-31 12:13 (8 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15158
Subject		: oops related to i915_gem_object_save_bit_17_swizzle
Submitter	: Werner Lemberg <wl-mXXj517/zsQ@public.gmane.org>
Date		: 2010-01-28 08:26 (11 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15156
Subject		: 2.6.32.6 hang at boot with ati x1600
Submitter	: Alexey Kuznetsov <ak-b7SOpcJQXxU@public.gmane.org>
Date		: 2010-01-28 05:02 (11 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15100
Subject		: X11 is black after resume from s2ram if my T400 was previous=
 in docking station before
Submitter	: Toralf F=C3=B6rster <toralf.foerster-Mmb7MZpHnFY@public.gmane.org>
Date		: 2010-01-21 08:56 (18 days old)
=46irst-Bad-Commit: http://git.kernel.org/git/linus/c1c7af60892070e4b82=
ad63bbfb95ae745056de0


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15096
Subject		: Resume lock up -- bisected, commit 3a1151e3f124fd1a2c54b8153=
f510f1a7c715369
Submitter	: Rafa=C5=82 Mi=C5=82ecki <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-01-20 23:15 (19 days old)
=46irst-Bad-Commit: http://git.kernel.org/git/linus/3a1151e3f124fd1a2c5=
4b8153f510f1a7c715369


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15042
Subject		: socket(PF_INET6 hangs when ipv6 not yet initialized
Submitter	: Marc Haber <mh+linux-kernel-ciUMMiFYEj8OIzVOb1FTxg@public.gmane.org>
Date		: 2010-01-10 14:28 (29 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126313553029280&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15021
Subject		: agpgart sometimes fails to initialize sometimes
Submitter	: Maciej Piechotka <uzytkownik2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-01-09 23:31 (30 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15015
Subject		: blank screen at random times in laptop when sitting idle
Submitter	: Jithin Emmanuel <jithin1987-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-01-09 16:48 (30 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15004
Subject		: i915: *ERROR* Execbuf while wedged
Submitter	: tomas m <tmezzadra-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-01-07 18:53 (32 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14998
Subject		: Caught 32-bit read from uninitialized memory in acpi_system_=
read_event -- 2.6.31 regression
Submitter	: Christian Casteyde <casteyde.christian-GANU6spQydw@public.gmane.org>
Date		: 2010-01-06 21:40 (33 days old)
=46irst-Bad-Commit: http://git.kernel.org/git/linus/eca6f534e61919b28fb=
21aafbd1c2983deae75be


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14997
Subject		: Closing and re-opening the lid does not reactivate the backl=
ight
Submitter	: o. meijer <meijer.o-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-01-06 15:38 (33 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14939
Subject		: drm: random hang with i915
Submitter	: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Date		: 2009-12-07 17:30 (63 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126020704125723&w=3D=
4
Handled-By	: Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14922
Subject		: 2.6.32 seemed to have broken nVidia MCP7A sata controller
Submitter	: Mike Cui <cuicui-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-12-19 6:13 (51 days old)
References	: http://marc.info/?l=3Dlinux-ide&m=3D126120323407742&w=3D4
Handled-By	: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
		  Robert Hancock <hancockrwd-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14898
Subject		: ksoftirqd problem
Submitter	: Nico <segfault2-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org>
Date		: 2009-12-13 19:05 (57 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126073114325690&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14895
Subject		: BUG in kernel 2.6.32 when using luks encrypted root and RAID=
0..
Submitter	: r4 <mk_4-aRb0bU7PRFPrBKCeMvbIDA@public.gmane.org>
Date		: 2009-12-03 18:24 (67 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125986664904751&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14891
Subject		: Deadlock regression related to NFS root
Submitter	: Stephen R. van den Berg <srb-PCMv+cxZuL0@public.gmane.org>
Date		: 2009-11-24 0:24 (76 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125902279909452&w=3D=
4
Handled-By	: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14868
Subject		: flood of "don't try to register things with the same name in=
 the same directory." on upgrade to 2.6.32
Submitter	: Rich Ercolani <rercola-YxllIAoeIHiVc3sceRu5cw@public.gmane.org>
Date		: 2009-12-24 02:44 (46 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14817
Subject		: When is system under load, then freeze/HD fail
Submitter	: okias <d.okias-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-12-15 11:12 (55 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14782
Subject		: Suspend hangs Lenovo SL300 after gdm login
Submitter	: Gary Trakhman <gary.trakhman-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-12-10 18:53 (60 days old)
=46irst-Bad-Commit: http://git.kernel.org/git/linus/03ba3782e8dcc5b0e1e=
fe440d33084f066e38cae


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14748
Subject		: e1000e NIC not working after reboot
Submitter	: Maciek Sitarz <macieks-yngNwrTfnRnVItvQsEIGlw@public.gmane.org>
Date		: 2009-12-06 13:04 (64 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14695
Subject		: regression in karmic thermal control
Submitter	: Bugie <public-ZA6dAAr5zYM@public.gmane.org>
Date		: 2009-11-26 08:45 (74 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14667
Subject		: bisected 2.6.32 EC regression - Temperatures not correctly d=
etected after suspend
Submitter	: Federico Chiacchiaretta <federico.chia-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-11-22 20:42 (78 days old)
=46irst-Bad-Commit: http://git.kernel.org/git/linus/6a63b06f3c494cc87ea=
de97f081300bda60acec7


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14657
Subject		: perf subsystem breakage in 2.6.32-rc7
Submitter	: Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Date		: 2009-11-19 19:50 (81 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125866013419738&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14656
Subject		: Oops at __rmqueue+0x98 with 2.6.32-rc6
Submitter	: Lucas C. Villa Real <lucasvr-9gmU7qdNRpmhPH1hqNUYSQ@public.gmane.org>
Date		: 2009-11-19 3:48 (81 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125860255229092&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14624
Subject		: ath9k: BUG kmalloc-8192: Poison overwritten
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-11-12 4:58 (88 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125800196520396&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14621
Subject		: specjbb2005 and aim7 regression with 2.6.32-rc kernels
Submitter	: Zhang, Yanmin <yanmin_zhang-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Date		: 2009-11-06 7:38 (94 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125749310413174&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14504
Subject		: intermittent hibernation problem again
Submitter	: Ferenc W=C3=A1gner <wferi-eEbw3PyuezQ@public.gmane.org>
Date		: 2009-10-28 23:49 (103 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14442
Subject		: resume after hibernate: /dev/sdb drops and returns as /dev/s=
de
Submitter	: Duncan <1i5t5.duncan-j9pdmedNgrk@public.gmane.org>
Date		: 2009-10-20 01:52 (111 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14426
Subject		: CE: hpet increasing min_delta_ns flood
Submitter	: Thibault Mondary <thibm-GANU6spQydw@public.gmane.org>
Date		: 2009-10-17 09:29 (114 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14376
Subject		: Kernel NULL pointer dereference/ kvm subsystem
Submitter	: Don Dupuis <dondster-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-06 14:38 (125 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125484025021737&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14298
Subject		: warning at manage.c:361 (set_irq_wake), matrix-keypad relate=
d?
Submitter	: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Date		: 2009-09-30 20:07 (131 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125434130703538&w=3D=
4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14297
Subject		: console resume broken since ba15ab0e8d
Submitter	: Sascha Hauer <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Date		: 2009-09-30 15:11 (131 days old)
=46irst-Bad-Commit: http://git.kernel.org/git/linus/ba15ab0e8de0d4439a9=
1342ad52d55ca9e313f3d
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125432349404060&w=3D=
4


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15134
Subject		: gobi_loader hangs after commit 8e8dce065088
Submitter	: Matthew Garrett <mjg59-1xO5oi07KQx4cg9Nei1l7Q@public.gmane.org>
Date		: 2010-01-17 2:55 (22 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126369696509502&w=3D=
4
Handled-By	: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
		  Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/73878/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15127
Subject		: Bluetooth: sleeping function called from invalid context
Submitter	: David John <davidjon-XRr60H37pjdAfugRpC6u6w@public.gmane.org>
Date		: 2010-01-12 9:19 (27 days old)
=46irst-Bad-Commit: http://git.kernel.org/git/linus/9e726b17422bade75fb=
a94e625cd35fd1353e682
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126328727021949&w=3D=
4
Handled-By	: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/76019/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15108
Subject		: Blank screen with KMS enabled (on clevo M5xN laptop)
Submitter	: J=C3=A9r=C3=A9my Lal <kapouer-QATUhw8NPUbYtjvyW6yDsg@public.gmane.org>
Date		: 2010-01-22 20:30 (17 days old)
Handled-By	: Zhang Rui <rui.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Patch		: http://bugzilla.kernel.org/attachment.cgi?id=3D24740


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15071
Subject		: IBM/Lenovo Trackpoint speed, sensitivity reset after suspend
Submitter	: Marten Vance <kernel-srgEi2D3yJHR7s880joybQ@public.gmane.org>
Date		: 2010-01-16 16:19 (23 days old)
Handled-By	: Dmitry Torokhov <dmitry.torokhov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Patch		: http://bugzilla.kernel.org/attachment.cgi?id=3D24889


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15040
Subject		: High cpu temperature with 2.6.32 - bisected to cpuidle menu =
update
Submitter	: Dimitrios Apostolou <jimis-hi6Y0CQ0nG0@public.gmane.org>
Date		: 2010-01-06 17:39 (33 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126279952723036&w=3D=
4
Handled-By	: Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/71962/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15000
Subject		: Thinkpad dock button no longer works
Submitter	: Paul Martin <pm-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org>
Date		: 2010-01-07 02:11 (32 days old)
Handled-By	: Chris Mason <chris.mason-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/76110/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14894
Subject		: pohmelfs: NULL pointer dereference
Submitter	: Alexander Beregalov <a.beregalov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-12-02 1:11 (68 days old)
References	: http://marc.info/?l=3Dlinux-kernel&m=3D125971633107940&w=3D=
4
Handled-By	: Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>
		  Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/70211/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14886
Subject		: Asus P2B-DS not detected as SMP moterboard
Submitter	: Lorenzo Buzzi <flinco-VGgt2q2+T+FeoWH0uzbU5w@public.gmane.org>
Date		: 2009-12-27 17:20 (43 days old)
=46irst-Bad-Commit: http://git.kernel.org/git/linus/e5b8fc6ac158f65598f=
58dba2c0d52ba3b412f52
Handled-By	: Matthew Garrett <mjg59-1xO5oi07KQx4cg9Nei1l7Q@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/76089/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14742
Subject		: 2.6.32 new menu idle governor causes very high CPU temp
Submitter	:  <akwatts-DaQTI0RpDDMAvxtiuMwx3w@public.gmane.org>
Date		: 2009-12-05 17:24 (65 days old)
Handled-By	: Arjan van de Ven <arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Patch		: http://bugzilla.kernel.org/show_bug.cgi?id=3D14742#c7


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D14487
Subject		: PANIC: early exception 08 rip 246:10 error ffffffff810251b5 =
cr2 0
Submitter	: Justin P. Mattock <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2009-10-23 16:45 (108 days old)
References	: http://lkml.org/lkml/2009/10/23/252
Handled-By	: Jan Beulich <jbeulich-Et1tbQHTxzrQT0dZR+AlfA@public.gmane.org>
Patch		: http://patchwork.kernel.org/patch/68719/


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions introd=
uced
between 2.6.31 and 2.6.32, unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D14230

Please let the tracking teak know if there are any Bugzilla entries tha=
t
should be added to the list in there.

Thanks!
