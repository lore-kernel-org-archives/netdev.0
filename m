From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.36-rc8-git3: Reported regressions from 2.6.35
Date: Sun, 17 Oct 2010 22:15:31 +0200 (CEST)
Message-ID: <TP5BfCZNRXD.A._8.uj1uMB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Florian Mickler <florian-sVu6HhrpSfRAfugRpC6u6w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>
To: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This message contains a list of some regressions from 2.6.35,
for which there are no fixes in the mainline known to the tracking team=
=2E
If any of them have been fixed already, please let us know.

If you know of any other unresolved regressions from 2.6.35, please let=
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
  2010-10-17       70       27          27
  2010-10-10       56       16          15
  2010-10-03       52       16          14
  2010-09-26       46       15          13
  2010-09-20       38       15          15
  2010-09-12       28       14          13
  2010-08-30       21       16          15


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D20472
Subject		: [2.6.35.5 -> .7] INFO: task rpcbind:14163 blocked for more t=
han 120 seconds.
Submitter	: Pawel Sikora <pluto-PIIpFW8S9c0@public.gmane.org>
Date		: 2010-10-15 15:02 (3 days old)
Message-ID	: <201010151702.15675.pluto-PIIpFW8S9c0@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128715683507549&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D20462
Subject		: 2.6.36-rc7-git2 - panic/GPF: e1000e/vlans?
Submitter	: Nikola Ciprich <extmaillist-Jp3n8lUXroTtwjQa/ONI9g@public.gmane.org>
Date		: 2010-10-15 7:10 (3 days old)
Message-ID	: <20101015071008.GA8714-xTMdSLfc3Wpi51D5yjT6kKVXKuFTiq87@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128712984831303&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D20352
Subject		: Fwd: Re: UML kernel crash of v2.6.36-rcX kernel
Submitter	: Toralf F=C3=B6rster <toralf.foerster-Mmb7MZpHnFY@public.gmane.org>
Date		: 2010-10-13 11:28 (5 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/365b18189789bfa1acd9939=
e6312b8a4b4577b28
Message-ID	: <201010131328.06465.toralf.foerster-Mmb7MZpHnFY@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128696930132503&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D20342
Subject		: [LogFS] [2.6.36-rc7] Deadlock in logfs_get_wblocks, hold and=
 wait on same lock super->s_write_mutex
Submitter	: Prasad Joshi <prasadjoshi124-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-10-13 9:49 (5 days old)
Message-ID	: <AANLkTinvsMxTxEbDEFmb5M-6fYjdRvErU=3D=3DZs7+qANkV-Rq2MYuBUFGs@public.gmane.org=
ail.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128696335024718&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D20332
Subject		: [LogFS] [2.6.36-rc7] Kernel BUG at lib/btree.c:465!
Submitter	: Prasad Joshi <prasadjoshi124-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-10-12 18:56 (6 days old)
Message-ID	: <AANLkTimAbCZNhLQ5nADUiAC+7JpAeJBEmjFwdxyZ-FxO-JsoAwUIsXotQFR93xxRIaA@public.gmane.org=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128690910501830&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D20322
Subject		: 2.6.36-rc7: inconsistent lock state: inconsistent {IN-RECLAI=
M_FS-R} -> {RECLAIM_FS-ON-W} usage.
Submitter	: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date		: 2010-10-11 20:10 (7 days old)
Message-ID	: <20101011201007.GA29707-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128682782828453&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D20232
Subject		: kworker consumes ~100% CPU on HP Elitebook 8540w running 2.6=
=2E36_rc6-git4
Submitter	: Ozan Caglayan <ozan-caicS1wCkhO6A22drWdTBw@public.gmane.org>
Date		: 2010-10-13 06:13 (5 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D20182
Subject		: 2.6.36-rc7: NULL pointer dereference in ehci_clear_tt_buffer=
_complete
Submitter	: Stefan Richter <stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>
Date		: 2010-10-11 20:56 (7 days old)
Message-ID	: <tkrat.9f585ea47331a2a2-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128683064431749&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D20172
Subject		: Lenovo S12 2.6.36-rc7 lockup
Submitter	: Chris Vine <chris-TF6qbakwsgc2epGFuHBODCp2UmYkHbXO@public.gmane.org>
Date		: 2010-10-10 12:59 (8 days old)
Message-ID	: <20101010135912.76eb61b7-PlFwYbz7hoIyinQH9hAyzg@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128671620721712&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D20162
Subject		: [LogFS][2.6.36.rc7+] Kernel BUG at readwrite.c:1193
Submitter	: Prasad Joshi <prasadjoshi124-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-10-10 17:44 (8 days old)
Message-ID	: <AANLkTi=3DJkcuWBPo+X-i+9o-BJFVqjea1J3e=3DMr=3DHvAWF@mail.=
gmail.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128673196203340&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D20032
Subject		: 2.6.36-rc7 continuos kernel panics due to of cpu_idle (and c=
pu_intel_idle)
Submitter	: Patrizio Bassi <patrizio.bassi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-10-08 18:23 (10 days old)
Message-ID	: <AANLkTi=3D2irM5tM2rNC5wHVV=3DNw4cs_CK59pvXDD+Y5Dz-Rq2MYuBUFGs@public.gmane.org=
ail.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128656222919323&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D20022
Subject		: "do_IRQ: 0.89 No irq handler for vector (irq -1)"
Submitter	: Dave Airlie <airlied-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-10-07 8:55 (11 days old)
Message-ID	: <AANLkTikZj21CtFwC2ttvc0wJPx2qyedn7b1xXaxH659E-JsoAwUIsXotQFR93xxRIaA@public.gmane.org=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128644173420501&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D19862
Subject		: [REGRESSION] no sound on T60 laptop (HDA Intel)
Submitter	: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Date		: 2010-10-05 9:25 (13 days old)
Message-ID	: <E1P33mT-0003qa-Fv-8f8m9JG5TPIdUIPVzhDTVZP2KDSNp7ea@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128627079921512&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D19802
Subject		: [drm:init_ring_common] *ERROR* render ring head not reset to=
 zero
Submitter	: Thomas Meyer <thomas-VsYtu1Qij5c@public.gmane.org>
Date		: 2010-10-04 20:31 (14 days old)
Message-ID	: <201010042231.20320.thomas-VsYtu1Qij5c@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128622441331199&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D19782
Subject		: 2.6.36-rc6-git2 -- BUG dentry: Poison overwritten (after res=
ume from hibernation)
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-10-03 3:54 (15 days old)
Message-ID	: <AANLkTimrqtzBHAZSuDhEs_3CKA6pCbM35b1BtKH=3DMvC_-JsoAwUIsXov1KXRcyAk9cg@public.gmane.org=
l.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128607809314079&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D19632
Subject		: 2.6.36-rc6: modprobe Not tainted warning
Submitter	: Heinz Diehl <htd-iEI8Y0CNJBYdnm+yROfE0A@public.gmane.org>
Date		: 2010-09-30 18:25 (18 days old)
Message-ID	: <20100930182516.GA15089-iEI8Y0CNJBYdnm+yROfE0A@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128587114004680&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D19392
Subject		: WARNING: at drivers/net/wireless/ath/ath5k/base.c:3475 ath5k=
_bss_info_changed+0x44/0x168 [ath5k]()
Submitter	: Justin Mattock <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-09-28 22:30 (20 days old)
Message-ID	: <AANLkTim5WCGKPvEkOkO_YnMF9pg8mvLfQoFBNUFpfa_k-JsoAwUIsXotQFR93xxRIaA@public.gmane.org=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128571307018635&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D19372
Subject		: 2.6.36-rc6: WARNING: at drivers/gpu/drm/radeon/radeon_fence.=
c:235 radeon_fence_wait+0x35a/0x3c0
Submitter	: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-09-29 21:29 (19 days old)
Message-ID	: <20100929212923.GA5578-y0M6fkzdUYllgR+Ck+lCww@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128579579400315&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D19142
Subject		: Screen flickers when switching from the console to X
Submitter	: Andrey Rahmatullin <wrar-u2l5PoMzF/Vg9hUCZPvPmw@public.gmane.org>
Date		: 2010-09-27 12:05 (21 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D19072
Subject		: [2.6.36-rc regression] occasional complete system hangs on s=
parc64 SMP
Submitter	: Mikael Pettersson <mikpe-1zs4UD6AkMk@public.gmane.org>
Date		: 2010-09-23 17:02 (25 days old)
Message-ID	: <<19611.34846.813757.309183-tgku4HJDRZih8lFjZTKsyTAV6s6igYVG@public.gmane.org>>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128526136531048&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D19052
Subject		: 2.6.36-rc5-git1 -- [drm:i915_report_and_clear_eir] *ERROR* E=
IR stuck: 0x00000010, masking
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-09-22 23:47 (26 days old)
Message-ID	: <AANLkTikWQjUQjFJU9MO1+XbSLAEE-GARz+S+Dz2Fgu4h-JsoAwUIsXotQFR93xxRIaA@public.gmane.org=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128519926626322&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D19002
Subject		: Radeon rv730 AGP/KMS/DRM kernel lockup
Submitter	: Duncan <1i5t5.duncan-j9pdmedNgrk@public.gmane.org>
Date		: 2010-09-23 16:48 (25 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D17361
Subject		: Random kmemcheck errors and kernel freeze on 2.6.36-rc*
Submitter	: Christian Casteyde <casteyde.christian-GANU6spQydw@public.gmane.org>
Date		: 2010-08-29 19:59 (50 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D17121
Subject		: Two blank rectangles more than 10 cm long when booting
Submitter	: Eric Valette <eric.valette-GANU6spQydw@public.gmane.org>
Date		: 2010-08-26 17:24 (53 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D17061
Subject		: 2.6.36-rc1 on zaurus: bluetooth regression
Submitter	: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Date		: 2010-08-21 15:24 (58 days old)
Message-ID	: <20100821152445.GA1536-+ZI9xUNit7I@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128240433828087&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16971
Subject		: qla4xxx compile failure on 32-bit PowerPC: missing readq and=
 writeq
Submitter	: Meelis Roos <mroos-Y27EyoLml9s@public.gmane.org>
Date		: 2010-08-19 21:03 (60 days old)
Message-ID	: <<alpine.SOC.1.00.1008192359310.19654-ptEonEWSGqKptlylMvRsHA@public.gmane.org>>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128225184900892&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16951
Subject		: hackbench regression with 2.6.36-rc1
Submitter	: Zhang, Yanmin <yanmin_zhang-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Date		: 2010-08-18 6:18 (61 days old)
Message-ID	: <1282112318.21202.8.camel-sz7BYL/Y5Hu/P+R7jlPCFVaTQe2KTcn/@public.gmane.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128211235904910&w=3D=
2


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions from 2=
=2E6.35,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D16444

Please let the tracking team know if there are any Bugzilla entries tha=
t
should be added to the list in there.

Thanks!
