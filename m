From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.34-rc5: Reported regressions from 2.6.33
Date: Tue, 20 Apr 2010 05:15:57 +0200 (CEST)
Message-ID: <deuQKFRcc0B.A.3EG.BRSzLB@tosh>
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

This message contains a list of some regressions from 2.6.33,
for which there are no fixes in the mainline known to the tracking team=
=2E
If any of them have been fixed already, please let us know.

If you know of any other unresolved regressions from 2.6.33, please let=
 us
know either and we'll add them to the list.  Also, please let us know
if any of the entries below are invalid.

Each entry from the list will be sent additionally in an automatic repl=
y
to this message with CCs to the people involved in reporting and handli=
ng
the issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2010-04-20       64       35          34
  2010-04-07       48       35          33
  2010-03-21       15       13          10


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15812
Subject		: utsname.domainname not set in x86_32 processes (causing "YPB=
INDPROC_DOMAIN: domain not bound" errors)
Submitter	:  <adi-3HqRAUrWAWyGglJvpFV4uA@public.gmane.org>
Date		: 2010-04-19 21:28 (1 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15805
Subject		: reiserfs locking
Submitter	: Alexander Beregalov <a.beregalov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-04-15 21:02 (5 days old)
Message-ID	: <t2ka4423d671004151402n7b2dc425mdc9c6bb9640d63fb-JsoAwUIsXov1KXRcyAk9cg@public.gmane.org=
l.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127136535323933&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15796
Subject		: [REGRESSION bisected] Sound goes too fast due to commit 7b3a=
177b0
Submitter	: =C3=89ric Piel <Eric.Piel-VkQ1JFuSMpfAbQlEx87xDw@public.gmane.org>
Date		: 2010-04-13 21:54 (7 days old)
=46irst-Bad-Commit: http://kernel.org/git/linus/7b3a177b0d4f92b3431b8dc=
a777313a07533a710
Message-ID	: <4BC4E812.6050602-VkQ1JFuSMpfAbQlEx87xDw@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127119569009790&w=3D=
2
Handled-By	: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15795
Subject		: 2.6.34-rc4 : OOPS in unmap_vma
Submitter	: Parag Warudkar <parag.lkml-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-04-14 (6 days old)
Message-ID	: <alpine.DEB.2.00.1004132147260.1881@parag-laptop>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127121006625429&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15790
Subject		: Meta-Bug: Regressions
Submitter	: Florian Mickler <fmickler-Mmb7MZpHnFY@public.gmane.org>
Date		: 2010-04-15 18:21 (5 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15788
Subject		: external usb sound card doesn't work after resume
Submitter	: Fran=C3=A7ois Valenduc <francois.valenduc-bmtTS95sd5BUM80lpFwj4w@public.gmane.org>
Date		: 2010-04-15 10:16 (5 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15774
Subject		: 2.6.34-rc3: eth0 (8139too): transmit queue 0 timed out
Submitter	: N=C3=A9meth M=C3=A1rton <nm127-Y8qEzhMunLyT9ig0jae3mg@public.gmane.org>
Date		: 2010-04-10 12:33 (10 days old)
Message-ID	: <4BC07022.6000708-Y8qEzhMunLyT9ig0jae3mg@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127090287021976&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15768
Subject		: Incorrectly calculated free blocks result in ENOSPC from wri=
tepage
Submitter	: Dmitry Monakhov <dmonakhov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Date		: 2010-04-12 11:24 (8 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15744
Subject		: [2.6.34-rc1 REGRESSION] ahci 0000:00:1f.2: controller reset =
failed (0xffffffff)
Submitter	: Andy Isaacson <adi-3HqRAUrWAWyGglJvpFV4uA@public.gmane.org>
Date		: 2010-04-06 22:54 (14 days old)
Message-ID	: <<4BC51312.6080302-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org></desc>>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127059449031511&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15730
Subject		: Ugly rmap NULL ptr deref oopsie on hibernate (was Linux 2.6.=
34-rc3)
Submitter	: Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>
Date		: 2010-04-02 17:59 (18 days old)
Message-ID	: <20100402175937.GA19690-f9CnO7I+Q6zU6FkGJEIX5A@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127023173329741&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15729
Subject		: BUG: physmap modprobe & rmmod
Submitter	: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Date		: 2010-04-02 20:40 (18 days old)
Message-ID	: <20100402134058.c4682716.randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127024096210230&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15719
Subject		: virtio_net causing kernel BUG when running under VirtualBox
Submitter	: Thomas M=C3=BCller <thomas-5bHTHlrcoh6zQB+pC5nmwQ@public.gmane.org>
Date		: 2010-03-27 14:32 (24 days old)
=46irst-Bad-Commit: http://kernel.org/git/linus/9ab86bbcf8be755256f0a5e=
994e0b38af6b4d399
Message-ID	: <4BAE1707.2050803-5bHTHlrcoh6zQB+pC5nmwQ@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126970039227740&w=3D=
4
Handled-By	: Shirley Ma <mashirle-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15717
Subject		: bluetooth oops
Submitter	: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Date		: 2010-03-14 20:14 (37 days old)
Message-ID	: <20100314201434.GE22059-I/5MKhXcvmPrBKCeMvbIDA@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126859771528426&w=3D=
4
Handled-By	: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15713
Subject		: hackbench regression due to commit 9dfc6e68bfe6e
Submitter	: Alex Shi <alex.shi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date		: 2010-03-25 8:40 (26 days old)
=46irst-Bad-Commit: http://kernel.org/git/linus/9dfc6e68bfe6ee452efb1a4=
e9ca26a9007f2b864
Message-ID	: <1269506457.4513.141.camel-c8rhgrCDLIED0+JXs3kMbRL4W9x8LtSr@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126950632920682&w=3D=
4
Handled-By	: Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
		  Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15712
Subject		: [regression] 2.6.34-rc1 to -rc3 on zaurus: no longer boots
Submitter	: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Date		: 2010-04-01 6:06 (19 days old)
Message-ID	: <20100401060624.GA1329-+ZI9xUNit7I@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127010200817402&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15711
Subject		: 2.6.34-rc3, BUG at mm/slab.c:2989
Submitter	: Heinz Diehl <htd-HjJ2MNWy62to6+H+lsi3Gti2O/JbrIOy@public.gmane.org>
Date		: 2010-04-01 17:52 (19 days old)
Message-ID	: <20100401175225.GA6581-HjJ2MNWy62to6+H+lsi3Gti2O/JbrIOy@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127014437406250&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15704
Subject		: [r8169] WARNING: at net/sched/sch_generic.c
Submitter	: Sergey Senozhatsky <sergey.senozhatsky-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-03-31 10:21 (20 days old)
Message-ID	: <<20100331102142.GA3294-dY8u8AhHFaWtd10JCjopabkcH5ONE+aC@public.gmane.org>>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D127003090406108&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15698
Subject		: Freeze on power-off / suspend to ram
Submitter	: arond <hector1987-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-04-05 13:53 (15 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15673
Subject		: 2.6.34-rc2: "ima_dec_counts: open/free imbalance"?
Submitter	: Thomas Meyer <thomas-VsYtu1Qij5c@public.gmane.org>
Date		: 2010-03-28 11:31 (23 days old)
Message-ID	: <1269775909.5301.4.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126977593326800&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15672
Subject		: KVM bug, git bisected
Submitter	: Kent Overstreet <kent.overstreet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-03-27 12:43 (24 days old)
=46irst-Bad-Commit: http://kernel.org/git/linus/5beb49305251e5669852ed5=
41e8e2f2f7696c53e
Message-ID	: <4BADFD74.8060904-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126969385121711&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15671
Subject		: intel graphic card hanging (Hangcheck timer elapsed... GPU h=
ung)
Submitter	: Norbert Preining <preining-DX+603jRYB8@public.gmane.org>
Date		: 2010-03-27 16:11 (24 days old)
Message-ID	: <20100327161104.GA12043-DqSSrKF0TaySnEC3TeqHn5dqbFPxfnh/@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126970883105262&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15669
Subject		: INFO: suspicious rcu_dereference_check()
Submitter	: Zdenek Kabelac <zdenek.kabelac-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-03-08 1:26 (43 days old)
Message-ID	: <c4e36d111003250348q678eb2e6w4f3e8133e7fd6e58-JsoAwUIsXounXO2b/Sh1tA@public.gmane.org=
om>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126801163107713&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15668
Subject		: start_kernel(): bug: interrupts were enabled early
Submitter	: Rabin Vincent <rabin-66gdRtMMWGc@public.gmane.org>
Date		: 2010-03-25 19:53 (26 days old)
=46irst-Bad-Commit: http://kernel.org/git/linus/773e3eb7b81e5ba13b5155d=
fb3bb75b8ce37f8f9
Message-ID	: <20100325194100.GA2364@debian>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126954607216519&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15664
Subject		: Graphics hang and kernel backtrace when starting Azureus wit=
h Compiz enabled
Submitter	: Alex Villacis Lasso <avillaci-x0m+Mc+nT7uljOmnV8AmnkElSqmLX1BE@public.gmane.org>
Date		: 2010-04-01 01:09 (19 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15661
Subject		: PROBLEM: crash on halt with 2.6.34-0.16.rc2.git0.fc14.x86_64
Submitter	: Jon Masters <jonathan-Zp4isUonpHBD60Wz+7aTrA@public.gmane.org>
Date		: 2010-03-26 15:29 (25 days old)
Message-ID	: <<1269617372.3779.234.camel@localhost>>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126961739803949&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15659
Subject		: [Regresion] [2.6.34-rc1] [drm:i915_hangcheck_elapsed] *ERROR=
* Hangcheck timer elapsed... GPU hung
Submitter	: Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-03-25 20:04 (26 days old)
Message-ID	: <201003252104.24965.maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126954749618319&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15625
Subject		: BUG: 2.6.34-rc1, RIP is (null)
Submitter	: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Date		: 2010-03-18 22:22 (33 days old)
Message-ID	: <4BA2A7A9.4080503-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126895098217351&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15611
Subject		: Failure with the 2.6.34-rc1 kernel
Submitter	: Rupjyoti Sarmah <rsarmah-6mNVq6Owofk@public.gmane.org>
Date		: 2010-03-16 15:45 (35 days old)
Message-ID	: <AC311A8E81420D4EBC1F26E6479848FE065B7D3D-oUPhqDSr77q+n3Z1v9ZxkQ@public.gmane.org=
=2Eamcc.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126875435718396&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15610
Subject		: fsck leads to swapper - BUG: unable to handle kernel NULL po=
inter dereference & panic
Submitter	: Ozgur Yuksel <ozgur.yuksel-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Date		: 2010-03-22 15:59 (29 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15601
Subject		: [BUG] SLOB breaks Crypto
Submitter	: michael-dev-1SGGS//iJ+Y38rf8aCqVIw@public.gmane.org
Date		: 2010-03-15 13:39 (36 days old)
Message-ID	: <4B9E38AF.70309-1SGGS//iJ+Y38rf8aCqVIw@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126866044724539&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15590
Subject		: 2.6.34-rc1: regression: ^Z no longer stops sound
Submitter	: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Date		: 2010-03-14 7:58 (37 days old)
Message-ID	: <20100314075831.GA13457-I/5MKhXcvmPrBKCeMvbIDA@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126855353122623&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15589
Subject		: 2.6.34-rc1: Badness at fs/proc/generic.c:316
Submitter	: Christian Kujau <lists-AanptEQQ3TL9uQeqpI+JUg@public.gmane.org>
Date		: 2010-03-13 23:53 (38 days old)
Message-ID	: <alpine.DEB.2.01.1003131544340.5493-uKsf7x9sgtqQ/Pez2Lbyp4QuADTiUCJX@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D126852442903680&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15553
Subject		: Screen backlight doesn't come back on after lid was closed (=
GM45)
Submitter	:  <bugs-fbdoOxCsnNob1SvskN2V4Q@public.gmane.org>
Date		: 2010-03-17 14:35 (34 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15551
Subject		: WARNING: at net/mac80211/work.c:811 ieee80211_work_work+0x7f=
/0xde8 [mac80211]()
Submitter	: Alex Zhavnerchik <alex.vizor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-03-16 22:03 (35 days old)


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D15505
Subject		: No more b43 wireless interface since 2.6.34-rc1
Submitter	: Christian Casteyde <casteyde.christian-GANU6spQydw@public.gmane.org>
Date		: 2010-03-10 06:59 (41 days old)
Handled-By	: Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Patch		: https://bugzilla.kernel.org/show_bug.cgi?id=3D15505#c11


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions from 2=
=2E6.33,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D15310

Please let the tracking team know if there are any Bugzilla entries tha=
t
should be added to the list in there.

Thanks!
