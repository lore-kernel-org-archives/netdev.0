From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.37-rc2-git4: Reported regressions 2.6.35 -> 2.6.36
Date: Fri, 19 Nov 2010 00:50:56 +0100 (CET)
Message-ID: <tTUH_XeInOH.A.dMF.c3b5MB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maciej Rutecki <maciej.rutecki@gmail.com>,
	Florian Mickler <florian@mickler.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.freedesktop.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This message contains a list of some post-2.6.35 regressions introduced=
 before
2.6.36, for which there are no fixes in the mainline known to the track=
ing team.
If any of them have been fixed already, please let us know.

If you know of any other unresolved post-2.6.35 regressions, please let=
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
  2010-11-19       92       38          34
  2010-10-17       70       27          27
  2010-10-10       56       16          15
  2010-10-03       52       16          14
  2010-09-26       46       15          13
  2010-09-20       38       15          15
  2010-09-12       28       14          13
  2010-08-30       21       16          15


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D23212
Subject		: multifunction card reader of acer aspire one stopped working
Submitter	: Thibault Mondary <thibm@free.fr>
Date		: 2010-11-18 14:03 (1 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D23132
Subject		: without "pci=3Dnocrs", Dell Inspiron 1545 hangs
Submitter	: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date		: 2010-11-17 19:18 (2 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D23062
Subject		: kvm segfaults on 2.6.36-64bit kernel with 32 bit userspace
Submitter	: Jorge Boncompte <jorge@dti2.net>
Date		: 2010-11-17 11:59 (2 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/9581d442b905


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D22842
Subject		: iwl3945 suddenly stops working
Submitter	: Felipe Contreras <felipe.contreras@gmail.com>
Date		: 2010-11-14 11:14 (5 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D22782
Subject		: 2.6.36: general protection fault during lockfs lockspace rem=
oval
Submitter	: nik@linuxbox.cz <nik@linuxbox.cz>
Date		: 2010-11-12 12:05 (7 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D22732
Subject		: 2.6.37-rc1: hibernation breaks swap
Submitter	: Zhang Rui <rui.zhang@intel.com>
Date		: 2010-11-11 08:38 (8 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D22272
Subject		: High [extra timer interrupt] count in powertop since 2.6.36
Submitter	: Ian Kumlien <pomac@demius.net>
Date		: 2010-10-30 23:52 (20 days old)
Message-ID	: <alpine.LNX.2.00.1010310148450.24290@twilight.pomac.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128848330304431&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D22172
Subject		: alsa-util.c: snd_pcm_avail_delay() returned strange values: =
delay 0 is less than avail 32
Submitter	: Tobias <devnull@plzk.org>
Date		: 2010-11-06 09:33 (13 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D22092
Subject		: Kernel v2.6.36 trouble on USB disconnect
Submitter	: Ketil Froyn <ketil@froyn.name>
Date		: 2010-10-29 8:05 (21 days old)
Message-ID	: <AANLkTik5qVxkEGVAA1PSOGk2KTW+ekHpSwttsQEWzWj+@mail.gmail.=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128833956503607&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D21932
Subject		: Regression in 2.6.36 in single stepping over hardware breakp=
oint (Wine)
Submitter	: Michael Stefaniuc <mstefani@redhat.com>
Date		: 2010-10-28 0:12 (22 days old)
Message-ID	: <4CC8BFDD.8080600@redhat.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128822477714448&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D21662
Subject		: 2.6.35->2.6.36 regression, vanilla kernel panic, ppp or hrti=
mers crashing
Submitter	: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Date		: 2010-10-25 9:22 (25 days old)
Message-ID	: <201010251222.37191.nuclearcat@nuclearcat.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128799855826011&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D21652
Subject		: several problems with intel graphics since 2.6.36
Submitter	: Norbert Preining <preining@logic.at>
Date		: 2010-10-27 14:32 (23 days old)
Message-ID	: <20101027143252.GA8676@gamma.logic.tuwien.ac.at>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128818998630241&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D21402
Subject		: [KVM] Noacpi Windows guest can not boot up on 32bit KVM host
Submitter	: xudong <xudong.hao@intel.com>
Date		: 2010-10-29 03:01 (21 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D21372
Subject		: NULL pointer deference at disk_replace_part_tbl+0x32
Submitter	: Luis R. Rodriguez <mcgrof@gmail.com>
Date		: 2010-10-28 17:22 (22 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D21332
Subject		: Regression in single stepping over hardware breakpoint (Wine=
)
Submitter	: Michael Stefaniuc <mstefani@redhat.com>
Date		: 2010-10-27 23:41 (23 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/0c4519e825c9e2b6a8310de=
ff8582f8c35bfbba9


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D20462
Subject		: 2.6.36-rc7-git2 - panic/GPF: e1000e/vlans?
Submitter	: Nikola Ciprich <extmaillist@linuxbox.cz>
Date		: 2010-10-15 7:10 (35 days old)
Message-ID	: <20101015071008.GA8714@pcnci.linuxbox.cz>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128712984831303&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D20352
Subject		: Fwd: Re: UML kernel crash of v2.6.36-rcX kernel
Submitter	: Toralf F=C3=B6rster <toralf.foerster@gmx.de>
Date		: 2010-10-13 11:28 (37 days old)
=46irst-Bad-Commit: http://git.kernel.org/linus/365b18189789bfa1acd9939=
e6312b8a4b4577b28
Message-ID	: <201010131328.06465.toralf.foerster@gmx.de>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128696930132503&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D20342
Subject		: [LogFS] [2.6.36-rc7] Deadlock in logfs_get_wblocks, hold and=
 wait on same lock super->s_write_mutex
Submitter	: Prasad Joshi <prasadjoshi124@gmail.com>
Date		: 2010-10-13 9:49 (37 days old)
Message-ID	: <AANLkTinvsMxTxEbDEFmb5M-6fYjdRvErU=3D=3DZs7+qANkV@mail.gm=
ail.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128696335024718&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D20332
Subject		: [LogFS] [2.6.36-rc7] Kernel BUG at lib/btree.c:465!
Submitter	: Prasad Joshi <prasadjoshi124@gmail.com>
Date		: 2010-10-12 18:56 (38 days old)
Message-ID	: <AANLkTimAbCZNhLQ5nADUiAC+7JpAeJBEmjFwdxyZ-FxO@mail.gmail.=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128690910501830&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D20322
Subject		: 2.6.36-rc7: inconsistent lock state: inconsistent {IN-RECLAI=
M_FS-R} -> {RECLAIM_FS-ON-W} usage.
Submitter	: Dave Jones <davej@redhat.com>
Date		: 2010-10-11 20:10 (39 days old)
Message-ID	: <20101011201007.GA29707@redhat.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128682782828453&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D20232
Subject		: kworker consumes ~100% CPU on HP Elitebook 8540w running 2.6=
=2E36_rc6-git4
Submitter	: Ozan Caglayan <ozan@pardus.org.tr>
Date		: 2010-10-13 06:13 (37 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D20172
Subject		: 2.6.36-rc7 boot stalls unless nolapic_timer - Lenovo S12
Submitter	: Chris Vine <chris@cvine.freeserve.co.uk>
Date		: 2010-10-10 12:59 (40 days old)
Message-ID	: <<20101010135912.76eb61b7@boulder.homenet>>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128671620721712&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D19802
Subject		: [drm:init_ring_common] *ERROR* render ring head not reset to=
 zero
Submitter	: Thomas Meyer <thomas@m3y3r.de>
Date		: 2010-10-04 20:31 (46 days old)
Message-ID	: <201010042231.20320.thomas@m3y3r.de>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128622441331199&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D19782
Subject		: 2.6.36-rc6-git2 -- BUG dentry: Poison overwritten (after res=
ume from hibernation)
Submitter	: Miles Lane <miles.lane@gmail.com>
Date		: 2010-10-03 3:54 (47 days old)
Message-ID	: <AANLkTimrqtzBHAZSuDhEs_3CKA6pCbM35b1BtKH=3DMvC_@mail.gmai=
l.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128607809314079&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D19632
Subject		: 2.6.36-rc6: modprobe Not tainted warning
Submitter	: Heinz Diehl <htd@fritha.org>
Date		: 2010-09-30 18:25 (50 days old)
Message-ID	: <20100930182516.GA15089@fritha.org>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128587114004680&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D19392
Subject		: WARNING: at drivers/net/wireless/ath/ath5k/base.c:3475 ath5k=
_bss_info_changed+0x44/0x168 [ath5k]()
Submitter	: Justin Mattock <justinmattock@gmail.com>
Date		: 2010-09-28 22:30 (52 days old)
Message-ID	: <AANLkTim5WCGKPvEkOkO_YnMF9pg8mvLfQoFBNUFpfa_k@mail.gmail.=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128571307018635&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D19372
Subject		: 2.6.36-rc6: WARNING: at drivers/gpu/drm/radeon/radeon_fence.=
c:235 radeon_fence_wait+0x35a/0x3c0
Submitter	: Alexey Dobriyan <adobriyan@gmail.com>
Date		: 2010-09-29 21:29 (51 days old)
Message-ID	: <20100929212923.GA5578@core2.telecom.by>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128579579400315&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D19142
Subject		: Screen flickers when switching from the console to X
Submitter	: Andrey Rahmatullin <wrar@altlinux.org>
Date		: 2010-09-27 12:05 (53 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D19052
Subject		: 2.6.36-rc5-git1 -- [drm:i915_report_and_clear_eir] *ERROR* E=
IR stuck: 0x00000010, masking
Submitter	: Miles Lane <miles.lane@gmail.com>
Date		: 2010-09-22 23:47 (58 days old)
Message-ID	: <AANLkTikWQjUQjFJU9MO1+XbSLAEE-GARz+S+Dz2Fgu4h@mail.gmail.=
com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128519926626322&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D19002
Subject		: Radeon rv730 AGP/KMS/DRM kernel lockup
Submitter	: Duncan <1i5t5.duncan@cox.net>
Date		: 2010-09-23 16:48 (57 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D17121
Subject		: Two blank rectangles more than 10 cm long when booting
Submitter	: Eric Valette <eric.valette@free.fr>
Date		: 2010-08-26 17:24 (85 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D17061
Subject		: 2.6.36-rc1 on zaurus: bluetooth regression
Submitter	: Pavel Machek <pavel@ucw.cz>
Date		: 2010-08-21 15:24 (90 days old)
Message-ID	: <20100821152445.GA1536@ucw.cz>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128240433828087&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16971
Subject		: qla4xxx compile failure on 32-bit PowerPC: missing readq and=
 writeq
Submitter	: Meelis Roos <mroos@linux.ee>
Date		: 2010-08-19 21:03 (92 days old)
Message-ID	: <<alpine.SOC.1.00.1008192359310.19654@math.ut.ee>>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128225184900892&w=3D=
2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D16951
Subject		: hackbench regression with 2.6.36-rc1
Submitter	: Zhang, Yanmin <yanmin_zhang@linux.intel.com>
Date		: 2010-08-18 6:18 (93 days old)
Message-ID	: <1282112318.21202.8.camel@ymzhang.sh.intel.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128211235904910&w=3D=
2


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D22452
Subject		: data corruption after mmap()ing a file and writev() some dat=
a to another file
Submitter	: Marius Tolzmann <tolzmann@molgen.mpg.de>
Date		: 2010-11-08 10:33 (11 days old)
Patch		: http://www.spinics.net/lists/xfs/msg02126.html


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D21092
Subject		: Kernel 2.6.36 Bug during quotaon on reiserfs
Submitter	:  <markus.gapp@gmx.net>
Date		: 2010-10-24 16:57 (26 days old)
Handled-By	: Jan Kara <jack@suse.cz>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=3D35292


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D20182
Subject		: 2.6.36-rc7: NULL pointer dereference in ehci_clear_tt_buffer=
_complete
Submitter	: Stefan Richter <stefanr@s5r6.in-berlin.de>
Date		: 2010-10-11 20:56 (39 days old)
Message-ID	: <tkrat.9f585ea47331a2a2@s5r6.in-berlin.de>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128683064431749&w=3D=
2
Handled-By	: Alan Stern <stern@rowland.harvard.edu>
Patch		: https://patchwork.kernel.org/patch/250761/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=3D20162
Subject		: [LogFS][2.6.36.rc7+] Kernel BUG at readwrite.c:1193
Submitter	: Prasad Joshi <prasadjoshi124@gmail.com>
Date		: 2010-10-10 17:44 (40 days old)
Message-ID	: <AANLkTi=3DJkcuWBPo+X-i+9o-BJFVqjea1J3e=3DMr=3DHvAWF@mail.=
gmail.com>
References	: http://marc.info/?l=3Dlinux-kernel&m=3D128673196203340&w=3D=
2
Handled-By	:  Prasad Gajanan Joshi <prasadjoshi124@gmail.com>
Patch		: https://bugzilla.kernel.org/show_bug.cgi?id=3D20162#c1


=46or details, please visit the bug entries and follow the links given =
in
references.

As you can see, there is a Bugzilla entry for each of the listed regres=
sions.
There also is a Bugzilla entry used for tracking the regressions introd=
uced
between 2.6.35 and 2.6.36, unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D16444

Please let the tracking team know if there are any Bugzilla entries tha=
t
should be added to the list in there.

Thanks!

--
To unsubscribe from this list: send the line "unsubscribe linux-acpi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
