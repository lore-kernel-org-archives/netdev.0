From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.37-rc6-git4: Reported regressions 2.6.35 -> 2.6.36
Date: Sun, 19 Dec 2010 13:41:20 +0100 (CET)
Message-ID: <ZRNlsjykcOD.A.b-F.20fDNB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
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

This message contains a list of some post-2.6.35 regressions introduced before
2.6.36, for which there are no fixes in the mainline known to the tracking team.
If any of them have been fixed already, please let us know.

If you know of any other unresolved post-2.6.35 regressions, please let us know
either and we'll add them to the list.  Also, please let us know if any
of the entries below are invalid.

Each entry from the list will be sent additionally in an automatic reply to
this message with CCs to the people involved in reporting and handling the
issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2010-12-19       98       28          23
  2010-12-05       95       34          31
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

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=24752
Subject		: Random crashes easily reproducible with make -j5 - intel i915 - kernel 2.6.36 on intel/nvidia hybrid graphics machine
Submitter	: Giacomo <delleceste-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-12-10 8:57 (10 days old)
Message-ID	: <AANLkTimkQM94u9iz7FVVjehB0mwDwfkNwKhF2F2tYq-r-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=129197146619176&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=24392
Subject		: AGP aperture disabled, worked in 2.6.35
Submitter	: Stephen Kitt <steve-HEvo97dlh4E@public.gmane.org>
Date		: 2010-12-06 06:31 (14 days old)
First-Bad-Commit: http://git.kernel.org/linus/96576a9e1a0cdb8a43d3af5846be0948f52b4460


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=24202
Subject		: [830] drm:intel_prepare_page_flip, *ERROR* Prepared flip multiple times
Submitter	: mkkot <marcin2006-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-12-02 14:10 (18 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=24022
Subject		: wireless no longer works after 1st update of 10.10 [rtl819xE:ERR in init_firmware()]
Submitter	: njin <marconifabio-osBHMS06NAwBXFe83j6qeQ@public.gmane.org>
Date		: 2010-11-29 19:49 (21 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=23812
Subject		: HAL does not provide battery information on RHEL5 and CentOS-5
Submitter	: Dag Wieers <dag-TpjQRECdbeTQT0dZR+AlfA@public.gmane.org>
Date		: 2010-11-26 18:08 (24 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=23302
Subject		: alsa stops working after one or more hibernate or suspend cycles
Submitter	: Werner Lemberg <wl-mXXj517/zsQ@public.gmane.org>
Date		: 2010-11-19 16:21 (31 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=22842
Subject		: iwl3945 suddenly stops working
Submitter	: Felipe Contreras <felipe.contreras-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-11-14 11:14 (36 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=22782
Subject		: 2.6.36: general protection fault during lockfs lockspace removal
Submitter	: nik-Jp3n8lUXroTtwjQa/ONI9g@public.gmane.org <nik-Jp3n8lUXroTtwjQa/ONI9g@public.gmane.org>
Date		: 2010-11-12 12:05 (38 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=22172
Subject		: alsa-util.c: snd_pcm_avail_delay() returned strange values: delay 0 is less than avail 32
Submitter	: Tobias <devnull-fBT1nhYaLZ4@public.gmane.org>
Date		: 2010-11-06 09:33 (44 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=22092
Subject		: Kernel v2.6.36 trouble on USB disconnect
Submitter	: Ketil Froyn <ketil-wcohQK4BhvFBDLzU/O5InQ@public.gmane.org>
Date		: 2010-10-29 8:05 (52 days old)
Message-ID	: <AANLkTik5qVxkEGVAA1PSOGk2KTW+ekHpSwttsQEWzWj+-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128833956503607&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=21662
Subject		: 2.6.35->2.6.36 regression, vanilla kernel panic, ppp or hrtimers crashing
Submitter	: Denys Fedoryshchenko <nuclearcat-03OYUmBsc8OBik42HM7KXg@public.gmane.org>
Date		: 2010-10-25 9:22 (56 days old)
Message-ID	: <201010251222.37191.nuclearcat-03OYUmBsc8OBik42HM7KXg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128799855826011&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=21652
Subject		: several problems with intel graphics since 2.6.36
Submitter	: Norbert Preining <preining-DX+603jRYB8@public.gmane.org>
Date		: 2010-10-27 14:32 (54 days old)
Message-ID	: <20101027143252.GA8676-DqSSrKF0TaySnEC3TeqHn5dqbFPxfnh/@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128818998630241&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=21402
Subject		: [KVM] Noacpi Windows guest can not boot up on 32bit KVM host
Submitter	: xudong <xudong.hao-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date		: 2010-10-29 03:01 (52 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=20332
Subject		: [LogFS] [2.6.36-rc7] Kernel BUG at lib/btree.c:465!
Submitter	: Prasad Joshi <prasadjoshi124-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-10-12 18:56 (69 days old)
Message-ID	: <AANLkTimAbCZNhLQ5nADUiAC+7JpAeJBEmjFwdxyZ-FxO-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128690910501830&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=20322
Subject		: 2.6.36-rc7: inconsistent lock state: inconsistent {IN-RECLAIM_FS-R} -> {RECLAIM_FS-ON-W} usage.
Submitter	: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date		: 2010-10-11 20:10 (70 days old)
Message-ID	: <20101011201007.GA29707-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128682782828453&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=20232
Subject		: kworker consumes ~100% CPU on HP Elitebook 8540w running 2.6.36_rc6-git4
Submitter	: Ozan Caglayan <ozan-caicS1wCkhO6A22drWdTBw@public.gmane.org>
Date		: 2010-10-13 06:13 (68 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=19632
Subject		: 2.6.36-rc6: modprobe Not tainted warning
Submitter	: Heinz Diehl <htd-iEI8Y0CNJBYdnm+yROfE0A@public.gmane.org>
Date		: 2010-09-30 18:25 (81 days old)
Message-ID	: <20100930182516.GA15089-iEI8Y0CNJBYdnm+yROfE0A@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128587114004680&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=19392
Subject		: WARNING: at drivers/net/wireless/ath/ath5k/base.c:3475 ath5k_bss_info_changed+0x44/0x168 [ath5k]()
Submitter	: Justin Mattock <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-09-28 22:30 (83 days old)
Message-ID	: <<AANLkTim5WCGKPvEkOkO_YnMF9pg8mvLfQoFBNUFpfa_k-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>>
References	: http://marc.info/?l=linux-kernel&m=128571307018635&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=19372
Subject		: 2.6.36-rc6: WARNING: at drivers/gpu/drm/radeon/radeon_fence.c:235 radeon_fence_wait+0x35a/0x3c0
Submitter	: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-09-29 21:29 (82 days old)
Message-ID	: <20100929212923.GA5578-y0M6fkzdUYllgR+Ck+lCww@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128579579400315&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=19052
Subject		: 2.6.36-rc5-git1 -- [drm:i915_report_and_clear_eir] *ERROR* EIR stuck: 0x00000010, masking
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-09-22 23:47 (89 days old)
Message-ID	: <AANLkTikWQjUQjFJU9MO1+XbSLAEE-GARz+S+Dz2Fgu4h-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128519926626322&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17121
Subject		: Two blank rectangles more than 10 cm long when booting
Submitter	: Eric Valette <eric.valette-GANU6spQydw@public.gmane.org>
Date		: 2010-08-26 17:24 (116 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17061
Subject		: 2.6.36-rc1 on zaurus: bluetooth regression
Submitter	: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Date		: 2010-08-21 15:24 (121 days old)
Message-ID	: <20100821152445.GA1536-+ZI9xUNit7I@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128240433828087&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16951
Subject		: hackbench regression with 2.6.36-rc1
Submitter	: Zhang, Yanmin <yanmin_zhang-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Date		: 2010-08-18 6:18 (124 days old)
Message-ID	: <1282112318.21202.8.camel-sz7BYL/Y5Hu/P+R7jlPCFVaTQe2KTcn/@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128211235904910&w=2


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=21092
Subject		: Kernel 2.6.36 Bug during quotaon on reiserfs
Submitter	:  <markus.gapp-hi6Y0CQ0nG0@public.gmane.org>
Date		: 2010-10-24 16:57 (57 days old)
Handled-By	: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=35292


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=20462
Subject		: 2.6.36-rc7-git2 - panic/GPF: e1000e/vlans?
Submitter	: Nikola Ciprich <extmaillist-Jp3n8lUXroTtwjQa/ONI9g@public.gmane.org>
Date		: 2010-10-15 7:10 (66 days old)
Message-ID	: <20101015071008.GA8714-xTMdSLfc3Wpi51D5yjT6kKVXKuFTiq87@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128712984831303&w=2
Handled-By	: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Patch		: http://www.spinics.net/lists/netdev/msg146227.html


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=20342
Subject		: [LogFS] [2.6.36-rc7] Deadlock in logfs_get_wblocks, hold and wait on same lock super->s_write_mutex
Submitter	: Prasad Joshi <prasadjoshi124-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-10-13 9:49 (68 days old)
Message-ID	: <AANLkTinvsMxTxEbDEFmb5M-6fYjdRvErU==Zs7+qANkV-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128696335024718&w=2
Patch		: https://patchwork.kernel.org/patch/328682/


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=20162
Subject		: [LogFS][2.6.36.rc7+] Kernel BUG at readwrite.c:1193
Submitter	: Prasad Joshi <prasadjoshi124-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-10-10 17:44 (71 days old)
Message-ID	: <AANLkTi=JkcuWBPo+X-i+9o-BJFVqjea1J3e=Mr=HvAWF-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128673196203340&w=2
Handled-By	:  Prasad Gajanan Joshi <prasadjoshi124-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Patch		: https://bugzilla.kernel.org/show_bug.cgi?id=20162#c1


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16971
Subject		: qla4xxx compile failure on 32-bit PowerPC: missing readq and writeq
Submitter	: Meelis Roos <mroos-Y27EyoLml9s@public.gmane.org>
Date		: 2010-08-19 21:03 (123 days old)
Message-ID	: <<<alpine.SOC.1.00.1008192359310.19654-ptEonEWSGqKptlylMvRsHA@public.gmane.org>>>
References	: http://marc.info/?l=linux-kernel&m=128225184900892&w=2
Patch		: http://marc.info/?l=linux-scsi&m=128590267608876&w=2


For details, please visit the bug entries and follow the links given in
references.

As you can see, there is a Bugzilla entry for each of the listed regressions.
There also is a Bugzilla entry used for tracking the regressions introduced
between 2.6.35 and 2.6.36, unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=16444

Please let the tracking team know if there are any Bugzilla entries that
should be added to the list in there.

Thanks!
