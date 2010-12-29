From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.37-rc8: Reported regressions 2.6.35 -> 2.6.36
Date: Thu, 30 Dec 2010 00:18:40 +0100 (CET)
Message-ID: <odW4v9b6arG.A.2bH.uE8GNB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
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

[NOTE: This most likely is the last summary report of regressions introduced
 between 2.6.35 and 2.6.36.]

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
  2010-12-30       99       22          20
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
Submitter	: Giacomo <delleceste@gmail.com>
Date		: 2010-12-10 8:57 (20 days old)
Message-ID	: <AANLkTimkQM94u9iz7FVVjehB0mwDwfkNwKhF2F2tYq-r@mail.gmail.com>
References	: http://marc.info/?l=linux-kernel&m=129197146619176&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=24722
Subject		: Disconnecting my USB mouse hangs the machine and issues kernel warning
Submitter	: Heinz Diehl <htd@fancy-poultry.org>
Date		: 2010-12-12 12:42 (18 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=24392
Subject		: AGP aperture disabled, worked in 2.6.35
Submitter	: Stephen Kitt <steve@sk2.org>
Date		: 2010-12-06 06:31 (24 days old)
First-Bad-Commit: http://git.kernel.org/linus/http://git.kernel.org/linus/96576a9e1a0cdb8a43d3af5846be0948f52b4460


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=24202
Subject		: [830] drm:intel_prepare_page_flip, *ERROR* Prepared flip multiple times
Submitter	: mkkot <marcin2006@gmail.com>
Date		: 2010-12-02 14:10 (28 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=23812
Subject		: HAL does not provide battery information on RHEL5 and CentOS-5
Submitter	: Dag Wieers <dag@wieers.com>
Date		: 2010-11-26 18:08 (34 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=22842
Subject		: iwl3945 suddenly stops working
Submitter	: Felipe Contreras <felipe.contreras@gmail.com>
Date		: 2010-11-14 11:14 (46 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=22782
Subject		: 2.6.36: general protection fault during lockfs lockspace removal
Submitter	: nik@linuxbox.cz <nik@linuxbox.cz>
Date		: 2010-11-12 12:05 (48 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=22172
Subject		: alsa-util.c: snd_pcm_avail_delay() returned strange values: delay 0 is less than avail 32
Submitter	: Tobias <devnull@plzk.org>
Date		: 2010-11-06 09:33 (54 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=22092
Subject		: Kernel v2.6.36 trouble on USB disconnect
Submitter	: Ketil Froyn <ketil@froyn.name>
Date		: 2010-10-29 8:05 (62 days old)
Message-ID	: <<AANLkTik5qVxkEGVAA1PSOGk2KTW+ekHpSwttsQEWzWj+@mail.gmail.com>>
References	: http://marc.info/?l=linux-kernel&m=128833956503607&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=21652
Subject		: several problems with intel graphics since 2.6.36
Submitter	: Norbert Preining <preining@logic.at>
Date		: 2010-10-27 14:32 (64 days old)
Message-ID	: <20101027143252.GA8676@gamma.logic.tuwien.ac.at>
References	: http://marc.info/?l=linux-kernel&m=128818998630241&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=21402
Subject		: [KVM] Noacpi Windows guest can not boot up on 32bit KVM host
Submitter	: xudong <xudong.hao@intel.com>
Date		: 2010-10-29 03:01 (62 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=20332
Subject		: [LogFS] [2.6.36-rc7] Kernel BUG at lib/btree.c:465!
Submitter	: Prasad Joshi <prasadjoshi124@gmail.com>
Date		: 2010-10-12 18:56 (79 days old)
Message-ID	: <AANLkTimAbCZNhLQ5nADUiAC+7JpAeJBEmjFwdxyZ-FxO@mail.gmail.com>
References	: http://marc.info/?l=linux-kernel&m=128690910501830&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=20322
Subject		: 2.6.36-rc7: inconsistent lock state: inconsistent {IN-RECLAIM_FS-R} -> {RECLAIM_FS-ON-W} usage.
Submitter	: Dave Jones <davej@redhat.com>
Date		: 2010-10-11 20:10 (80 days old)
Message-ID	: <20101011201007.GA29707@redhat.com>
References	: http://marc.info/?l=linux-kernel&m=128682782828453&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=20232
Subject		: kworker consumes ~100% CPU on HP Elitebook 8540w running 2.6.36_rc6-git4
Submitter	: Ozan Caglayan <ozan@pardus.org.tr>
Date		: 2010-10-13 06:13 (78 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=19392
Subject		: WARNING: at drivers/net/wireless/ath/ath5k/base.c:3475 ath5k_bss_info_changed+0x44/0x168 [ath5k]()
Submitter	: Justin Mattock <justinmattock@gmail.com>
Date		: 2010-09-28 22:30 (93 days old)
Message-ID	: <<AANLkTim5WCGKPvEkOkO_YnMF9pg8mvLfQoFBNUFpfa_k@mail.gmail.com>>
References	: http://marc.info/?l=linux-kernel&m=128571307018635&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=19372
Subject		: 2.6.36-rc6: WARNING: at drivers/gpu/drm/radeon/radeon_fence.c:235 radeon_fence_wait+0x35a/0x3c0
Submitter	: Alexey Dobriyan <adobriyan@gmail.com>
Date		: 2010-09-29 21:29 (92 days old)
Message-ID	: <20100929212923.GA5578@core2.telecom.by>
References	: http://marc.info/?l=linux-kernel&m=128579579400315&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=19052
Subject		: 2.6.36-rc5-git1 -- [drm:i915_report_and_clear_eir] *ERROR* EIR stuck: 0x00000010, masking
Submitter	: Miles Lane <miles.lane@gmail.com>
Date		: 2010-09-22 23:47 (99 days old)
Message-ID	: <AANLkTikWQjUQjFJU9MO1+XbSLAEE-GARz+S+Dz2Fgu4h@mail.gmail.com>
References	: http://marc.info/?l=linux-kernel&m=128519926626322&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17121
Subject		: Two blank rectangles more than 10 cm long when booting
Submitter	: Eric Valette <eric.valette@free.fr>
Date		: 2010-08-26 17:24 (126 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17061
Subject		: 2.6.36-rc1 on zaurus: bluetooth regression
Submitter	: Pavel Machek <pavel@ucw.cz>
Date		: 2010-08-21 15:24 (131 days old)
Message-ID	: <20100821152445.GA1536@ucw.cz>
References	: http://marc.info/?l=linux-kernel&m=128240433828087&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16951
Subject		: hackbench regression with 2.6.36-rc1
Submitter	: Zhang, Yanmin <yanmin_zhang@linux.intel.com>
Date		: 2010-08-18 6:18 (134 days old)
Message-ID	: <1282112318.21202.8.camel@ymzhang.sh.intel.com>
References	: http://marc.info/?l=linux-kernel&m=128211235904910&w=2


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=21092
Subject		: Kernel 2.6.36 Bug during quotaon on reiserfs
Submitter	:  <markus.gapp@gmx.net>
Date		: 2010-10-24 16:57 (67 days old)
Handled-By	: Jan Kara <jack@suse.cz>
Patch		: https://bugzilla.kernel.org/attachment.cgi?id=35292


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16971
Subject		: qla4xxx compile failure on 32-bit PowerPC: missing readq and writeq
Submitter	: Meelis Roos <mroos@linux.ee>
Date		: 2010-08-19 21:03 (133 days old)
Message-ID	: <<<alpine.SOC.1.00.1008192359310.19654@math.ut.ee>>>
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

